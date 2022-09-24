#ifndef _HLSL_PER_VIEW_CONSTANTS_HPP_
#define _HLSL_PER_VIEW_CONSTANTS_HPP_

HLSL_BEGIN_STRUCT(PerViewConstants)
	float4x4 WorldToClip;
	float4x4 ClipToWorld;
	float4x4 WorldToView;
	float4x4 ViewToWorld;
	float4x4 ViewToClip;
	float4x4 ClipToView;
	float4 ViewPosition;
	float4 ViewForward;
	float4 ScreenSizeAndInverseSize;
	float RenderNearPlane;
	float RenderFarPlane;
	float _Pad0;
	float _Pad1;
HLSL_END_STRUCT(PerViewConstants)

#endif
