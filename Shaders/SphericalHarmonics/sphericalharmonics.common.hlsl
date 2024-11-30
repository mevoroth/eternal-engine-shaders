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

struct SphericalHarmonicsBand0RGB
{
	SphericalHarmonicsBand0 R;
	SphericalHarmonicsBand0 G;
	SphericalHarmonicsBand0 B;
};

struct SphericalHarmonicsBand01RGB
{
	SphericalHarmonicsBand01 R;
	SphericalHarmonicsBand01 G;
	SphericalHarmonicsBand01 B;
};

struct SphericalHarmonicsBand012RGB
{
	SphericalHarmonicsBand012 R;
	SphericalHarmonicsBand012 G;
	SphericalHarmonicsBand012 B;
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

SphericalHarmonicsBand01RGB InitializeBand01RGBFromBand012RGB(SphericalHarmonicsBand012RGB InBand)
{
	SphericalHarmonicsBand01RGB Result = (SphericalHarmonicsBand01RGB)0;
	Result.R = InBand.R.Band01;
	Result.G = InBand.G.Band01;
	Result.B = InBand.B.Band01;
	return Result;
}

SphericalHarmonicsBand0 Add(SphericalHarmonicsBand0 InA, SphericalHarmonicsBand0 InB)
{
	SphericalHarmonicsBand0 Result = (SphericalHarmonicsBand0)0;
	Result.Value = InA.Value + InB.Value;
	return Result;
}

SphericalHarmonicsBand1 Add(SphericalHarmonicsBand1 InA, SphericalHarmonicsBand1 InB)
{
	SphericalHarmonicsBand1 Result = (SphericalHarmonicsBand1)0;
	Result.Values = InA.Values + InB.Values;
	return Result;
}

SphericalHarmonicsBand2 Add(SphericalHarmonicsBand2 InA, SphericalHarmonicsBand2 InB)
{
	SphericalHarmonicsBand2 Result = (SphericalHarmonicsBand2)0;
	Result.Values0	= InA.Values0 + InB.Values0;
	Result.Value1	= InA.Value1 + InB.Value1;
	return Result;
}

SphericalHarmonicsBand01 Add(SphericalHarmonicsBand01 InA, SphericalHarmonicsBand01 InB)
{
	SphericalHarmonicsBand01 Result = (SphericalHarmonicsBand01)0;
	Result.Band0 = Add(InA.Band0, InB.Band0);
	Result.Band1 = Add(InA.Band1, InB.Band1);
	return Result;
}

SphericalHarmonicsBand012 Add(SphericalHarmonicsBand012 InA, SphericalHarmonicsBand012 InB)
{
	SphericalHarmonicsBand012 Result = (SphericalHarmonicsBand012)0;
	Result.Band01	= Add(InA.Band01, InB.Band01);
	Result.Band2	= Add(InA.Band2, InB.Band2);
	return Result;
}

SphericalHarmonicsBand0RGB Add(SphericalHarmonicsBand0RGB InA, SphericalHarmonicsBand0RGB InB)
{
	SphericalHarmonicsBand0RGB Result = (SphericalHarmonicsBand0RGB)0;
	Result.R = Add(InA.R, InB.R);
	Result.G = Add(InA.G, InB.G);
	Result.B = Add(InA.B, InB.B);
	return Result;
}

SphericalHarmonicsBand01RGB Add(SphericalHarmonicsBand01RGB InA, SphericalHarmonicsBand01RGB InB)
{
	SphericalHarmonicsBand01RGB Result = (SphericalHarmonicsBand01RGB)0;
	Result.R = Add(InA.R, InB.R);
	Result.G = Add(InA.G, InB.G);
	Result.B = Add(InA.B, InB.B);
	return Result;
}

SphericalHarmonicsBand012RGB Add(SphericalHarmonicsBand012RGB InA, SphericalHarmonicsBand012RGB InB)
{
	SphericalHarmonicsBand012RGB Result = (SphericalHarmonicsBand012RGB) 0;
	Result.R = Add(InA.R, InB.R);
	Result.G = Add(InA.G, InB.G);
	Result.B = Add(InA.B, InB.B);
	return Result;
}

SphericalHarmonicsBand0 Mul(SphericalHarmonicsBand0 InBand, float InMultiplier)
{
	SphericalHarmonicsBand0 Result = (SphericalHarmonicsBand0)0;
	Result.Value = InBand.Value * InMultiplier;
	return Result;
}

SphericalHarmonicsBand1 Mul(SphericalHarmonicsBand1 InBand, float InMultiplier)
{
	SphericalHarmonicsBand1 Result = (SphericalHarmonicsBand1)0;
	Result.Values = InBand.Values * InMultiplier;
	return Result;
}

SphericalHarmonicsBand2 Mul(SphericalHarmonicsBand2 InBand, float InMultiplier)
{
	SphericalHarmonicsBand2 Result = (SphericalHarmonicsBand2)0;
	Result.Values0	= InBand.Values0 * InMultiplier;
	Result.Value1	= InBand.Value1 * InMultiplier;
	return Result;
}

SphericalHarmonicsBand01 Mul(SphericalHarmonicsBand01 InBand, float InMultiplier)
{
	SphericalHarmonicsBand01 Result = (SphericalHarmonicsBand01)0;
	Result.Band0 = Add(InBand.Band0, InMultiplier);
	Result.Band1 = Add(InBand.Band1, InMultiplier);
	return Result;
}

SphericalHarmonicsBand012 Mul(SphericalHarmonicsBand012 InBand, float InMultiplier)
{
	SphericalHarmonicsBand012 Result = (SphericalHarmonicsBand012)0;
	Result.Band01	= Mul(InBand.Band01, InMultiplier);
	Result.Band2	= Mul(InBand.Band2, InMultiplier);
	return Result;
}

SphericalHarmonicsBand0RGB Mul(SphericalHarmonicsBand0RGB InBand, float InMultiplier)
{
	SphericalHarmonicsBand0RGB Result = (SphericalHarmonicsBand0RGB)0;
	Result.R = Mul(InBand.R, InMultiplier);
	Result.G = Mul(InBand.G, InMultiplier);
	Result.B = Mul(InBand.B, InMultiplier);
	return Result;
}

SphericalHarmonicsBand01RGB Mul(SphericalHarmonicsBand01RGB InBand, float InMultiplier)
{
	SphericalHarmonicsBand01RGB Result = (SphericalHarmonicsBand01RGB)0;
	Result.R = Mul(InBand.R, InMultiplier);
	Result.G = Mul(InBand.G, InMultiplier);
	Result.B = Mul(InBand.B, InMultiplier);
	return Result;
}

SphericalHarmonicsBand012RGB Mul(SphericalHarmonicsBand012RGB InBand, float InMultiplier)
{
	SphericalHarmonicsBand012RGB Result = (SphericalHarmonicsBand012RGB)0;
	Result.R = Mul(InBand.R, InMultiplier);
	Result.G = Mul(InBand.G, InMultiplier);
	Result.B = Mul(InBand.B, InMultiplier);
	return Result;
}

SphericalHarmonicsBand0RGB Mul(SphericalHarmonicsBand0 InBand, float3 InColor)
{
	SphericalHarmonicsBand0RGB Result = (SphericalHarmonicsBand0RGB)0;
	Result.R = Mul(InBand, InColor.r);
	Result.G = Mul(InBand, InColor.g);
	Result.B = Mul(InBand, InColor.b);
	return Result;
}

SphericalHarmonicsBand01RGB Mul(SphericalHarmonicsBand01 InBand, float3 InColor)
{
	SphericalHarmonicsBand01RGB Result = (SphericalHarmonicsBand01RGB)0;
	Result.R = Mul(InBand, InColor.r);
	Result.G = Mul(InBand, InColor.g);
	Result.B = Mul(InBand, InColor.b);
	return Result;
}

SphericalHarmonicsBand012RGB Mul(SphericalHarmonicsBand012 InBand, float3 InColor)
{
	SphericalHarmonicsBand012RGB Result = (SphericalHarmonicsBand012RGB) 0;
	Result.R = Mul(InBand, InColor.r);
	Result.G = Mul(InBand, InColor.g);
	Result.B = Mul(InBand, InColor.b);
	return Result;
}

float3 DecodeSphericalHarmonicsBand0(SphericalHarmonicsBand0RGB InBand)
{
	return max(float3(
		InBand.R.Value,
		InBand.G.Value,
		InBand.B.Value
	), 0.0f);
}

float3 DecodeSphericalHarmonicsBand01(SphericalHarmonicsBand01RGB InBand, float3 InNormal)
{
	float4 Normal = float4(InNormal, 1.0f);
	
	return max(float3(
		dot(float4(InBand.R.Band1.Values, InBand.R.Band0.Value), Normal),
		dot(float4(InBand.G.Band1.Values, InBand.G.Band0.Value), Normal),
		dot(float4(InBand.B.Band1.Values, InBand.B.Band0.Value), Normal)
	), 0.0f);
}

float3 DecodeSphericalHarmonicsBand012(SphericalHarmonicsBand012RGB InBand, float3 InNormal)
{
	float4 Normal = float4(InNormal, 1.0f);
	
	SphericalHarmonicsBand01RGB Band01 = InitializeBand01RGBFromBand012RGB(InBand);
	
	float3 DecodedBand01 = DecodeSphericalHarmonicsBand01(Band01, InNormal);
	
	float4 WeightBand2_0 = InNormal.xyzz * InNormal.yzzx;
	float3 DecodedBand2_0 = float3(
		dot(InBand.R.Band2.Values0, WeightBand2_0),
		dot(InBand.G.Band2.Values0, WeightBand2_0),
		dot(InBand.B.Band2.Values0, WeightBand2_0)
	);
	float WeightBand2_1 = InNormal.x * InNormal.x - InNormal.y * InNormal.y;
	float3 DecodedBand2_1 = float3(
		InBand.R.Band2.Value1,
		InBand.G.Band2.Value1,
		InBand.B.Band2.Value1
	) * WeightBand2_1;
	
	return max(DecodedBand01 + DecodedBand2_0 + DecodedBand2_1, 0.0f);

}

#endif
