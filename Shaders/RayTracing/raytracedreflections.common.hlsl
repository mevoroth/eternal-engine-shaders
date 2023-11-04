#ifndef _RAYTRACED_REFLECTIONS_COMMON_HLSL_
#define _RAYTRACED_REFLECTIONS_COMMON_HLSL_

#include "platform.common.hlsl"
#include "perview.common.hlsl"

struct RayPayload
{
	float4 Luminance;
};

REGISTER_T(RaytracingAccelerationStructure					Scene,							0, 0);
REGISTER_T(Texture2D<float>									DepthTexture,					1, 0);
REGISTER_T(Texture2D<float4>								NormalsTexture,					2, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(														0, 0);
RW_RESOURCE(RWTexture2D, float4, SPIRV_FORMAT_R11FG11FB10F,	OutLuminance,					0, 0);

#endif
