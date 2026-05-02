#ifndef _COLORSPACE_COMMON_HLSL_
#define _COLORSPACE_COMMON_HLSL_

float ColorToLuminance(float3 InColor)
{
	return dot(InColor, float3(0.2126f, 0.7152f, 0.0722f));
}

float3 ColorDesaturate(float3 InColor, float InSaturation)
{
	float Greyscale = ColorToLuminance(InColor);
	return lerp(Greyscale.xxx, InColor, InSaturation);
}

#endif
