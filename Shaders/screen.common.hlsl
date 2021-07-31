#ifndef _SCREEN_COMMON_HLSL_
#define _SCREEN_COMMON_HLSL_

struct PSIn
{
	float4 SvPosition	: SV_Position;
	float2 UV			: TEXCOORD0;
};

#endif
