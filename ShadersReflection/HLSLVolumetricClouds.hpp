#ifndef _HLSL_VOLUMETRIC_CLOUDS_HPP_
#define _HLSL_VOLUMETRIC_CLOUDS_HPP_

HLSL_BEGIN_STRUCT(VolumetricCloudsConstants)
	float TopLayerRadiusSquared;
	float BottomLayerRadiusSquared;
	float _Pad0;
	float _Pad1;
HLSL_END_STRUCT(VolumetricCloudsConstants)

#endif
