#ifndef _SPHERICAL_HARMONICS_COMMON_HLSL_
#define _SPHERICAL_HARMONICS_COMMON_HLSL_

#include "constants.common.hlsl"

#define SPHERICAL_HARMONICS_BAND0_COEFFICIENT_0		(sqrt(1.0f / (4.0f * PI)))
#define SPHERICAL_HARMONICS_BAND1_COEFFICIENT_0		(sqrt(3.0f / (4.0f * PI)))
#define SPHERICAL_HARMONICS_BAND2_COEFFICIENT_0		(sqrt(15.0f / (4.0f * PI)))
#define SPHERICAL_HARMONICS_BAND2_COEFFICIENT_1		(3.0f * sqrt(5.0f / (16.0f * PI)))
#define SPHERICAL_HARMONICS_BAND2_COEFFICIENT_2		(-sqrt(5.0f / (16.0f * PI)))
#define SPHERICAL_HARMONICS_BAND2_COEFFICIENT_3		(sqrt(15.0f / (16.0f * PI)))

struct SphericalHarmonicsBand0
{
	float Value;
};

struct SphericalHarmonicsBand1
{
	float3 Values;
};

struct SphericalHarmonicsBand2
{
	float4 Values0;
	float Value1;
};

struct SphericalHarmonicsBand01
{
	SphericalHarmonicsBand0 Band0;
	SphericalHarmonicsBand1 Band1;
};

struct SphericalHarmonicsBand012
{
	SphericalHarmonicsBand01 Band01;
	SphericalHarmonicsBand2 Band2;
};

SphericalHarmonicsBand0 InitializeBand0Basis()
{
	SphericalHarmonicsBand0 Band0 = (SphericalHarmonicsBand0)0;
	Band0.Value = SPHERICAL_HARMONICS_BAND0_COEFFICIENT_0;
	return Band0;
}

SphericalHarmonicsBand01 InitializeBand01Basis(float3 InNormal)
{
	SphericalHarmonicsBand01 Band01 = (SphericalHarmonicsBand01)0;
	Band01.Band0 = InitializeBand0Basis();
	Band01.Band1.Values = InNormal.yzx * float3(
		-SPHERICAL_HARMONICS_BAND1_COEFFICIENT_0,
		SPHERICAL_HARMONICS_BAND1_COEFFICIENT_0,
		-SPHERICAL_HARMONICS_BAND1_COEFFICIENT_0
	);
	return Band01;
}

SphericalHarmonicsBand012 InitializeBand012Basis(float3 InNormal)
{
	const float3 NormalSquared	= InNormal * InNormal;
	const float3 NormalXYXbyYZZ	= InNormal.xyx * InNormal.yzz;
	
	SphericalHarmonicsBand012 Band012 = (SphericalHarmonicsBand012)0;
	Band012.Band01			= InitializeBand01Basis(InNormal);
	Band012.Band2.Values0	= float4(
		SPHERICAL_HARMONICS_BAND2_COEFFICIENT_0,
		-SPHERICAL_HARMONICS_BAND2_COEFFICIENT_0,
		SPHERICAL_HARMONICS_BAND2_COEFFICIENT_1,
		-SPHERICAL_HARMONICS_BAND2_COEFFICIENT_0
	) * float4(NormalXYXbyYZZ.xy, NormalSquared.z, NormalXYXbyYZZ.z);
	Band012.Band2.Values0.z	+= SPHERICAL_HARMONICS_BAND2_COEFFICIENT_2;
	Band012.Band2.Value1	= SPHERICAL_HARMONICS_BAND2_COEFFICIENT_3 * (NormalSquared.x - NormalSquared.y);
	return Band012;
}

#endif
