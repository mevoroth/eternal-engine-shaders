#include "object.common.hlsl"

REGISTER_B(ConstantBuffer<PerDrawConstants>	PerDrawConstantBuffer,	0, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(								1, 0);
REGISTER_T(StructuredBuffer<VSIn>	Vertices,						0, 0);
REGISTER_T(StructuredBuffer<uint3>	Indices,						1, 0);

[numthreads(128, 1, 1)]
[outputtopology("triangle")]
void MS(
	uint3 DTid : SV_DispatchThreadID,
	out vertices PSIn OutVertices[256],
	out indices uint3 OutIndices[256]
)
{
	const uint PrimitiveIndex	= DTid.x;
	const uint VerticesCount	= PerDrawConstantBuffer.VerticesCount;
	const uint PrimitivesCount	= PerDrawConstantBuffer.PrimitivesCount;

	SetMeshOutputCounts(VerticesCount, PrimitivesCount);

	if (PrimitiveIndex < VerticesCount)
	{
		PSIn OUT = ComputePSIn(Vertices[PrimitiveIndex], PerDrawConstantBuffer, PerViewConstantBuffer);

		OutVertices[PrimitiveIndex] = OUT;
	}

	if (PrimitiveIndex < PrimitivesCount)
	{
		OutIndices[PrimitiveIndex] = Indices[PrimitiveIndex];
	}
}
