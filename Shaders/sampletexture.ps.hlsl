#include "postprocess.common.hlsl"

Texture2D<float4>	Texture : register(t0);
SamplerState		Sampler : register(s0);

struct FrameConstants
{
	float Multiplier;
	float Offset;
	float _Pad1;
	float _Pad2;
};
ConstantBuffer<FrameConstants> FrameConstantsBuffer : register(b0);

float4 PS( PSIn IN ) : SV_Target0
{
	//return float4(IN.UV, 0.0f, 1.0f);
	float4 TextureValue = Texture.Sample(Sampler, IN.UV);
	TextureValue.rgb = TextureValue.rgb * FrameConstantsBuffer.Multiplier + FrameConstantsBuffer.Offset;
	return TextureValue;
}
