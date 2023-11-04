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

static const float3 EarthRayleighScattering	= float3(5.8e-6f, 13.6e-6f, 33.1e-6f) * KM_TO_M;
static const float3 EarthMieScattering		= (float3)(2.0e-6f  * KM_TO_M);

struct ShaderPixelOut
{
	float4 OutLuminance : SV_Target0;
};

float3 GetRayOrigin( ShaderPixelIn IN )
{
#if USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP
	uint CubeMapFace				= IN.RenderTargetArrayIndex;
	PerViewConstants CurrentView	= PerViewCubeMapConstantBuffer.PerViewFace[CubeMapFace];
#else // USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_NONE
	PerViewConstants CurrentView	= PerViewConstantBuffer;
#endif
	return CurrentView.ViewPosition.xyz;
}

float3 GetRayDirection( ShaderPixelIn IN )
{
#if USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_CUBEMAP
	uint CubeMapFace				= IN.RenderTargetArrayIndex;
	PerViewConstants CurrentView	= PerViewCubeMapConstantBuffer.PerViewFace[CubeMapFace];
#else // USE_MULTIPLE_LAYER_RENDER_TARGETS == MULTIPLE_LAYER_RENDER_TARGETS_NONE
	PerViewConstants CurrentView	= PerViewConstantBuffer;
#endif
	
	return GetRayDirection(IN.UV, CurrentView);
}

#include "Volumetrics/volumetrics.type.hlsl"
ParticipatingMediaDescription SampleParticipatingMedia(float3 PositionWS)
{
	float DistanceFromEarthCenter	= length(PositionWS);
	float HeightDelta				= max(DistanceFromEarthCenter - EARTH_RADIUS_KM, 0.0f);
	
	ParticipatingMediaDescription ParticipatingMedia = (ParticipatingMediaDescription)0;
	
	ParticipatingMedia.Scattering[SCATTERING_TYPE_MIE]		= EarthMieScattering * exp(-HeightDelta * (1.0f / 1.2f));
	ParticipatingMedia.Scattering[SCATTERING_TYPE_RAYLEIGH]	= EarthRayleighScattering * exp(-HeightDelta * (1.0f / 8.0f));
	ParticipatingMedia.Extinction							= 0.01f;
	
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

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0.0f;
	
	const float3 RayOriginKm	= GetRayOrigin(IN) * M_TO_KM;
	const float3 RayDirection	= GetRayDirection(IN);
	const float3 LightDirection	= AtmosphereConstantBuffer.AtmosphereDirectionalLightDirection;
	const float LdotV			= dot(LightDirection, RayDirection);
	
	float2 AtmosphereIntersection;
	SphereDescription AtmosphereSphere = InitializeSphereDescription(EARTH_RADIUS_KM_SQUARED);
	RaySphereIntersection(RayOriginKm + float3(0.0f, 0.0f, EARTH_RADIUS_KM), RayDirection, AtmosphereSphere, AtmosphereIntersection);
	const float AtmosphereOuterDistance = max(AtmosphereIntersection.x, AtmosphereIntersection.y);
	
	IntegrateScatteringParameters Parameters;
	Parameters.IntegrateDiffusion			= InitializeDiffusionDescription(AtmosphereConstantBuffer.AtmospherePhaseG[0].Value, LdotV);
	Parameters.IntegratePositionWS			= RayOriginKm + RayDirection * AtmosphereOuterDistance;
	Parameters.IntegrateDirection			= RayDirection;
	Parameters.IntegrateStepCount			= 16;
	Parameters.IntegrateStepCountRcp		= rcp(Parameters.IntegrateStepCount);
	Parameters.IntegrateRangeMin			= EARTH_RADIUS_KM;
	Parameters.IntegrateRangeMax			= ATMOSPHERE_RADIUS_KM;
	Parameters.IntegrateLightIlluminance	= AtmosphereConstantBuffer.AtmosphereDirectionalLightIlluminance;
	
	IntegrateScatteringResult Result = IntegrateScattering(Parameters);
	OUT.OutLuminance = float4(Result.Luminance, 1.0f);
	
	return OUT;
}
