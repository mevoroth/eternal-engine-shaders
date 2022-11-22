#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/HLSLVolumetricClouds.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(													0, 0);
REGISTER_B(ConstantBuffer<VolumetricCloudsConstants>	VolumetricCloudsConstantBuffer,	1, 0);
REGISTER_T(Texture2D<float>		DepthTexture,											0, 0);
RW_RESOURCE(RWTexture2D, float3, SPIRV_FORMAT_R11FG11FB10F, OutColor,					0, 0);

struct SphereDescription
{
	float3 SphereCenter;
	float SphereRadiusMetersSquared;
};

SphereDescription InitializeSphereDescription(float SphereRadiusMetersSquared, float3 SphereCenter = (float3)0.0f)
{
	SphereDescription Description			= (SphereDescription)0;
	Description.SphereCenter				= SphereCenter;
	Description.SphereRadiusMetersSquared	= SphereRadiusMetersSquared;
	return Description;
}

struct ParticipatingMediaDescription
{
	float3 Scattering;
	float3 Extinction;
};

ParticipatingMediaDescription SampleParticipatingMedia(float3 PositionWS)
{
	ParticipatingMediaDescription ParticipatingMedia = (ParticipatingMediaDescription)0;

	float3 SphereCenter = float3(1000, 5000, 0);
	float SphereSize = 4500;

	float3 PositionToSphereCenter = PositionWS - SphereCenter;
	
	if (dot(PositionToSphereCenter, PositionToSphereCenter) < SphereSize * SphereSize)
	{
		ParticipatingMedia.Scattering = float3(0.7, 0.7, 0.9);
		ParticipatingMedia.Extinction = float3(0.75, 0.25, 0);
	}

	return ParticipatingMedia;
}

float HenyeyGreensteinPhase(float G, float CosTheta)
{
	float GSquared = G * G;
	return (1.0f - GSquared) / pow(abs(1.0f + GSquared - 2 * G * CosTheta), 3.0f / 2.0f);
}

bool RaySphereIntersection(float3 RayOrigin, float3 RayDirection, SphereDescription Sphere, inout float2 Solutions)
{
	float3 LocalPosition = RayOrigin - Sphere.SphereCenter.xyz;
	float LocalPositionSquared = dot(LocalPosition, LocalPosition);
	float2 QuadraticCoefficient = float2(
		2.0f * dot(RayDirection, RayDirection),
		LocalPositionSquared - Sphere.SphereRadiusMetersSquared
	);
	float Discriminant = QuadraticCoefficient.x * QuadraticCoefficient.x - 4 * QuadraticCoefficient.y;
	float SqrtDiscriminant = sqrt(Discriminant);

	Solutions = (-QuadraticCoefficient.xx + float2(-1, 1) * SqrtDiscriminant.xx) * 0.5f;
	
	return Discriminant >= 0;
}

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void CS( uint3 DTid : SV_DispatchThreadID )
{
	if (any((int2)DTid.xy >= PerViewConstantBuffer.ScreenSizeAndInverseSize.xy))
		return;
	
	const float2 ScreenUV		= DTid.xy * PerViewConstantBuffer.ScreenSizeAndInverseSize.zw;
	const float3 RayOrigin		= PerViewConstantBuffer.ViewPosition.xyz;
	const float3 RayDirection	= normalize(UVDepthToWorldPosition(ScreenUV, PerViewConstantBuffer.RenderFarPlane, PerViewConstantBuffer.ClipToWorld) - RayOrigin);

	const SphereDescription TopClouds		= InitializeSphereDescription(VolumetricCloudsConstantBuffer.TopLayerRadiusMetersSquared);
	const SphereDescription BottomClouds	= InitializeSphereDescription(VolumetricCloudsConstantBuffer.BottomLayerRadiusMetersSquared);

	float2 TopCloudsSolutions		= (float2)0.0f;
	float2 BottomCloudsSolutions	= (float2)0.0f;
	float2 CloudsMarchingMinMax		= (float2)0.0f;
	
	const bool IntersectTop		= RaySphereIntersection(RayOrigin, RayDirection, TopClouds,		TopCloudsSolutions);
	const bool IntersectBottom	= RaySphereIntersection(RayOrigin, RayDirection, BottomClouds,	BottomCloudsSolutions);

	if (!IntersectTop)
		return;

	if (IntersectBottom)
	{
		CloudsMarchingMinMax = float2(
			all(BottomCloudsSolutions > 0.0f) ? min(BottomCloudsSolutions.x, BottomCloudsSolutions.y) : max(BottomCloudsSolutions.x, BottomCloudsSolutions.y),
			all(TopCloudsSolutions > 0.0f) || all(BottomCloudsSolutions > 0.0f) ? min(TopCloudsSolutions.x, TopCloudsSolutions.y) : max(TopCloudsSolutions.x, TopCloudsSolutions.y)
		);
		CloudsMarchingMinMax.y = max(0.0f, CloudsMarchingMinMax.y);
	}
	else
	{
		CloudsMarchingMinMax = TopCloudsSolutions;
	}

	const float Depth				= DepthTexture[DTid.xy].x;
	const float3 GeometryPosition	= UVDepthToWorldPosition(ScreenUV, Depth, PerViewConstantBuffer.ClipToWorld);
	const float GeometryIntersect	= dot(GeometryPosition, RayDirection);

	if (GeometryIntersect <= CloudsMarchingMinMax.x)
		return;

	CloudsMarchingMinMax = min(CloudsMarchingMinMax, GeometryIntersect.xx);
	float CloudsMarchingRangeMeters	= CloudsMarchingMinMax.y - CloudsMarchingMinMax.x;
	float CloudsMarchingDeltaMeters	= CloudsMarchingRangeMeters * VolumetricCloudsConstantBuffer.MaxStepsRcp;

	const float3 LightDirection = float3(0, -1, 0);

	float3 Luminance		= (float3)0.0f;
	float3 Transmittance	= (float3)1.0f;
	float LightCosTheta		= dot(LightDirection, RayDirection);
	float Phase[VOLUMETRIC_PHASE_COUNT];
	for (int PhaseIndex = 0; PhaseIndex < VOLUMETRIC_PHASE_COUNT; ++PhaseIndex)
		Phase[PhaseIndex] = HenyeyGreensteinPhase(VolumetricCloudsConstantBuffer.PhaseG[PhaseIndex].Value, LightCosTheta);
	float PhaseFinal = Phase[0] + VolumetricCloudsConstantBuffer.PhaseBlend * (Phase[1] - Phase[0]);

	float DistanceMeters = 0.0f;
	float3 CloudsMarchingPosition = RayOrigin + RayDirection * CloudsMarchingMinMax.x;

	for (int Step = 0; Step < VolumetricCloudsConstantBuffer.MaxSteps; ++Step)
	{
		ParticipatingMediaDescription ParticipatingMedia = SampleParticipatingMedia(CloudsMarchingPosition);

		float3 LightLuminance = 2.5;
		float3 ScatteredLuminance = LightLuminance * ParticipatingMedia.Scattering * PhaseFinal;

		const float3 SafeExtinctionThreshold = 0.000001f;
		const float3 SafeExtinction = max(SafeExtinctionThreshold, ParticipatingMedia.Extinction);
		const float3 SafeDeltaTransmittance = exp(-SafeExtinction * CloudsMarchingDeltaMeters);
		float3 DeltaLuminance = (ScatteredLuminance - ScatteredLuminance * SafeDeltaTransmittance) / SafeExtinction;
		
		Luminance		+= Transmittance * DeltaLuminance;
		Transmittance	*= SafeDeltaTransmittance;

		CloudsMarchingPosition += RayDirection * CloudsMarchingDeltaMeters;
		DistanceMeters += CloudsMarchingDeltaMeters;
	}

	OutColor[DTid.xy] = OutColor[DTid.xy].rgb * (1.0f.xxx - Transmittance) + Luminance;
}
