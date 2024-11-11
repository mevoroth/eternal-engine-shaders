#ifndef _PLATFORM_COMMON_HLSL_
#define _PLATFORM_COMMON_HLSL_

#ifndef ETERNAL_USE_PRIVATE
#define ETERNAL_USE_PRIVATE		(0)
#endif

#include "vulkan.common.hlsl"
#include "dx12.common.hlsl"

#if ETERNAL_USE_PRIVATE
#include "platform.private.common.hlsl"
#endif

#endif
