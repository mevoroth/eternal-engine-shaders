#include "vertexcolor.common.hlsl"

ShaderPixelIn ShaderVertex( VSIn IN )
{
	ShaderPixelIn OUT = (ShaderPixelIn) 0;

	OUT.Pos = mul(IN.Pos, ViewProjection);
	OUT.Col = IN.Col;

	return OUT;
}
