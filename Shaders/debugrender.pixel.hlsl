#include "postprocess.common.hlsl"

struct ShaderPixelOut
{
	float4 FinalColor	: SV_Target0;
};

Texture2D TestTexture: register(t0);
SamplerState TestSampler: register(s0);

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT;

	//OUT.FinalColor = float4(1.0f, 1.0f, 0.0f, 1.0f);
	OUT.FinalColor = TestTexture.Sample(TestSampler, IN.UV);

	return OUT;
}
