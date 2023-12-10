#ifndef _DEBUG_RAYTRACING_COMMON_HLSL_
#define _DEBUG_RAYTRACING_COMMON_HLSL_

#include "ShadersReflection/RayTracing/Debug/HLSLRayGenerationConstants.hpp"

struct RayPayload
{
	float4 Color;
};

REGISTER_T(RaytracingAccelerationStructure					Scene,							0, 0);
RW_RESOURCE(RWTexture2D, float4, SPIRV_FORMAT_R11FG11FB10F,	OutRenderTarget,				0, 0);
CONSTANT_BUFFER(RayGenerationConstants,						RayGenerationConstantBuffer,	0, 0);

bool IsInsideViewport(float2 Point, RayGenerationViewport Viewport)
{
	return (Point.x >= Viewport.Left && Point.x <= Viewport.Right)
		&& (Point.y >= Viewport.Top && Point.y <= Viewport.Bottom);
}

#endif
