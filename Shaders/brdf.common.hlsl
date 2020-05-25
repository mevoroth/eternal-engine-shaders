#ifndef _BRDF_COMMON_HLSL_
#define _BRDF_COMMON_HLSL_

#define BRDF_FRESNEL_SCHLICK
#define BRDF_DISTRIBUTION_GGX
#define BRDF_GEOMETRY_GGX

// Fresnel
#if defined(BRDF_FRESNEL_SCHLICK)
float3 Fresnel(float VdotH, float3 Spec)
{
	return Spec + (1.0f - Spec) * pow(1 - VdotH, 5.0f);
}
//#elif defined(BRDF_FRESNEL_COOK_TORRANCE)
#else
float3 Fresnel(float3 VdotH, float3 Spec)
{
	return Spec;
}
#endif

// Geometry function
#if defined(BRDF_GEOMETRY_GGX)
float GeometryComponent(float Roughness2, float NdotX)
{
    //return rcp(Roughness2 + NdotX * (1.0f - Roughness2));
    return 2.0f * NdotX / (NdotX + sqrt(Roughness2 + (1.0f - Roughness2) * NdotX * NdotX));
}
float Geometry(float Roughness2, float NdotV, float NdotL)
{
    return GeometryComponent(Roughness2, NdotV) * GeometryComponent(Roughness2, NdotL);
}
#else
float Geometry(float Roughness, float NdotV, float NdotL)
{
	return 1.0f;
}
#endif

// Distribution
#if defined(BRDF_DISTRIBUTION_GGX)
float Distribution(float Roughness2, float NdotH)
{
    float a2 = Roughness2 * Roughness2;
	float NdotH2 = NdotH * NdotH;
	float d = NdotH2 * (a2 - 1.0f) + 1.0f;
	return a2 / (d * d);
}
#else
float Distribution(float Roughness2, float NdotH)
{
	return Roughness2;
}
#endif

#endif
