#include "postprocess.common.hlsl"

Buffer<float4> Test : register(t0);

float4 PS( PSIn IN ) : SV_Target0
{
	float2 ScreenUV = IN.UV.xy;

	return Test[(int)(IN.UV.x * 1024)];
	//return float4(ScreenUV.xy, 0.f, 1.f);
}
