#ifndef _SCREEN_VS_HLSL_
#define _SCREEN_VS_HLSL_

#include "screen.common.hlsl"

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

PSIn VS( uint vid : SV_VertexID )
{
	uint Index = Indices[vid];

	PSIn OUT = (PSIn) 0;

	OUT.SvPosition	= float4(VerticesSvPositions[Index], 0.0f, 1.0f);
	OUT.UV			= UVs[Index];

	return OUT;
}

#endif
