#include "object.common.hlsl"

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0;
	OUT.Emissive = IN.Color.rgb;
	return OUT;
}
