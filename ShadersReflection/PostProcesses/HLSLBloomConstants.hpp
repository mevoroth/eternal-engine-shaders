#ifndef _HLSL_BLOOM_CONSTANTS_HPP_
#define _HLSL_BLOOM_CONSTANTS_HPP_

HLSL_BEGIN_STRUCT(BloomConstants)
	float4 ViewSizeAndInverseSize;
	float2 BloomTexelSize;
	float BloomThreshold;
	float BloomIntensity;
	float BloomSaturation;
	float BloomDirtMaskIntensity;
	float BloomUpsampleRadius;
	uint BloomMipLevel;
HLSL_END_STRUCT(BloomConstants)

#endif
