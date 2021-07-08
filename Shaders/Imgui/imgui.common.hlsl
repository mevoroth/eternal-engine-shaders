#ifndef _IMGUI_COMMON_HLSL_
#define _IMGUI_COMMON_HLSL_

#include "platform.common.hlsl"

struct VSIn
{
	float2 Position		: POSITION;
	float2 UV			: TEXCOORD0;
	float4 Color		: COLOR0;
};

struct PSIn
{
	float4 SVPosition	: SV_POSITION;
	float4 Color		: COLOR0;
	float2 UV			: TEXCOORD0;
};

#endif
