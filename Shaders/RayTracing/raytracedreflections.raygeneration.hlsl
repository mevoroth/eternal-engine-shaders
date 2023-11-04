#include "raytracedreflections.common.hlsl"

[shader("raygeneration")]
void ShaderRayGeneration()
{
	float2 ScreenUV = (float2) DispatchRaysIndex() / (float2) DispatchRaysDimensions();
	
	const float Depth				= DepthTexture[DispatchRaysIndex().xy].x;
	const float3 GeometryPosition	= UVDepthToWorldPosition(ScreenUV, Depth, PerViewConstantBuffer.ClipToWorld);
	const float3 GeometryNormals	= NormalsTexture[DispatchRaysIndex().xy].xyz;
	
	RayDesc Ray		= (RayDesc)0;
	Ray.Origin		= GeometryPosition;
	Ray.Direction	= GeometryNormals;
	Ray.TMin		= PerViewConstantBuffer.ViewNearPlane;
	Ray.TMax		= PerViewConstantBuffer.ViewFarPlane;
	
	RayPayload Payload = (RayPayload)0;
	
	TraceRay(Scene, RAY_FLAG_CULL_BACK_FACING_TRIANGLES, ~0, 0, 1, 0, Ray, Payload);
	
	OutLuminance[DispatchRaysIndex().xy] += Payload.Luminance;
}
