#ifndef _DIRECT_LIGHTING_COMMON_HLSL_
#define _DIRECT_LIGHTING_COMMON_HLSL_

#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"
#include "screen.common.hlsl"
#include "ShadersReflection/HLSLDirectLighting.hpp"

struct ShaderPixelOut
{
	float4 Luminance : SV_Target0;
};

#endif
