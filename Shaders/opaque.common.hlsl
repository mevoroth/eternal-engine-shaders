#ifndef _OPAQUE_COMMON_HLSL_
#define _OPAQUE_COMMON_HLSL_

#include "common.hlsl"
#include "sampler.common.hlsl"

struct VSIn
{
	float4 Pos : SV_Position;
	float4 Normal : NORMAL;
	float2 UV : TEXCOORD0;
};

struct PSIn
{
	float4 Pos : SV_Position;
	float4 Normal : NORMAL;
	float2 UV : TEXCOORD0;
};

struct PSOut
{
	float4	Diffuse						: SV_Target0;
	float4	MetallicRoughnessSpecular	: SV_Target1;
	float4	Emissive					: SV_Target2;
	float4	Normal						: SV_Target3;
    float	Depth						: SV_Depth;
};

Texture2D DiffuseTexture					: register(t0);
Texture2D MetallicRoughnessSpecularTexture	: register(t1);
Texture2D EmissiveTexture					: register(t2);
Texture2D NormalTexture						: register(t3);

#define OpaqueSampler BilinearSampler

cbuffer ObjectConstants : register(b1)
{
	matrix Model;
};

#endif
