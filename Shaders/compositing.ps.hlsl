#include "compositing.common.hlsl"
#include "postprocess.common.hlsl"

float4 PS( PSIn IN ) : SV_Target0
{
    return float4(NormalTexture.Sample(BilinearSampler, IN.UV.xy).xyz, 1.f);
    //return float4(DepthTexture.Sample(BilinearSampler, IN.UV.xy).xxx, 1.f);
    //return float4(IN.UV, 0.f, 1.f);
}
