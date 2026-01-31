#include "Imgui/imgui.common.hlsl"

CONSTANT_BUFFER(ProjectionConstants, ProjectionConstantBuffer,	0, 0);

ShaderPixelIn ShaderVertex( ShaderVertexIn IN )
{
	ShaderPixelIn OUT = (ShaderPixelIn)0;
	OUT.SVPosition	= mul(ProjectionConstantBuffer.ProjectionMatrix, float4(IN.Position.xy, 0.0f, 1.0f));
	OUT.Color		= IN.Color;
	OUT.UV			= IN.UV;
	return OUT;
}
