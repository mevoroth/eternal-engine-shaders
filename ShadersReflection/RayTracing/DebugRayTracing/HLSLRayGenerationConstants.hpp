#ifndef _HLSL_RAY_GENERATION_CONSTANTS_HPP_
#define _HLSL_RAY_GENERATION_CONSTANTS_HPP_

struct RayGenerationViewport
{
	float Left;
	float Top;
	float Right;
	float Bottom;
};

HLSL_BEGIN_STRUCT(RayGenerationConstants)
	RayGenerationViewport Viewport;
	RayGenerationViewport Stencil;
HLSL_END_STRUCT(RayGenerationConstants)

#endif
