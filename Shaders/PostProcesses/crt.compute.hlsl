#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/PostProcesses/HLSLCRTConstants.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(												0, 0);
CONSTANT_BUFFER(CRTConstants,								CRTConstantBuffer,		1, 0);
REGISTER_T(Texture2D<float3>								ColorTexture,			0, 0);
REGISTER_S(SamplerState										BilinearSampler,		0, 0);
RW_RESOURCE(RWTexture2D, float3, SPIRV_FORMAT_R11FG11FB10F,	OutColor,				0, 0);

float2 CRTCurveUV(float2 InUV)
{
    InUV = InUV * 2.0f - 1.0f;
    float2 Offset = abs( InUV.yx ) / float2(6.0f, 4.0f);
    InUV = InUV + InUV * Offset * Offset;
    InUV = InUV * 0.5f + 0.5f;
    return InUV;
}

float GetVignette(float2 InUV)
{
	float Vignette = InUV.x * InUV.y * (1.0f - InUV.x) * (1.0 - InUV.y);
	Vignette = clamp(pow(16.0f * Vignette, 0.3f), 0.0f, 1.0f);
	return Vignette;
}

float GetScanline(float2 InUV)
{
    float Scanline	= clamp(0.95f + 0.05f * cos(PI * (InUV.y + 0.008f * PerViewConstantBuffer.CurrentTime) * 240.0f), 0.0f, 1.0f);
    float Grid 		= 0.85f + 0.15f * clamp(1.5f * cos(PI * InUV.x * 640.0f), 0.0f, 1.0f);    
    return Scanline * Grid;
}

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DispatchThreadID : SV_DispatchThreadID )
{
	if (any((int2)DispatchThreadID.xy >= PerViewConstantBuffer.ViewSizeAndInverseSize.xy))
		return;

	float2 UV = ((float2)DispatchThreadID.xy + 0.5f) * PerViewConstantBuffer.ViewSizeAndInverseSize.zw;
	float2 DistortedUV = CRTCurveUV(UV);
	
	float3 Color = ColorTexture.SampleLevel(BilinearSampler, DistortedUV, 0).rgb;
	
	Color = (any(DistortedUV < 0.0f) || any(DistortedUV > 1.0f)) ? (float3)0.0f : Color;
	
	Color *= GetVignette(DistortedUV);
	Color *= GetScanline(DistortedUV);

	OutColor[DispatchThreadID.xy] = Color;
}
