#ifndef _HLSL_ATMOSPHERE_CONSTANTS_HPP_
#define _HLSL_ATMOSPHERE_CONSTANTS_HPP_

#define VOLUMETRIC_PHASE_COUNT	(2)

HLSL_BEGIN_STRUCT(AtmosphereConstants)
	HLSL_ARRAY_VEC1(float, AtmospherePhaseG, VOLUMETRIC_PHASE_COUNT);
	float3 AtmosphereDirectionalLightDirection;
	float AtmospherePhaseBlend;
	float3 AtmosphereDirectionalLightIlluminance;
HLSL_END_STRUCT(AtmosphereConstants)

#endif
