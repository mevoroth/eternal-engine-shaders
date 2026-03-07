#ifndef _HLSL_CHROMATIC_ABERRATION_CONSTANTS_HPP_
#define _HLSL_CHROMATIC_ABERRATION_CONSTANTS_HPP_

#define CHROMATIC_ABERRATION_OCTAVES_COUNT	(8)

HLSL_BEGIN_STRUCT(ChromaticAberrationOctave)
	float3 OctaveMask;
	float OctaveStrength;
	float2 OctaveDirection;
	float2 _Pad;
HLSL_END_STRUCT(ChromaticAberrationOctave)

HLSL_BEGIN_STRUCT(ChromaticAberrationConstants)
	ChromaticAberrationOctave ChromaticAberrationOctaves[CHROMATIC_ABERRATION_OCTAVES_COUNT];
	uint ChromaticAberrationOctavesCount;
HLSL_END_STRUCT(ChromaticAberrationConstants)

#endif
