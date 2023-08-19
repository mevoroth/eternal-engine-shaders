#include "debugraytracing.common.hlsl"

[shader("miss")]
void ShaderMiss(inout RayPayload InOutPayload)
{
	InOutPayload.Color = float4(0, 0, 0, 1);
}
