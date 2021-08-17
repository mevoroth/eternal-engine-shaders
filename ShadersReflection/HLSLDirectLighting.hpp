#ifndef _HLSL_DIRECT_LIGHTING_HPP_
#define _HLSL_DIRECT_LIGHTING_HPP_


HLSL_BEGIN_STRUCT(LightInformation)
	float4 Position;
	float3 Radiance;
	float _Pad0;
	float3 Direction;
	float _Pad1;
HLSL_END_STRUCT(LightInformation)

HLSL_BEGIN_STRUCT(DirectLightingConstants)
	uint LightsCount;
	uint _Pad0;
	uint _Pad1;
	uint _Pad2;
HLSL_END_STRUCT(DirectLightingConstants)


#endif
