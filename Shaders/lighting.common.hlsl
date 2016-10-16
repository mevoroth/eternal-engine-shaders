#ifndef _LIGHTING_COMMON_HLSL_
#define _LIGHTING_COMMON_HLSL_

#include "common.hlsl"
#include "sampler.common.hlsl"

#define BRDF_FRESNEL_SCHLICK
#define BRDF_DISTRIBUTION_GGX
#define BRDF_GEOMETRY_GGX
#include "brdf.common.hlsl"

struct Light
{
	float4 Position;
	float4 Color;
	float Distance;
	float Intensity;
};

cbuffer LightConstants : register(b1)
{
	Light Lights[8];
	int LightsCount;
}

struct PSOut
{
	float4 Light : SV_Target0;
};

Texture2D DepthTexture			: register(t0);
Texture2D DiffuseTexture		: register(t1);
Texture2D SpecularTexture		: register(t2);
Texture2D NormalTexture			: register(t3);
Texture2D DepthDebugTexture		: register(t10);

float3 SpecularBRDF(float3 Specular, float Roughness2, float VdotH, float NdotH, float NdotV, float NdotL)
{
	//return Geometry(Roughness2, NdotV, NdotL).xxx;
	//return Distribution(Roughness2, NdotH).xxx;
	//return Fresnel(VdotH, Specular);
	return Distribution(Roughness2, NdotH).xxx * Fresnel(VdotH, Specular) * Geometry(Roughness2, NdotV, NdotL).xxx / (4.0f * NdotL * NdotV);
}

float3 DiffuseBRDF(float3 Diffuse)
{
	return Diffuse * (1.0f / 3.14159265359f);
}

#endif
