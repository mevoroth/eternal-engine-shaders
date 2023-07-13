#include "object.common.hlsl"

REGISTER_T(Texture2D<float4>						AlbedoTexture,				0, 0);
REGISTER_T(Texture2D<float4>						NormalsTexture,				1, 0);
REGISTER_T(Texture2D<float4>						RoughnessMetallicSpecular,	2, 0);
REGISTER_S(SamplerState								BilinearSampler,			0, 0);

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0;

	float3x3 TangentSpace = float3x3(
		IN.Binormal,
		IN.Normal,
		IN.Tangent
	);
	float3 Normals					= NormalsTexture.Sample(BilinearSampler, IN.UV).xyz;
	Normals							= normalize(Normals) * 2.0f - 1.0f;
	Normals							= mul(TangentSpace, Normals);

	OUT.Emissive					= 0.0f;
	OUT.Albedo						= AlbedoTexture.Sample(BilinearSampler, IN.UV);
	OUT.Normal						= float4(Normals, 1.0f);
	OUT.RoughnessMetallicSpecular	= RoughnessMetallicSpecular.Sample(BilinearSampler, IN.UV).gbaa;

	return OUT;
}
