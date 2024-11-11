#include "object.common.hlsl"

REGISTER_T(TextureCube<float3>						SkyTexture,					0, 0);
REGISTER_S(SamplerState								BilinearSampler,			0, 0);

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0;

	float3 Normals	= IN.Normal * 2.0f - 1.0f;
	OUT.Emissive	= SkyTexture.Sample(BilinearSampler, Normals);

	return OUT;
}
