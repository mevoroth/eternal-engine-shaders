#include "postprocess.common.hlsl"

//Buffer<float4> Test : register(t0);

float4 PS( PSIn IN ) : SV_Target0
{
	return float4(1.0f, 0.0f, 0.0f, 1.0f);
	//float2 ScreenUV = IN.UV.xy;

	//return Test[(int)(IN.UV.x * 1024)];
	//return float4(ScreenUV.xy, 0.f, 1.f);
}
