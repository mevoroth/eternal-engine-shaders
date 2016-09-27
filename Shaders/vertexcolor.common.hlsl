#ifndef _VERTEX_COLOR_COMMON_HLSL_
#define _VERTEX_COLOR_COMMON_HLSL_

#include "common.hlsl"
#include "sampler.common.hlsl"

struct VSIn
{
	float4 Pos : SV_Position;
	float4 Col : COLOR0;
};

struct PSIn
{
	float4 Pos : SV_Position;
	float4 Col : COLOR0;
};

struct PSOut
{
	float Diffuse	: SV_Target0;
	float Depth		: SV_Depth;
};

#endif
