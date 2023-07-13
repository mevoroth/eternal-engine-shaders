#ifndef _IMGUI_COMMON_HLSL_
#define _IMGUI_COMMON_HLSL_

#include "platform.common.hlsl"
#include "ShadersReflection/Imgui/HLSLImgui.hpp"

struct ShaderVertexIn
{
	float2 Position		: POSITION0;
	float2 UV			: TEXCOORD0;
	float4 Color		: COLOR0;
};

struct ShaderPixelIn
{
	float4 SVPosition	: SV_POSITION;
	float4 Color		: COLOR0;
	float2 UV			: TEXCOORD0;
};

#endif
