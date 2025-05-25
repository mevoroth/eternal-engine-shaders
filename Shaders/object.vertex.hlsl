#include "object.common.hlsl"

CONSTANT_BUFFER(PerDrawConstants, PerDrawConstantBuffer,					0, 0);
#if OBJECT_HAS_INSTANCES
CONSTANT_BUFFER(PerDrawInstanceConstants, PerDrawInstanceConstantBuffer,	1, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(										2, 0);
REGISTER_T_PER_INSTANCE_STRUCTURED_BUFFER(									0, 0);
#else
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(										1, 0);
#endif

ShaderPixelIn ShaderVertex( ShaderVertexIn IN )
{
	PerInstanceInformation DefaultPerInstanceInformation = (PerInstanceInformation)0;
	DefaultPerInstanceInformation.InstanceWorldToWorld = float4x4(
		1.0f, 0.0f, 0.0f, 0.0f,
		0.0f, 1.0f, 0.0f, 0.0f,
		0.0f, 0.0f, 1.0f, 0.0f,
		0.0f, 0.0f, 0.0f, 1.0f
	);

	ShaderPixelIn OUT = ComputeShaderPixelIn(
		IN,
		PerDrawConstantBuffer,
		PerViewConstantBuffer,
#if OBJECT_HAS_INSTANCES
		PerInstanceStructuredBuffer[PerDrawInstanceConstantBuffer.InstanceStart + IN.InstanceIndex]
#else
		DefaultPerInstanceInformation
#endif
	);

	return OUT;
}
