#include "object.common.hlsl"

CONSTANT_BUFFER(PerDrawConstants, PerDrawConstantBuffer,					0, 0);
CONSTANT_BUFFER(PerDrawInstanceConstants, PerDrawInstanceConstantBuffer,	1, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(										2, 0);
REGISTER_T_PER_INSTANCE_STRUCTURED_BUFFER(									0, 0);

ShaderPixelIn ShaderVertex( ShaderVertexIn IN )
{
	ShaderPixelIn OUT = ComputeShaderPixelIn(
		IN,
		PerDrawConstantBuffer,
		PerViewConstantBuffer,
		PerInstanceStructuredBuffer[PerDrawInstanceConstantBuffer.InstanceStart + IN.InstanceIndex]
	);

	return OUT;
}
