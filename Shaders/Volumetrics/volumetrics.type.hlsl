#ifndef _VOLUMETRICS_TYPE_HLSL_
#define _VOLUMETRICS_TYPE_HLSL_

#define SCATTERING_TYPE_MIE			(0)
#define SCATTERING_TYPE_RAYLEIGH	(1)
#define SCATTERING_TYPE_COUNT		(2)

struct DiffusionDescription
{
	float Phase[SCATTERING_TYPE_COUNT];
};

struct ParticipatingMediaDescription
{
	float3 Scattering[SCATTERING_TYPE_COUNT];
	float3 Extinction;
};

struct IntegrateScatteringResult
{
	float3 Luminance;
	float3 Extinction;
	float3 Transmittance;
};

struct IntegrateScatteringParameters
{
	DiffusionDescription IntegrateDiffusion;
	float3 IntegratePositionWS;
	float3 IntegrateDirection;
	int IntegrateStepCount;
	float IntegrateStepCountRcp;
	float IntegrateRangeMin;
	float IntegrateRangeMax;
	float3 IntegrateLightIlluminance;
};

#endif
