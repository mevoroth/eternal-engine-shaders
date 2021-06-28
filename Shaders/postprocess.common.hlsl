#ifndef _POST_PROCESS_COMMON_HLSL_
#define _POST_PROCESS_COMMON_HLSL_

struct PSIn
{
	float4 SvPosition	: SV_Position;
	float2 UV			: TEXCOORD0;
};

#endif
