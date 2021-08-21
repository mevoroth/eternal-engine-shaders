#ifndef _FUNCTIONS_COMMON_HLSL_
#define _FUNCTIONS_COMMON_HLSL_

float Luminance(float3 Color)
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

#endif
