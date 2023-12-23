#include "vertexcolor.common.hlsl"

ShaderPixelIn ShaderVertex( ShaderVertexIn IN )
{
	ShaderPixelIn OUT = (ShaderPixelIn)0;

	OUT.Pos = IN.Pos;
	OUT.Col = IN.Col;

	return OUT;
}
