#ifndef _VERTEX_COLOR_COMMON_HLSL_
#define _VERTEX_COLOR_COMMON_HLSL_

#include "common.hlsl"
#include "sampler.common.hlsl"

struct ShaderVertexIn
{
	float4 Pos : POSITION;
	float4 Col : COLOR0;
};

struct ShaderPixelIn
{
	float4 Pos : SV_Position;
	float4 Col : COLOR0;
};

struct ShaderPixelOut
{
	float4 Diffuse	: SV_Target;
};

#endif
