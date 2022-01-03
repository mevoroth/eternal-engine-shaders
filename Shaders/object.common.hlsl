#ifndef _OBJECT_COMMON_HLSL_
#define _OBJECT_COMMON_HLSL_

#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/HLSLPerDrawConstants.hpp"

#ifndef OBJECT_NEEDS_NORMAL
#define OBJECT_NEEDS_NORMAL			(0)
#endif

#ifndef OBJECT_NEEDS_TANGENT
#define OBJECT_NEEDS_TANGENT		(0)
#endif

#ifndef OBJECT_NEEDS_BINORMAL
#define OBJECT_NEEDS_BINORMAL		(0)
#endif

#ifndef OBJECT_NEEDS_UV
#define OBJECT_NEEDS_UV				(0)
#endif

struct VSIn
{
	float4 Position : POSITION;
#if OBJECT_NEEDS_NORMAL
	float3 Normal	: NORMAL;
#endif
#if OBJECT_NEEDS_TANGENT
	float3 Tangent	: TANGENT;
#endif
#if OBJECT_NEEDS_BINORMAL
	float3 Binormal	: BINORMAL;
#endif
#if OBJECT_NEEDS_UV
	float2 UV		: TEXCOORD0;
#endif
};

struct PSIn
{
	float4 SVPosition	: SV_Position;
#if OBJECT_NEEDS_NORMAL
	float3 Normal		: NORMAL;
#endif
#if OBJECT_NEEDS_TANGENT
	float3 Tangent		: TANGENT;
#endif
#if OBJECT_NEEDS_BINORMAL
	float3 Binormal		: BINORMAL;
#endif
#if OBJECT_NEEDS_UV
	float2 UV			: TEXCOORD0;
#endif
};

struct PSOut
{
	float3 Emissive						: SV_Target0;
	float4 Albedo						: SV_Target1;
	float4 Normal						: SV_Target2;
	float4 RoughnessMetallicSpecular	: SV_Target3;
};

struct 

PSIn ComputePSIn(VSIn IN, PerDrawConstants PerDrawConstantBuffer, PerViewConstants PerViewConstantBuffer)
{
	PSIn OUT = (PSIn)0;

	OUT.SVPosition = mul(PerDrawConstantBuffer.SubMeshToWorld, IN.Position);
	OUT.SVPosition = mul(PerViewConstantBuffer.WorldToClip, OUT.SVPosition);
#if OBJECT_NEEDS_NORMAL
	OUT.Normal = IN.Normal;
#endif
#if OBJECT_NEEDS_TANGENT
	OUT.Tangent = IN.Tangent;
#endif
#if OBJECT_NEEDS_BINORMAL
	OUT.Binormal = IN.Binormal;
#endif
#if OBJECT_NEEDS_UV
	OUT.UV = IN.UV;
#endif

	return OUT;
}

#endif
