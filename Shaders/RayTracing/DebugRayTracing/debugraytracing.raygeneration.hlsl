#include "debugraytracing.common.hlsl"

[shader("raygeneration")]
void ShaderRayGeneration()
{
	float2 LerpValues = (float2)DispatchRaysIndex() / (float2)DispatchRaysDimensions();

	// Orthographic projection since we're raytracing in screen space.
	float3 RayDirection = float3(0, 0, 1);
	float3 RayOrigin = float3(
		lerp(RayGenerationConstantBuffer.Viewport.Left, RayGenerationConstantBuffer.Viewport.Right, LerpValues.x),
		lerp(RayGenerationConstantBuffer.Viewport.Top, RayGenerationConstantBuffer.Viewport.Bottom, LerpValues.y),
		0.0f);

	if (IsInsideViewport(RayOrigin.xy, RayGenerationConstantBuffer.Stencil))
	{
		// Trace the ray.
		// Set the ray's extents.
		RayDesc Ray;
		Ray.Origin = RayOrigin;
		Ray.Direction = RayDirection;
		// Set TMin to a non-zero small value to avoid aliasing issues due to floating - point errors.
		// TMin should be kept small to prevent missing geometry at close contact areas.
		Ray.TMin = 0.001;
		Ray.TMax = 10000.0;
		RayPayload Payload = { float4(0, 0, 0, 0) };
		TraceRay(Scene, RAY_FLAG_CULL_BACK_FACING_TRIANGLES, ~0, 0, 1, 0, Ray, Payload);

		// Write the raytraced color to the output texture.
		OutRenderTarget[DispatchRaysIndex().xy] = Payload.Color;
	}
	else
	{
		// Render interpolated DispatchRaysIndex outside the stencil window
		OutRenderTarget[DispatchRaysIndex().xy] = float4(LerpValues, 0, 1);
	}
}
