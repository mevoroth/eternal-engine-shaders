#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/PostProcesses/HLSLBloomConstants.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(												0, 0);
CONSTANT_BUFFER(BloomConstants,								BloomConstantBuffer,	1, 0);
REGISTER_T(Texture2D<float3>								ColorTexture,			0, 0);
REGISTER_T(Texture2D<float3>								ColorMip1Texture,		1, 0);
REGISTER_S(SamplerState										BilinearSampler,		0, 0);
RW_RESOURCE(RWTexture2D, float3, SPIRV_FORMAT_R11FG11FB10F,	OutColor,				0, 0);

#ifndef BLOOM_BLUR_HORIZONTAL
#define BLOOM_BLUR_HORIZONTAL	(0)
#endif

#ifndef BLOOM_BLUR_VERTICAL
#define BLOOM_BLUR_VERTICAL		(0)
#endif

#if BLOOM_BLUR_HORIZONTAL == BLOOM_BLUR_VERTICAL
#error "Define either BLOOM_BLUR_HORIZONTAL or BLOOM_BLUR_VERTICAL not both"
#endif

static const float GaussianWeights[5] = { 0.2270270f, 0.1945945f, 0.1216216f, 0.0540540f, 0.0162162f };

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DispatchThreadID : SV_DispatchThreadID )
{
	if (any(DispatchThreadID.xy >= BloomConstantBuffer.ViewSizeAndInverseSize.xy))
		return;

	float2 UV = (float2(DispatchThreadID.xy) + 0.5f) * BloomConstantBuffer.BloomTexelSize;

#if BLOOM_BLUR_HORIZONTAL
	float2 BlurDirection = float2(BloomConstantBuffer.BloomTexelSize.x, 0.0f);
#endif

#if BLOOM_BLUR_VERTICAL
	float2 BlurDirection = float2(0.0f, BloomConstantBuffer.BloomTexelSize.y);
#endif
	
	float3 Result = ColorTexture.SampleLevel(BilinearSampler, UV, 0.0f) * GaussianWeights[0];
	
	for (int TapIndex = 1; TapIndex < 5; ++TapIndex)
	{
		float2 Offset = BlurDirection * float(TapIndex);
		Result += ColorTexture.SampleLevel(BilinearSampler, UV + Offset, 0.0f) * GaussianWeights[TapIndex];
		Result += ColorTexture.SampleLevel(BilinearSampler, UV - Offset, 0.0f) * GaussianWeights[TapIndex];
	}

#if BLOOM_BLUR_VERTICAL
	Result += ColorMip1Texture.SampleLevel(BilinearSampler, UV, 0.0f);
#endif

	OutColor[DispatchThreadID.xy] = Result;
}
