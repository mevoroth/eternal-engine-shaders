#include "postprocess.common.hlsl"

float4 PS( PSIn IN ) : SV_Target0
{
	float2 ScreenUV = IN.UV.xy;

	return float4(ScreenUV.xy, 0.f, 1.f);
}
