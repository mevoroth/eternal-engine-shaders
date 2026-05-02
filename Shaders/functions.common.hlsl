#ifndef _FUNCTIONS_COMMON_HLSL_
#define _FUNCTIONS_COMMON_HLSL_

#include "constants.common.hlsl"

struct SphereDescription
{
	float3 SphereCenter;
	float SphereRadiusMetersSquared;
};

SphereDescription InitializeSphereDescription(float InSphereRadiusMetersSquared, float3 InSphereCenter = (float3)0.0f)
{
	SphereDescription Description			= (SphereDescription)0;
	Description.SphereCenter				= InSphereCenter;
	Description.SphereRadiusMetersSquared	= InSphereRadiusMetersSquared;
	return Description;
}

float2 UVToClipXY(float2 InUV)
{
	return InUV * float2(2.0f, -2.0f) + float2(-1.0f, 1.0f);
}

float3 UVDepthToWorldPosition(float2 InUV, float InDepth, float4x4 InClipToWorld)
{
	float4 ClipPosition		= float4(UVToClipXY(InUV), InDepth, 1.0f);
	float4 WorldPosition	= mul(InClipToWorld, ClipPosition);
	return WorldPosition.xyz / WorldPosition.w;
}

float3 SafeNormalize(float3 InVector)
{
	return InVector * rsqrt(max(dot(InVector, InVector), EPSILON));
}

bool RaySphereIntersection(float3 InRayOrigin, float3 InRayDirection, SphereDescription InSphere, out float2 OutSolutions)
{
	float3 LocalPosition = InRayOrigin - InSphere.SphereCenter.xyz;
	float LocalPositionSquared = dot(LocalPosition, LocalPosition);
	float2 QuadraticCoefficient = float2(
		2.0f * dot(InRayDirection, InRayDirection),
		LocalPositionSquared - InSphere.SphereRadiusMetersSquared
	);
	float Discriminant = QuadraticCoefficient.x * QuadraticCoefficient.x - 4 * QuadraticCoefficient.y;
	float SqrtDiscriminant = sqrt(Discriminant);

	OutSolutions = (-QuadraticCoefficient.xx + float2(-1, 1) * SqrtDiscriminant.xx) * 0.5f;
	
	return Discriminant >= 0;
}

#endif
