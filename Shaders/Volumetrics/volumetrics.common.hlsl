#ifndef _VOLUMETRICS_COMMON_HLSL_
#define _VOLUMETRICS_COMMON_HLSL_

#include "common.hlsl"

float HenyeyGreensteinPhase(float G, float CosTheta)
{
	//	 1				   1 - G²
	//	----	-----------------------------
	//	4*PI	(1 + G² + 2*G*CosTheta)^(3/2)
	
	float GSquared = G * G;
	return (1.0f - GSquared) / (pow(abs(1.0f + GSquared - 2 * G * CosTheta), 3.0f / 2.0f) * 4.0f * PI);
}

float RayleighPhase(float CosTheta)
{
	//	 1		3
	//	----	-	(1 + CosTheta²)
	//	4*PI	4
	
	float CosThetaSquared = CosTheta * CosTheta;
	float Constant = (3.0f / (16.0f * PI));
	return Constant * CosThetaSquared + Constant;
}

float3 EvaluateScattering(ParticipatingMediaDescription ParticipatingMedia, DiffusionDescription Diffusion)
{
	float3 Scattering = (float3)0.0f;
	for (int ScatteringType = 0; ScatteringType < SCATTERING_TYPE_COUNT; ++ScatteringType)
		Scattering += ParticipatingMedia.Scattering[ScatteringType] * Diffusion.Phase[ScatteringType];
	return Scattering;
}

IntegrateScatteringResult InitializeIntegrateScatteringResult()
{
	IntegrateScatteringResult Result;
	
	Result.Luminance		= (float3)0.0f;
	Result.Transmittance	= (float3)1.0f;
	
	return Result;
}

IntegrateScatteringResult IntegrateScattering(IntegrateScatteringParameters IntegrateParameters)
{
	IntegrateScatteringResult Result = InitializeIntegrateScatteringResult();
	
	int IntegrateStepCount					= 16;
	float IntegrateStepCountRcp				= rcp((float)IntegrateStepCount);
	float IntegrateRangeMin					= 0.0f;
	float IntegrateRangeMax					= 1.0f;
	float3 IntegratePositionWS				= float3(0.0f, 0.0f, 0.0f);
	float3 IntegrateDirection				= float3(0.0f, 1.0f, 0.0f);
	float IntegrateStepDeltaMeters			= (IntegrateRangeMax - IntegrateRangeMin);
	float3 IntegrateLightIlluminance		= (float3) 1000.0f;
	DiffusionDescription IntegrateDiffusion	= IntegrateParameters.IntegrateDiffusion;
	
	for (int Step = 0; Step < IntegrateStepCount; ++Step)
	{
		ParticipatingMediaDescription ParticipatingMedia = SampleParticipatingMedia(IntegratePositionWS);
		
		float3 DeltaExtinction		= ParticipatingMedia.Extinction * IntegrateStepDeltaMeters;
		float3 DeltaTransmittance	= exp(-DeltaExtinction);
		float3 DeltaIlluminance = IntegrateLightIlluminance * EvaluateScattering(ParticipatingMedia, IntegrateDiffusion);
		
		float3 DeltaScattering		= (DeltaIlluminance - DeltaIlluminance * DeltaTransmittance) / ParticipatingMedia.Extinction;
		
		Result.Luminance			+= Result.Transmittance * DeltaScattering;
		Result.Transmittance		*= DeltaTransmittance;
		
		IntegratePositionWS += IntegrateDirection * IntegrateStepDeltaMeters;
	}
	
	return Result;
}

#endif
