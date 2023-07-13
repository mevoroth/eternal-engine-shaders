#include "compositing.common.hlsl"
#include "postprocess.common.hlsl"

float4 ShaderPixel( ShaderPixelIn IN ) : SV_Target0
{
	float2 ScreenUV = IN.UV.xy;
	ScreenUV.y = ScreenUV.y;

	return float4(LightingTexture.Sample(BilinearSampler, ScreenUV).xyz, 1.f);
	//return float4(DepthTexture.Sample(BilinearSampler, IN.UV.xy).xxx, 1.f);
	//return float4(NormalTexture.Sample(BilinearSampler, IN.UV.xy).xyz, 1.f);
	//return float4(IN.UV, 0.f, 1.f);
}
