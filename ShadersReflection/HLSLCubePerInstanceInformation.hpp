#ifndef _HLSL_CUBE_PER_INSTANCE_INFORMATION_HPP_
#define _HLSL_CUBE_PER_INSTANCE_INFORMATION_HPP_

HLSL_BEGIN_STRUCT(CubePerInstanceInformation)
	float4x4 InstanceWorldToWorld;
	float3 CubeOrigin;
	float _Pad0;
	float3 CubeExtent;
	float _Pad1;
	float4 _Pad2;
	float4 _Pad3;
HLSL_END_STRUCT(CubePerInstanceInformation)

#endif
