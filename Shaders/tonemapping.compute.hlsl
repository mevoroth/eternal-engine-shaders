#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(		0, 0);
REGISTER_U(RWTexture2D<float4>	OutColor,	0, 0);

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DTid : SV_DispatchThreadID )
{
	if (any((int2)DTid.xy >= PerViewConstantBuffer.ViewSizeAndInverseSize.xy))
		return;

	float4 Color = OutColor[DTid.xy];
	OutColor[DTid.xy] = Color / (Color + 1);
}
