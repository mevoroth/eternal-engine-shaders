#include "object.common.hlsl"

CONSTANT_BUFFER(PerDrawConstants,	PerDrawConstantBuffer,					0, 0);
CONSTANT_BUFFER(PerDrawInstanceConstants, PerDrawInstanceConstantBuffer,	1, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(										2, 0);
REGISTER_T(StructuredBuffer<ShaderVertexIn>	Vertices,								0, 0);
REGISTER_T(StructuredBuffer<uint3>	Indices,								1, 0);
REGISTER_T_PER_INSTANCE_STRUCTURED_BUFFER(									2, 0);

[numthreads(128, 1, 1)]
[outputtopology("triangle")]
void MS(
	uint3 DTid : SV_DispatchThreadID,
	out vertices ShaderPixelIn OutVertices[256],
	out indices uint3 OutIndices[256]
)
{
	const uint PrimitiveIndex	= DTid.x;
	const uint VerticesCount	= PerDrawConstantBuffer.VerticesCount;
	const uint PrimitivesCount	= PerDrawConstantBuffer.PrimitivesCount;

	SetMeshOutputCounts(VerticesCount, PrimitivesCount);

	if (PrimitiveIndex < VerticesCount)
	{
		ShaderPixelIn OUT = ComputeShaderPixelIn(
			Vertices[PrimitiveIndex],
			PerDrawConstantBuffer,
			PerViewConstantBuffer,
			PerInstanceStructuredBuffer[PerDrawInstanceConstantBuffer.InstanceStart + 0]
		);

		OutVertices[PrimitiveIndex] = OUT;
	}

	if (PrimitiveIndex < PrimitivesCount)
	{
		OutIndices[PrimitiveIndex] = Indices[PrimitiveIndex];
	}
}
