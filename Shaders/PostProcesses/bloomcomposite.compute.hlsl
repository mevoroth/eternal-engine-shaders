#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/PostProcesses/HLSLBloomConstants.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(												0, 0);
CONSTANT_BUFFER(BloomConstants,								BloomConstantBuffer,	1, 0);
REGISTER_T(Texture2D<float3>								ColorTexture,			0, 0);
REGISTER_S(SamplerState										BilinearSampler,		0, 0);
RW_RESOURCE(RWTexture2D, float3, SPIRV_FORMAT_R11FG11FB10F,	OutColor,				0, 0);

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DispatchThreadID : SV_DispatchThreadID )
{
	if (any(DispatchThreadID.xy >= BloomConstantBuffer.ViewSizeAndInverseSize.xy))
		return;

	float2 UV = (float2(DispatchThreadID.xy) + 0.5f) * BloomConstantBuffer.BloomTexelSize;

	float2 BloomUpsampleRadius = BloomConstantBuffer.BloomTexelSize * BloomConstantBuffer.BloomUpsampleRadius;

	float2 Offsets[9] =
	{
		float2(-BloomUpsampleRadius.x, -BloomUpsampleRadius.y),
		float2(                  0.0f, -BloomUpsampleRadius.y),
		float2( BloomUpsampleRadius.x, -BloomUpsampleRadius.y),
		float2(-BloomUpsampleRadius.x,                   0.0f),
		float2(                  0.0f,                   0.0f),
		float2( BloomUpsampleRadius.x,                   0.0f),
		float2(-BloomUpsampleRadius.x,  BloomUpsampleRadius.y),
		float2(                  0.0f,  BloomUpsampleRadius.y),
		float2( BloomUpsampleRadius.x,  BloomUpsampleRadius.y),
	};

	float Weights[9] =
	{
		1.0f,
		2.0f,
		1.0f,
		2.0f,
		4.0f,
		2.0f,
		1.0f,
		2.0f,
		1.0f
	};

	float3 BloomResult = (float3)0.0f;
	float WeightsSum = 0.0f;
	
	for (int OffsetIndex = 0; OffsetIndex < 9; ++OffsetIndex)
	{
		BloomResult += ColorTexture.SampleLevel(BilinearSampler, UV + Offsets[OffsetIndex], 0.0f).rgb * Weights[OffsetIndex];
		WeightsSum += Weights[OffsetIndex];
	}

	BloomResult /= WeightsSum;

	BloomResult = ColorDesaturate(BloomResult, BloomConstantBuffer.BloomSaturation);
	BloomResult *= BloomConstantBuffer.BloomIntensity;
	
	float3 Color = OutColor[DispatchThreadID.xy];
	Color += BloomResult;
	OutColor[DispatchThreadID.xy] = Color;
}
