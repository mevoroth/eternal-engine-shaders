#include "imgui.common.hlsl"

REGISTER_S(SamplerState ImguiSampler,	0, 0);
REGISTER_T(Texture2D ImguiTexture,		0, 0);

float4 PS( PSIn IN ) : SV_Target
{
	float4 OUT = IN.Color * ImguiTexture.Sample(ImguiSampler, IN.UV);
	return OUT;
}
