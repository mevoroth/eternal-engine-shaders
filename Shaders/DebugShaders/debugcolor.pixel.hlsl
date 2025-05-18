#include "object.common.hlsl"

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0;
	OUT.Emissive = float4(1, 0, 0, 1);
	return OUT;
}
