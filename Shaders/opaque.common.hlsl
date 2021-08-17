#ifndef _OPAQUE_COMMON_HLSL_
#define _OPAQUE_COMMON_HLSL_

#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"

struct VSIn
{
	float4 Position : POSITION;
	float3 Normal	: NORMAL;
	float3 Tangent	: TANGENT;
	float3 Binormal	: BINORMAL;
	float2 UV		: TEXCOORD0;
};

struct PSIn
{
	float4 SVPosition	: SV_Position;
	float3 Normal		: NORMAL;
	float3 Tangent		: TANGENT;
	float3 Binormal		: BINORMAL;
	float2 UV			: TEXCOORD0;
};

struct PSOut
{
	float3 Emissive						: SV_Target0;
	float4 Albedo						: SV_Target1;
	float4 Normal						: SV_Target2;
	float4 RoughnessMetallicSpecular	: SV_Target3;
};

#endif
