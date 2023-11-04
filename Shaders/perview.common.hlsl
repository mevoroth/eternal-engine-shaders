#ifndef _PER_VIEW_COMMON_HLSL_
#define _PER_VIEW_COMMON_HLSL_

#include "ShadersReflection/HLSLPerViewConstants.hpp"
#include "functions.common.hlsl"

#define REGISTER_B_PER_VIEW_CONSTANT_BUFFER(Index, Set)		CONSTANT_BUFFER(PerViewConstants, PerViewConstantBuffer, Index, Set)

float3 GetRayDirection(float2 UV, PerViewConstants PerViewConstantBuffer)
{
	const float3 RayOrigin		= PerViewConstantBuffer.ViewPosition.xyz;
	const float3 RayDirection	= normalize(UVDepthToWorldPosition(
		UV,
		PerViewConstantBuffer.ViewRenderFarPlane,
		PerViewConstantBuffer.ClipToWorld
	) - RayOrigin);
	
	return RayDirection;
}

#endif
