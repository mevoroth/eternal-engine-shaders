#ifndef _SCREEN_VS_HLSL_
#define _SCREEN_VS_HLSL_

#include "screen.common.hlsl"

#define FULLSCREEN_MODE_QUAD		(0)
#define FULLSCREEN_MODE_TRIANGLE	(1)

#ifndef USE_FULLSCREEN_MODE
#define USE_FULLSCREEN_MODE			(FULLSCREEN_MODE_QUAD)
#endif

#if USE_FULLSCREEN_MODE == FULLSCREEN_MODE_QUAD
static const float2 VerticesSvPositions[] =
{
	float2(-1.0f,	-1.0f),
	float2( 1.0f,	-1.0f),
	float2( 1.0f,	 1.0f),
	float2(-1.0f,	 1.0f)
};

static const float2 UVs[] =
{
	float2(0.0f, 1.0f),
	float2(1.0f, 1.0f),
	float2(1.0f, 0.0f),
	float2(0.0f, 0.0f)
};

static const uint Indices[] =
{
	0, 1, 2,
	0, 2, 3
};
#elif USE_FULLSCREEN_MODE == FULLSCREEN_MODE_TRIANGLE
static const float2 VerticesSvPositions[] =
{
	float2(-1.0f,	 1.0f),
	float2(-1.0f,	-3.0f),
	float2( 3.0f,	 1.0f)
};

static const float2 UVs[] =
{
	float2(0.0f, 0.0f),
	float2(0.0f, 2.0f),
	float2(2.0f, 0.0f)
};

static const uint Indices[] =
{
	0, 1, 2
};
#else
#error "Unsupported triangle mode"
#endif

struct ShaderVertexIn
{
	uint VertexIndex	: SV_VertexID;
#if USE_MULTIPLE_LAYER_RENDER_TARGETS
	uint InstanceIndex	: SV_InstanceID;
#endif
};

ShaderPixelIn ShaderVertex( ShaderVertexIn IN )
{
	uint Index = Indices[IN.VertexIndex];

	ShaderPixelIn OUT = (ShaderPixelIn) 0;

	OUT.SvPosition				= float4(VerticesSvPositions[Index], 0.0f, 1.0f);
	OUT.UV						= UVs[Index];
#if USE_MULTIPLE_LAYER_RENDER_TARGETS
	OUT.RenderTargetArrayIndex	= IN.InstanceIndex;
#endif

	return OUT;
}

#endif
