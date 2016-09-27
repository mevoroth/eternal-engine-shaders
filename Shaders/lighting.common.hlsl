#ifndef _LIGHTING_COMMON_HLSL_
#define _LIGHTING_COMMON_HLSL_

#include "common.hlsl"

struct Light
{
    float4 Position;
    float4 Color;
    float Distance;
    float Intensity;
};

cbuffer LightConstants : register(b1)
{
    Light Lights[8];
    int LightsCount;
}

struct PSOut
{
	float4 Refraction : SV_Target0;
};

#endif
