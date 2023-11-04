#include "raytracedreflections.common.hlsl"

[shader("miss")]
void ShaderMiss(inout RayPayload InOutPayload)
{
	InOutPayload.Luminance = float4(0, 0, 0, 1);
}
