#ifndef _BRDF_COMMON_HLSL_
#define _BRDF_COMMON_HLSL_

#include "common.hlsl"

#define BRDF_DIFFUSE_LAMBERT							(0)
#define BRDF_DIFFUSE_OREN_NAYAR							(1)
#define BRDF_DIFFUSE_DISNEY								(2)

#define BRDF_SPECULAR_PHONG								(0)
#define BRDF_SPECULAR_MICROFACET						(1)

#define BRDF_FRESNEL_SCHLICK							(0)

#define BRDF_NORMAL_DISTRIBUTION_GGX					(0)

#define BRDF_GEOMETRY_ATTENUATION_SMITH					(0)

#ifndef BRDF_DIFFUSE
#define BRDF_DIFFUSE									BRDF_DIFFUSE_DISNEY
#endif

#ifndef BRDF_SPECULAR
#define BRDF_SPECULAR									BRDF_SPECULAR_MICROFACET
#endif

#ifndef BRDF_FRESNEL
#define BRDF_FRESNEL									BRDF_FRESNEL_SCHLICK
#endif

#ifndef BRDF_NORMAL_DISTRIBUTION
#define BRDF_NORMAL_DISTRIBUTION						BRDF_NORMAL_DISTRIBUTION_GGX
#endif

#ifndef BRDF_GEOMETRY_ATTENUATION
#define BRDF_GEOMETRY_ATTENUATION						BRDF_GEOMETRY_ATTENUATION_SMITH
#endif

#if BRDF_FRESNEL == BRDF_FRESNEL_SCHLICK
#define Fresnel											FresnelSchlick
#else
#define Fresnel											FresnelNull
#endif

#if BRDF_NORMAL_DISTRIBUTION == BRDF_NORMAL_DISTRIBUTION_GGX
#define NormalDistribution								NormalDistributionGGX
#else
#define NormalDistribution								NormalDistributionNull
#endif

#if BRDF_GEOMETRY_ATTENUATION == BRDF_GEOMETRY_ATTENUATION_SMITH
#define GeometryAttenuation								GeometryAttenuationSmith
#else
#define GeometryAttenuation								GeometryAttenuationNull
#endif

#if BRDF_DIFFUSE == BRDF_DIFFUSE_LAMBERT
#define EvaluateBRDFDiffuse								EvaluateDiffuseLambert
#elif BRDF_DIFFUSE == BRDF_DIFFUSE_OREN_NAYAR
#define EvaluateBRDFDiffuse								EvaluateDiffuseOrenNayar
#elif BRDF_DIFFUSE == BRDF_DIFFUSE_DISNEY
#define EvaluateBRDFDiffuse								EvaluateDiffuseDisney
#else
#define EvaluateBRDFDiffuse								EvaluateNull
#endif

#if BRDF_SPECULAR == BRDF_SPECULAR_PHONG
#define EvaluateBRDFSpecular							EvaluateSpecularPhong
#elif BRDF_SPECULAR == BRDF_SPECULAR_MICROFACET
#define EvaluateBRDFSpecular							EvaluateSpecularMicrofacet
#else
#define EvaluateBRDFSpecular							EvaluateNull
#endif

struct BRDFInput
{
	float3 Albedo;
	float3 Specular;
	float Roughness;
	float LinearRoughness;			// Roughness * Roughness
	float LinearRoughnessSquared;	// LinearRoughness * LinearRoughness

	float3 V;
	float3 N;
	float3 L;
	float3 H;

	float NdotV;
	float NdotL;
	float LdotH;
	float NdotH;
	float VdotH;
};

struct LuminanceOuput
{
	float3 Luminance;
};

//////////////////////////////////////////////////////////////////////////
float BeckmannLinearRoughnessSquaredToShininess(BRDFInput In)
{
	return 2.0f / clamp(In.LinearRoughnessSquared, 0.0002f, 0.9999f) - 2.0f;
}

float PhongNormalizationTerm(float Shininess)
{
	return (1.0f + Shininess) * PI_2_RCP;
}

LuminanceOuput EvaluateNull(BRDFInput In)
{
	return (LuminanceOuput)0;
}

LuminanceOuput FresnelNull(float3 F0, float F90, float VdotX)
{
	return (LuminanceOuput)1;
}

float NormalDistributionNull(BRDFInput In)
{
	return 0.5f;
}

float GeometryAttenuationNull(BRDFInput In)
{
	return 1.0f;
}

float ShadowedF90(float3 F0)
{
	const float MinDielectricsF0Rcp = (1.0f / MIN_DIELECTRICS_F0);
	return min(1.0f, MinDielectricsF0Rcp * Luminance(F0));
}

float DielectricSpecularToF0(float Specular)
{
	return 0.08f * Specular;
}

float3 ComputeF0(float Specular, float3 Albedo, float Metallic)
{
	return lerp(DielectricSpecularToF0(Specular).xxx, Albedo, Metallic.xxx);
}

//////////////////////////////////////////////////////////////////////////
// Fresnel
float3 FresnelSchlick(float3 F0, float F90, float VdotX)
{
	return F0 + (F90 - F0) * pow(1.0f - VdotX, 5.0f);
}

//////////////////////////////////////////////////////////////////////////
// Normal Distribution
float NormalDistributionGGX(BRDFInput In)
{
	float Denominator = ((In.LinearRoughnessSquared - 1.0f) * In.NdotH * In.NdotH + 1.0f);
	return In.LinearRoughnessSquared / (PI * Denominator * Denominator);
}

//////////////////////////////////////////////////////////////////////////
// Geometry Attenuation
float SmithPartTerm(BRDFInput In, float NdotX)
{
	return NdotX / max(In.LinearRoughness * sqrt(1.0f - NdotX * NdotX), EPSILON);
}

float GeometryAttenuationSmith(BRDFInput In)
{
	return SmithPartTerm(In, In.NdotL) * SmithPartTerm(In, In.NdotV);
}

//////////////////////////////////////////////////////////////////////////
// Diffuse
LuminanceOuput EvaluateDiffuseLambert(BRDFInput In)
{
	LuminanceOuput Out = (LuminanceOuput)0;

	Out.Luminance = In.Albedo * PI_RCP;

	return Out;
}

LuminanceOuput EvaluateDiffuseOrenNayar(BRDFInput In)
{
	LuminanceOuput Out = (LuminanceOuput)0;

	return Out;
}

LuminanceOuput EvaluateDiffuseDisney(BRDFInput In)
{
	LuminanceOuput Out = (LuminanceOuput)0;

	const float F90MinusOne = 2.0f * In.Roughness * In.LdotH * In.LdotH + 0.5f;

	const float FresnelDiffuseL = 1.0f + (F90MinusOne * pow(1.0f - In.NdotL, 5.0f));
	const float FresnelDiffuseV = 1.0f + (F90MinusOne * pow(1.0f - In.NdotV, 5.0f));

	Out.Luminance = In.Albedo * FresnelDiffuseL * FresnelDiffuseV * PI_RCP;

	return Out;
}

//////////////////////////////////////////////////////////////////////////
// Specular
LuminanceOuput EvaluateSpecularPhong(BRDFInput In)
{
	LuminanceOuput Out = (LuminanceOuput)0;

	const float Shininess = BeckmannLinearRoughnessSquaredToShininess(In);
	const float3 R = reflect(-In.L, In.N);
	Out.Luminance = In.Specular * PhongNormalizationTerm(Shininess) * pow(max(0.0f, dot(R, In.V)), Shininess);

	return Out;
}

LuminanceOuput EvaluateSpecularMicrofacet(BRDFInput In)
{
	LuminanceOuput Out = (LuminanceOuput)0;

	const float Distribution = NormalDistribution(In);
	const float Attenuation = GeometryAttenuation(In);
	const float3 FresnelTerm = Fresnel(In.Specular, ShadowedF90(In.Specular), In.VdotH);

	Out.Luminance = Distribution * Attenuation * FresnelTerm / max((4.0f * In.NdotL * In.NdotV), EPSILON);

	return Out;
}

//////////////////////////////////////////////////////////////////////////

LuminanceOuput EvaluateDirectLighting(BRDFInput In)
{
	LuminanceOuput Out = (LuminanceOuput)0;

	LuminanceOuput Diffuse = EvaluateBRDFDiffuse(In);
	LuminanceOuput Specular = EvaluateBRDFSpecular(In);

	Out.Luminance += Diffuse.Luminance;
	Out.Luminance += Specular.Luminance;

	return Out;
}

#endif
