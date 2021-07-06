#include "platform.common.hlsl"
#include "postprocess.common.hlsl"

struct FrameConstants
{
	float Multiplier;
	float Offset;
	float _Pad1;
	float _Pad2;
};

REGISTER_B(ConstantBuffer<FrameConstants> FrameConstantsBuffer,		0, 0);
REGISTER_T(Texture2D<float4>	Texture,							0, 0);
REGISTER_T(Texture2D<float4>	Texture2,							1, 0);
REGISTER_S(SamplerState			Sampler,							0, 0);

float4 PS( PSIn IN ) : SV_Target0
{
	//return float4(IN.UV, 0.0f, 1.0f);
	float4 TextureValue = Texture.Sample(Sampler, IN.UV);
	float4 TextureValue2 = Texture2.Sample(Sampler, IN.UV);
	TextureValue.rgb = TextureValue.rgb * FrameConstantsBuffer.Multiplier + FrameConstantsBuffer.Offset + TextureValue2;
	return TextureValue;
}
