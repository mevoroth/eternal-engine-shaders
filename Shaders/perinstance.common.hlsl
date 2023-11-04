#ifndef _PER_INSTANCE_COMMON_HLSL_
#define _PER_INSTANCE_COMMON_HLSL_

#include "ShadersReflection/HLSLPerInstanceInformation.hpp"

#define REGISTER_T_PER_INSTANCE_STRUCTURED_BUFFER(Index, Set)		REGISTER_T(StructuredBuffer<PerInstanceInformation> PerInstanceStructuredBuffer, Index, Set)

#endif
