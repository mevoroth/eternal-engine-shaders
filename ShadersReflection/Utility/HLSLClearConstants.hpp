#ifndef _HLSL_CLEAR_CONSTANTS_HPP_
#define _HLSL_CLEAR_CONSTANTS_HPP_

HLSL_BEGIN_STRUCT(ClearConstants)
	float4 ClearValue;
	uint3 ClearSize;
	uint _Pad;
HLSL_END_STRUCT(ClearConstants)

#endif
