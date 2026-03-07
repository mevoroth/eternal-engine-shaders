#include "common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/PostProcesses/HLSLChromaticAberrationConstants.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(															0, 0);
CONSTANT_BUFFER(ChromaticAberrationConstants,				ChromaticAberrationConstantBuffer,	1, 0);
REGISTER_T(Texture2D<float3>								ColorTexture,						0, 0);
REGISTER_S(SamplerState										BilinearSampler,					0, 0);
RW_RESOURCE(RWTexture2D, float3, SPIRV_FORMAT_R11FG11FB10F,	OutColor,							0, 0);

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DispatchThreadID : SV_DispatchThreadID )
{
	if (any((int2)DispatchThreadID.xy >= PerViewConstantBuffer.ViewSizeAndInverseSize.xy))
		return;

	float2 UV = (float2)DispatchThreadID.xy * PerViewConstantBuffer.ViewSizeAndInverseSize.zw;

	float3 AccumulatedColor = (float3)0.0f;
	for (uint OctaveIndex = 0; OctaveIndex < ChromaticAberrationConstantBuffer.ChromaticAberrationOctavesCount; ++OctaveIndex)
	{
		float3 OctaveColor = ColorTexture.SampleLevel(BilinearSampler, UV + ChromaticAberrationConstantBuffer.ChromaticAberrationOctaves[OctaveIndex].OctaveDirection, 0).rgb;
		OctaveColor *= ChromaticAberrationConstantBuffer.ChromaticAberrationOctaves[OctaveIndex].OctaveMask;
		AccumulatedColor += OctaveColor;
	}

	OutColor[DispatchThreadID.xy] = AccumulatedColor;
}
