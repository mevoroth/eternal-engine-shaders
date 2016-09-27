#ifndef _COMMON_HLSL_
#define _COMMON_HLSL_

cbuffer FrameConstants : register(b0)
{
	matrix ViewProjection;
    matrix ViewProjectionInversed;
};

#endif
