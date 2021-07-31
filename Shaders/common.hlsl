#ifndef _COMMON_HLSL_
#define _COMMON_HLSL_

struct PerViewConstants
{
	float4x4 WorldToClip;
	float4x4 ClipToWorld;
	float4x4 WorldToView;
	float4x4 ViewToWorld;
	float4x4 ViewToClip;
	float4x4 ClipToView;
};

#define REGISTER_B_PER_VIEW_CONSTANT_BUFFER(Index, Set)		REGISTER_B(ConstantBuffer<PerViewConstants> PerViewConstantBuffer, Index, Set)

#endif
