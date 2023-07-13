#ifndef _SCREEN_COMMON_HLSL_
#define _SCREEN_COMMON_HLSL_

#define MULTIPLE_LAYER_RENDER_TARGETS_NONE		(0)
#define MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP	(1)

#ifndef USE_MULTIPLE_LAYER_RENDER_TARGETS
#define USE_MULTIPLE_LAYER_RENDER_TARGETS		(MULTIPLE_LAYER_RENDER_TARGETS_NONE)
#endif

struct ShaderPixelIn
{
	float4 SvPosition			: SV_Position;
	float2 UV					: TEXCOORD0;
#if USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP
	uint RenderTargetArrayIndex	: SV_RenderTargetArrayIndex;
#endif
};

#endif
