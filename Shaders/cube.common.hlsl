#ifndef _CUBE_COMMON_HLSL_
#define _CUBE_COMMON_HLSL_

#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"
#include "perinstance.common.hlsl"
#include "ShadersReflection/HLSLPerDrawConstants.hpp"

struct PSIn
{
	float4 SVPosition : SV_Position;
};

#endif