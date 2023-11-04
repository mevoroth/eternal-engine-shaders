#include "raytracedreflections.common.hlsl"

[shader("closesthit")]
void ShaderClosestHit(inout RayPayload InOutPayload, in BuiltInTriangleIntersectionAttributes Attributes)
{
	float3 Barycentrics = float3(1 - Attributes.barycentrics.x - Attributes.barycentrics.y, Attributes.barycentrics.x, Attributes.barycentrics.y);
	//InOutPayload.Luminance = float4(Barycentrics, 1);
	InOutPayload.Luminance = float4(1, 0, 0, 1);

}
