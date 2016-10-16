#ifndef _POST_PROCESS_VS_HLSL_
#define _POST_PROCESS_VS_HLSL_

#include "postprocess.common.hlsl"

static const float2 Vertices[] =
{
	float2(-1.0f,	-1.0f),
	float2( 1.0f,	-1.0f),
	float2( 1.0f,	 1.0f),
	float2(-1.0f,	 1.0f)
};

#ifdef POST_PROCESS_UV_INVERT
static const float2 UVs[] =
{
	float2(0.0f, 1.0f),
	float2(1.0f, 1.0f),
	float2(1.0f, 0.0f),
	float2(0.0f, 0.0f)
};
#else
static const float2 UVs[] =
{
	float2(0.0f, 0.0f),
	float2(1.0f, 0.0f),
	float2(1.0f, 1.0f),
	float2(0.0f, 1.0f)
};
#endif

static const uint Indices[] =
{
	0, 2, 1,
	0, 3, 2
};

PSIn VS( uint vid : SV_VertexID )
{
	uint Index = Indices[vid];

	PSIn OUT = (PSIn) 0;

	OUT.Pos = float4(Vertices[Index], 0.0f, 1.0f);
	OUT.UV = UVs[Index];

	return OUT;
}

#endif
