#include "debugraytracing.common.hlsl"

[shader("anyhit")]
void ShaderAnyHit(inout RayPayload InOutPayload, in BuiltInTriangleIntersectionAttributes Attributes)
{
	float3 Barycentrics = float3(1 - Attributes.barycentrics.x - Attributes.barycentrics.y, Attributes.barycentrics.x, Attributes.barycentrics.y);
	InOutPayload.Color = float4(Barycentrics, 1);
}
