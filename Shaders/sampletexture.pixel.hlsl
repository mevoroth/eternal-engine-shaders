#include "screen.common.hlsl"

REGISTER_T(Texture2D<float4>	Texture,							0, 0);
REGISTER_S(SamplerState			Sampler,							0, 0);

float4 ShaderPixel( ShaderPixelIn IN ) : SV_Target0
{
	return Texture.Sample(Sampler, IN.UV);
}
