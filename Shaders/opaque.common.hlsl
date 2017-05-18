#ifndef _OPAQUE_COMMON_HLSL_
#define _OPAQUE_COMMON_HLSL_

#include "common.hlsl"
#include "sampler.common.hlsl"

struct VSIn
{
	float4 Pos : SV_Position;
	float4 Normal : NORMAL;
	float4 Tangent : TANGENT;
	float4 Binormal : BINORMAL;
	float2 UV : TEXCOORD0;
};

struct PSIn
{
	float4 Pos				: SV_Position;
	float4 Normal			: NORMAL;
	float2 UV				: TEXCOORD0;
	//float RoughnessDebug	: ROUGHNESS;
	float Depth				: DEPTH;
	//float W					: HOMOGENEOUS;
	//float4 WorldPos			: Debug0;
};

struct PSOut
{
	float4	Diffuse		: SV_Target0;
	float4	Specular	: SV_Target1;
	//float4	Emissive	: SV_Target2;
	float4	Normal		: SV_Target2;
	float4	Roughness	: SV_Target3;
	//float	W			: SV_Target5;
	//float4	WorldPos	: SV_Target6;	// Only for debug
	float	Depth		: SV_Depth;
};

Texture2D DiffuseTexture	: register(t0, space1);
Texture2D SpecularTexture	: register(t1, space1);
//Texture2D EmissiveTexture	: register(t2, space1);
Texture2D NormalTexture		: register(t2, space1);
Texture2D RoughnessTexture	: register(t3, space1);

#define OpaqueSampler BilinearSampler

cbuffer ObjectConstants : register(b1, space0)
{
	matrix ObjectModel;
};

struct InstanceStructuredBuffer
{
	matrix Model;
};

StructuredBuffer<InstanceStructuredBuffer> InstanceStructuredBufferData : register(t0, space0);

#endif
