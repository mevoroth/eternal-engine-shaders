#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/HLSLVolumetricClouds.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(													0, 0);
REGISTER_B(ConstantBuffer<VolumetricCloudsConstants>	VolumetricCloudsConstantBuffer,	1, 0);
REGISTER_T(Texture2D<float>		DepthTexture,											0, 0);
REGISTER_U(RWTexture2D<float4>	OutColor,												0, 0);
REGISTER_S(SamplerState			PointSampler,											0, 0);

struct SphereDescription
{
	float3 SphereCenter;
	float SphereRadiusSquared
};

SphereDescription InitializeSphereDescription(float SphereRadiusSquared, float3 SphereCenter = (float3)0.0f)
{
	SphereDescription Description	= (SphereDescription)0;
	Description.SphereCenter		= SphereCenter;
	Description.SphereRadiusSquared	= SphereRadiusSquared;
	return Description;
}

float HenyeyGreensteinPhase(float G, float CosTheta)
{
	float GSquared = G * G;
	return (1.0f - GSquared) / pow(1.0f + GSquared - 2 * G * CosTheta, 3.0f / 2.0f);
}

bool RaySphereIntersection(float3 RayOrigin, float3 RayDirection, SphereDescription Sphere, inout float2 Solutions)
{
	float3 LocalPosition = RayOrigin - Sphere.SphereCenter.xyz;
	float LocalPositionSquared = dot(LocalPosition, LocalPosition);
	float2 QuadraticCoefficient = float3(
		2.0f * dot(RayDirection, RayDirection),
		LocalPositionSquared - Sphere.SphereRadiusSquared
	);
	float Discriminant = QuadraticCoefficient.x * QuadraticCoefficient.x - 4 * QuadraticCoefficient.y;
	float SqrtDiscriminant = sqrt(Discriminant);

	Solutions = (-QuadraticCoefficient.xx + float2(-1, 1) * SqrtDiscriminant.xx) * 0.5f;
	
	return Discriminant >= 0;
}

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void CS( uint3 DTid : SV_DispatchThreadID )
{
	if (any(DTid.xy >= PerViewConstantBuffer.ScreenSizeAndInverseSize.xy))
		return;
	
	const float3 RayOrigin = PerViewConstantBuffer.ViewPosition.xyz;
	const float3 RayDirection = PerViewConstantBuffer.ViewFormard.xyz;

	SphereDescription TopClouds		= InitializeSphereDescription(VolumetricCloudsConstantBuffer.TopLayerRadiusSquared);
	SphereDescription BottomClouds	= InitializeSphereDescription(VolumetricCloudsConstantBuffer.BottomLayerRadiusSquared);

	float2 TopCloudsSolutions		= (float2)0.0f;
	float2 BottomCloudsSolutions	= (float2)0.0f;
	float2 CloudsMarchingMinMax		= (float2)0.0f;

	bool IntersectTop		= RaySphereIntersection(RayOrigin, RayDirection, TopClouds,		TopCloudsSolutions);
	bool IntersectBottom	= RaySphereIntersection(RayOrigin, RayDirection, BottomClouds,	BottomCloudsSolutions);

	if (!IntersectTop)
		return;

	if (IntersectBottom)
	{
		CloudsMarchingMinMax = float2(
			all(TopCloudsSolutions > 0.0f) || all(BottomCloudsSolutions > 0.0f) ? min(TopCloudsSolutions.x, TopCloudsSolutions.y) : max(TopCloudsSolutions.x, TopCloudsSolutions.y),
			all(BottomCloudsSolutions > 0.0f) ? min(BottomCloudsSolutions.x, BottomCloudsSolutions.y) : max(BottomCloudsSolutions.x, BottomCloudsSolutions.y)
		);
		CloudsMarchingMinMax.x = max(0.0f, CloudsMarchingMinMax.x);
	}
	else
	{
		CloudsMarchingMinMax = TopCloudsSolutions;
	}

	float Depth = DepthTexture[DTid.xy].x;

	OutColor[DTid.xy] = float4(1, 0, 0, 1);
}
