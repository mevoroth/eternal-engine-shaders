#ifndef _HLSL_VOLUMETRIC_CLOUDS_HPP_
#define _HLSL_VOLUMETRIC_CLOUDS_HPP_

#define VOLUMETRIC_PHASE_COUNT	(2)

HLSL_BEGIN_STRUCT(VolumetricCloudsConstants)
	HLSL_ARRAY_VEC1(float, PhaseG, VOLUMETRIC_PHASE_COUNT);

	float BottomLayerRadiusMeters;
	float TopLayerRadiusMeters;
	float BottomLayerRadiusMetersSquared;
	float TopLayerRadiusMetersSquared;

	float PhaseBlend;
	float MaxStepsRcp;
	int MaxSteps;
	int _Pad0;
HLSL_END_STRUCT(VolumetricCloudsConstants)

#endif
