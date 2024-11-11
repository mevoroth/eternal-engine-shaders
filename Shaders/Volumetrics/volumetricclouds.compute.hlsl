#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/HLSLVolumetricCloudsConstants.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(													0, 0);
CONSTANT_BUFFER(VolumetricCloudsConstants, VolumetricCloudsConstantBuffer,				1, 0);
REGISTER_T(Texture2D<float>		DepthTexture,											0, 0);
REGISTER_T(Texture3D<float4>	BaseCloudsTexture,										1, 0);
REGISTER_S(SamplerState			BilinearSampler,										0, 0);
RW_RESOURCE(RWTexture2D, float3, SPIRV_FORMAT_R11FG11FB10F, OutColor,					0, 0);

#include "Volumetrics/volumetrics.type.hlsl"
ParticipatingMediaDescription SampleParticipatingMedia(float3 PositionWS)
{
	ParticipatingMediaDescription ParticipatingMedia = (ParticipatingMediaDescription)0;

	float3 SphereCenter = float3(1000, 5000, 0);
	float SphereSize = 5000;

	float3 PositionToSphereCenter = PositionWS - SphereCenter;
	
	if (dot(PositionToSphereCenter, PositionToSphereCenter) > SphereSize * SphereSize)
	{
		ParticipatingMedia.Scattering[SCATTERING_TYPE_MIE]		= float3(0.7, 0.7, 0.9);
		ParticipatingMedia.Extinction = float3(0.75, 0.25, 0);
		float4 BaseClouds = BaseCloudsTexture.SampleLevel(BilinearSampler, PositionWS / 10000.0f, 0).xyzw;
		ParticipatingMedia.Scattering[SCATTERING_TYPE_MIE] *= BaseClouds.x * VolumetricCloudsConstantBuffer.CloudsDensity;
		ParticipatingMedia.Extinction *= BaseClouds.x * VolumetricCloudsConstantBuffer.CloudsDensity;
	}
	//else
	//{

	//	ParticipatingMedia.Scattering = float3(0.7, 0.2, 0.2);
	//}

	return ParticipatingMedia;
}
#include "Volumetrics/volumetrics.common.hlsl"

float3 SampleCloudsShadow(float3 PositionWS, float3 RayDirection)
{
	const int MaxShadowSteps = 8;

	const float MaxShadowDistance = 5000.0f;

	float3 Extinction = 0.0f;

	float3 CurrentPositionWS	= PositionWS;
	float3 RayStep				= RayDirection * (MaxShadowDistance / MaxShadowSteps);
	for (int ShadowStep = 0; ShadowStep < MaxShadowSteps; ++ShadowStep)
	{
		ParticipatingMediaDescription ParticipatingMedia = SampleParticipatingMedia(CurrentPositionWS);
		Extinction			+= ParticipatingMedia.Extinction;
		CurrentPositionWS	+= RayStep;
	}

	return exp(-Extinction * MaxShadowDistance);
}

bool InitializeCloudsMarchingRange(float3 RayOrigin, float3 RayDirection, float CloudsMarchingRangeMax, out float2 OutCloudsMarchingMinMax)
{
	float2 TopCloudsSolutions				= (float2)0.0f;
	float2 BottomCloudsSolutions			= (float2)0.0f;

	const SphereDescription TopClouds		= InitializeSphereDescription(VolumetricCloudsConstantBuffer.CloudsTopLayerRadiusMetersSquared);
	const SphereDescription BottomClouds	= InitializeSphereDescription(VolumetricCloudsConstantBuffer.CloudsBottomLayerRadiusMetersSquared);

	const bool IntersectTop					= RaySphereIntersection(RayOrigin, RayDirection, TopClouds, TopCloudsSolutions);
	const bool IntersectBottom				= RaySphereIntersection(RayOrigin, RayDirection, BottomClouds, BottomCloudsSolutions);

	if (!IntersectTop)
		return false;

	if (IntersectBottom)
	{
		OutCloudsMarchingMinMax = float2(
			all(BottomCloudsSolutions > 0.0f) ? min(BottomCloudsSolutions.x, BottomCloudsSolutions.y) : max(BottomCloudsSolutions.x, BottomCloudsSolutions.y),
			all(TopCloudsSolutions > 0.0f) || all(BottomCloudsSolutions > 0.0f) ? min(TopCloudsSolutions.x, TopCloudsSolutions.y) : max(TopCloudsSolutions.x, TopCloudsSolutions.y)
		);
	}
	else
	{
		OutCloudsMarchingMinMax = TopCloudsSolutions;
	}

	OutCloudsMarchingMinMax.x = max(OutCloudsMarchingMinMax.x, 0.0f);
	OutCloudsMarchingMinMax.y = min(OutCloudsMarchingMinMax.y, CloudsMarchingRangeMax);

	return OutCloudsMarchingMinMax.x < OutCloudsMarchingMinMax.y;
}

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DTid : SV_DispatchThreadID )
{
	if (any((int2)DTid.xy >= PerViewConstantBuffer.ViewSizeAndInverseSize.xy))
		return;
	
	const float2 ScreenUV		= (DTid.xy + 0.5f) * PerViewConstantBuffer.ViewSizeAndInverseSize.zw;
	const float3 RayOrigin		= PerViewConstantBuffer.ViewPosition.xyz;
	const float3 RayDirection	= normalize(UVDepthToWorldPosition(ScreenUV, PerViewConstantBuffer.ViewRenderFarPlane, PerViewConstantBuffer.ClipToWorld) - RayOrigin);

	float2 CloudsMarchingMinMax		= (float2)0.0f;
	
	const float Depth				= DepthTexture[DTid.xy].x;
	const float3 GeometryPosition	= UVDepthToWorldPosition(ScreenUV, Depth, PerViewConstantBuffer.ClipToWorld);
	const float GeometryIntersect	= dot(GeometryPosition, RayDirection);
	VOID_RESOURCE(float, GeometryIntersect);

	float CloudsMarchingRangeMax = min(distance(GeometryPosition, RayOrigin), 10000.0f);

	if (!InitializeCloudsMarchingRange(RayOrigin, RayDirection, CloudsMarchingRangeMax, CloudsMarchingMinMax))
		return;

	//CloudsMarchingMinMax = min(CloudsMarchingMinMax, GeometryIntersect.xx);
	float CloudsMarchingRangeMeters	= CloudsMarchingMinMax.y - CloudsMarchingMinMax.x;
	float CloudsMarchingDeltaMeters	= CloudsMarchingRangeMeters * VolumetricCloudsConstantBuffer.CloudsMaxStepsRcp;
	float3 CloudsMarchingPosition	= RayOrigin + RayDirection * CloudsMarchingMinMax.x;

	const float3 LightDirection = float3(0, -1, 0);

	float3 Luminance		= (float3)0.0f;
	float3 Transmittance	= (float3)1.0f;
	float LdotV				= dot(LightDirection, RayDirection);
	float Phase[VOLUMETRIC_PHASE_COUNT];
	for (int PhaseIndex = 0; PhaseIndex < VOLUMETRIC_PHASE_COUNT; ++PhaseIndex)
		Phase[PhaseIndex] = HenyeyGreensteinPhase(VolumetricCloudsConstantBuffer.CloudsPhaseG[PhaseIndex].Value, LdotV);
	float PhaseFinal = Phase[0] + VolumetricCloudsConstantBuffer.CloudsPhaseBlend * (Phase[1] - Phase[0]);

	float DistanceMeters = 0.0f;

	for (int Step = 0; Step < VolumetricCloudsConstantBuffer.CloudsMaxSteps; ++Step)
	{
		ParticipatingMediaDescription ParticipatingMedia = SampleParticipatingMedia(CloudsMarchingPosition);

		float3 LightLuminance = 2.5;
		
		const float3 CloudsShadow = SampleCloudsShadow(CloudsMarchingPosition, -LightDirection);

		float3 ScatteredLuminance = LightLuminance * ParticipatingMedia.Scattering[SCATTERING_TYPE_MIE] * PhaseFinal * CloudsShadow;

		const float3 SafeExtinctionThreshold = 0.000001f;
		const float3 SafeExtinction = max(SafeExtinctionThreshold, ParticipatingMedia.Extinction);
		const float3 SafeDeltaTransmittance = exp(-SafeExtinction * CloudsMarchingDeltaMeters);
		float3 DeltaLuminance = (ScatteredLuminance - ScatteredLuminance * SafeDeltaTransmittance) / SafeExtinction;
		
		Luminance		+= Transmittance * DeltaLuminance;
		Transmittance	*= SafeDeltaTransmittance;

		CloudsMarchingPosition += RayDirection * CloudsMarchingDeltaMeters;
		DistanceMeters += CloudsMarchingDeltaMeters;
	}

	//OutColor[DTid.xy] = OutColor[DTid.xy].rgb * (1.0f.xxx - Transmittance) + Luminance;
}
