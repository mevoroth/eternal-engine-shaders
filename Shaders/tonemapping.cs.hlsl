#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(		0, 0);
REGISTER_U(RWTexture2D<float4>	OutColor,	0, 0);

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void CS( uint3 DTid : SV_DispatchThreadID )
{
	if (any(DTid.xy >= PerViewConstantBuffer.ScreenSizeAndInverseSize.xy))
		return;

	float4 Color = OutColor[DTid.xy];
	OutColor[DTid.xy] = Color / (Color + 1);
}