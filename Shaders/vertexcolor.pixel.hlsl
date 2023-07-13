#include "vertexcolor.common.hlsl"

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0;

	OUT.Diffuse	= IN.Col;
	OUT.Depth	= IN.Pos.z;

	return OUT;
}
