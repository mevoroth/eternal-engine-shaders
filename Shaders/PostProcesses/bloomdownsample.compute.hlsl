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
	if (any((int2) DispatchThreadID.xy >= BloomConstantBuffer.ViewSizeAndInverseSize.xy))
		return;

	float2 UV = ((float2) DispatchThreadID.xy + 0.5f) * BloomConstantBuffer.ViewSizeAndInverseSize.zw;

	float2 HalfTexel = BloomConstantBuffer.BloomTexelSize * 0.5f;
	float2 FullTexel = BloomConstantBuffer.BloomTexelSize;

	float2 Offsets[13] =
	{
		float2(        0.0f,         0.0f),
		float2(-HalfTexel.x,  HalfTexel.y),
		float2( HalfTexel.x,  HalfTexel.y),
		float2(-HalfTexel.x, -HalfTexel.y),
		float2( HalfTexel.x, -HalfTexel.y),
		float2(-FullTexel.x,  0.0f       ),
		float2( FullTexel.x,  0.0f       ),
		float2( 0.0f,        -FullTexel.y),
		float2( 0.0f,         FullTexel.y),
		float2(-FullTexel.x, -FullTexel.y),
		float2( FullTexel.x, -FullTexel.y),
		float2(-FullTexel.x,  FullTexel.y),
		float2( FullTexel.x,  FullTexel.y)
	};
	
	float Weights[13] =
	{
		4.0f,
		1.0f,
		1.0f,
		1.0f,
		1.0f,
		0.5f,
		0.5f,
		0.5f,
		0.5f,
		0.25f,
		0.25f,
		0.25f,
		0.25f
	};
	
	float3 Result = 0.0f;
	float WeightsSum = 0.0f;
	
	for (int OffsetIndex = 0; OffsetIndex < 13; ++OffsetIndex)
	{
		Result += ColorTexture.SampleLevel(BilinearSampler, UV + Offsets[OffsetIndex], 0.0f).rgb * Weights[OffsetIndex];
		WeightsSum += Weights[OffsetIndex];
	}
	
	Result /= WeightsSum;
	
	float3 ResultLuminance = ColorToLuminance(Result);
	float BloomWeight = max(ResultLuminance - BloomConstantBuffer.BloomThreshold, 0.0f) / max(ResultLuminance, EPSILON);
	ResultLuminance *= BloomWeight;
	
	OutColor[DispatchThreadID.xy] = ResultLuminance;
}
