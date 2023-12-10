#ifndef _FUNCTIONS_COMMON_HLSL_
#define _FUNCTIONS_COMMON_HLSL_

#include "constants.common.hlsl"

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

float ColorToLuminance(float3 Color)
{
	return dot(Color, float3(0.2126f, 0.7152f, 0.0722f));
}

float2 UVToClipXY(float2 UV)
{
	return UV * float2(2.0f, -2.0f) + float2(-1.0f, 1.0f);
}

float3 UVDepthToWorldPosition(float2 UV, float Depth, float4x4 ClipToWorld)
{
	float4 ClipPosition		= float4(UVToClipXY(UV), Depth, 1.0f);
	float4 WorldPosition	= mul(ClipToWorld, ClipPosition);
	return WorldPosition.xyz / WorldPosition.w;
}

float3 SafeNormalize(float3 Vector)
{
	return Vector * rsqrt(max(dot(Vector, Vector), EPSILON));
}

bool RaySphereIntersection(float3 RayOrigin, float3 RayDirection, SphereDescription Sphere, out float2 OutSolutions)
{
	float3 LocalPosition = RayOrigin - Sphere.SphereCenter.xyz;
	float LocalPositionSquared = dot(LocalPosition, LocalPosition);
	float2 QuadraticCoefficient = float2(
		2.0f * dot(RayDirection, RayDirection),
		LocalPositionSquared - Sphere.SphereRadiusMetersSquared
	);
	float Discriminant = QuadraticCoefficient.x * QuadraticCoefficient.x - 4 * QuadraticCoefficient.y;
	float SqrtDiscriminant = sqrt(Discriminant);

	OutSolutions = (-QuadraticCoefficient.xx + float2(-1, 1) * SqrtDiscriminant.xx) * 0.5f;
	
	return Discriminant >= 0;
}

#endif
