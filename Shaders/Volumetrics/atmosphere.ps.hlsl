#include "platform.common.hlsl"
#include "common.hlsl"
#include "screen.common.hlsl"
#include "perview.common.hlsl"
#include "ShadersReflection/HLSLAtmosphereConstants.hpp"

CONSTANT_BUFFER(AtmosphereConstants, AtmosphereConstantBuffer,			0, 0);
#if USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP
CONSTANT_BUFFER(PerViewCubeMapConstants, PerViewCubeMapConstantBuffer,	1, 0);
#else // USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_NONE
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(									1, 0);
#endif

struct PSOut
{
	float4 OutLuminance : SV_Target0;
};

float3 GetRayDirection( PSIn IN )
{
#if USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP
	uint CubeMapFace			= IN.RenderTargetArrayIndex;
	const float3 RayOrigin		= PerViewCubeMapConstantBuffer.PerViewFace[CubeMapFace].ViewPosition.xyz;
	const float3 RayDirection	= normalize(UVDepthToWorldPosition(
		IN.UV,
		PerViewCubeMapConstantBuffer.PerViewFace[CubeMapFace].ViewRenderFarPlane,
		PerViewCubeMapConstantBuffer.PerViewFace[CubeMapFace].ClipToWorld
	) - RayOrigin);
#else // USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_NONE
	const float3 RayOrigin		= PerViewConstantBuffer.ViewPosition.xyz;
	const float3 RayDirection	= normalize(UVDepthToWorldPosition(
		IN.UV,
		PerViewConstantBuffer.ViewRenderFarPlane,
		PerViewConstantBuffer.ClipToWorld
	) - RayOrigin);
#endif
	return RayDirection;
}

#include "Volumetrics/volumetrics.type.hlsl"
ParticipatingMediaDescription SampleParticipatingMedia(float3 PositionWS)
{
	ParticipatingMediaDescription ParticipatingMedia = (ParticipatingMediaDescription)0;
	
	ParticipatingMedia.Scattering[SCATTERING_TYPE_MIE]		= 0.01f;
	ParticipatingMedia.Scattering[SCATTERING_TYPE_RAYLEIGH]	= 0.01f;
	ParticipatingMedia.Extinction = 0.01f;
	
	return ParticipatingMedia;
}
#include "Volumetrics/volumetrics.common.hlsl"

DiffusionDescription InitializeDiffusionDescription(float G, float CosTheta)
{
	DiffusionDescription Diffusion;
	
	Diffusion.Phase[SCATTERING_TYPE_MIE]		= HenyeyGreensteinPhase(G, CosTheta);
	Diffusion.Phase[SCATTERING_TYPE_RAYLEIGH]	= RayleighPhase(CosTheta);
	
	return Diffusion;
}

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0.0f;
	
//#if USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP
//	switch (IN.RenderTargetArrayIndex)
//	{
//	case 0:
//		OUT.OutLuminance = float4(1, 0, 0, 1);
//		break;
//	case 1:
//		OUT.OutLuminance = float4(0, 1, 0, 1);
//		break;
//	case 2:
//		OUT.OutLuminance = float4(0, 0, 1, 1);
//		break;
//	case 3:
//		OUT.OutLuminance = float4(1, 0, 1, 1);
//		break;
//	case 4:
//		OUT.OutLuminance = float4(1, 1, 0, 1);
//		break;
//	case 5:
//		OUT.OutLuminance = float4(0, 1, 1, 1);
//		break;
//	}
//#endif
	
	const float3 RayDirection	= GetRayDirection(IN);
	const float3 LightDirection	= AtmosphereConstantBuffer.AtmosphereDirectionalLightDirection;
	const float LdotV			= dot(LightDirection, RayDirection);
	
	IntegrateScatteringParameters Parameters;
	Parameters.IntegrateDiffusion			= InitializeDiffusionDescription(AtmosphereConstantBuffer.AtmospherePhaseG[0].Value, LdotV);
	Parameters.IntegratePositionWS			= 0.0f;
	Parameters.IntegrateDirection			= RayDirection;
	Parameters.IntegrateStepCount			= 16;
	Parameters.IntegrateStepCountRcp		= rcp(Parameters.IntegrateStepCount);
	Parameters.IntegrateRangeMin			= 0.0f;
	Parameters.IntegrateRangeMax			= 1.0f;
	Parameters.IntegrateLightIlluminance	= AtmosphereConstantBuffer.AtmosphereDirectionalLightIlluminance;
	
	IntegrateScatteringResult Result = IntegrateScattering(Parameters);
	OUT.OutLuminance = float4(Result.Luminance, 1.0f);
	
	return OUT;
}
