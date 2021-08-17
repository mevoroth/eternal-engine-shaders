#ifndef _PER_VIEW_COMMON_HLSL_
#define _PER_VIEW_COMMON_HLSL_

#include "ShadersReflection/HLSLPerViewConstants.hpp"

#define REGISTER_B_PER_VIEW_CONSTANT_BUFFER(Index, Set)		REGISTER_B(ConstantBuffer<PerViewConstants> PerViewConstantBuffer, Index, Set)

#endif
