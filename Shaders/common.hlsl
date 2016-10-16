#ifndef _COMMON_HLSL_
#define _COMMON_HLSL_

cbuffer FrameConstants : register(b0)
{
	float4x4 ViewProjection;
	float4x4 ViewProjectionInversed;
	float4 CameraPosition;
};

#endif
