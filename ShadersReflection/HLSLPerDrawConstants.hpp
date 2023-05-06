#ifndef _HLSL_PER_DRAW_CONSTANTS_HPP_
#define _HLSL_PER_DRAW_CONSTANTS_HPP_

HLSL_BEGIN_STRUCT(PerDrawConstants)
	float4x4 SubMeshToWorld;
	uint VerticesCount;
	uint PrimitivesCount;
	uint _Pad0;
	uint _Pad1;

	uint4 _Pad2;
	uint4 _Pad3;
	uint4 _Pad4;
HLSL_END_STRUCT(PerDrawConstants)

HLSL_BEGIN_STRUCT(PerDrawInstanceConstants)
	uint InstanceStart;
	uint _Pad0;
	uint _Pad1;
	uint _Pad2;
HLSL_END_STRUCT(PerDrawInstanceConstants)

#endif
