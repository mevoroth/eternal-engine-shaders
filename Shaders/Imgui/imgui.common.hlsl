#ifndef _IMGUI_COMMON_HLSL_
#define _IMGUI_COMMON_HLSL_

#include "ShadersReflection/Imgui/HLSLImgui.hpp"

struct ShaderVertexIn
{
	float2 Position		: POSITION0;
	float2 UV			: TEXCOORD0;
	float4 Color		: COLOR0;
};

struct ShaderPixelIn
{
	float4 SVPosition	: SV_Position;
	float4 Color		: COLOR0;
	float2 UV			: TEXCOORD0;
};

#endif
