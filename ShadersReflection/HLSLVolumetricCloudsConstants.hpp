#ifndef _HLSL_VOLUMETRIC_CLOUDS_CONSTANTS_HPP_
#define _HLSL_VOLUMETRIC_CLOUDS_CONSTANTS_HPP_

#define VOLUMETRIC_PHASE_COUNT	(2)

HLSL_BEGIN_STRUCT(VolumetricCloudsConstants)
	HLSL_ARRAY_VEC1(float, CloudsPhaseG, VOLUMETRIC_PHASE_COUNT);

	float CloudsBottomLayerRadiusMeters;
	float CloudsTopLayerRadiusMeters;
	float CloudsBottomLayerRadiusMetersSquared;
	float CloudsTopLayerRadiusMetersSquared;

	float CloudsPhaseBlend;
	float CloudsDensity;
	float CloudsMaxStepsRcp;
	int CloudsMaxSteps;

	float CloudsNoiseScale;
	float _Pad0;
	float _Pad1;
	float _Pad2;
HLSL_END_STRUCT(VolumetricCloudsConstants)

#endif
