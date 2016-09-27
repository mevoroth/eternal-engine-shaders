#ifndef _COMPOSITING_COMMON_HLSL_
#define _COMPOSITING_COMMON_HLSL_

#include "common.hlsl"
#include "sampler.common.hlsl"

Texture2D DepthTexture						: register(t0);
Texture2D DiffuseTexture					: register(t1);
Texture2D MetallicRoughnessSpecularTexture	: register(t2);
Texture2D EmissiveTexture					: register(t3);
Texture2D NormalTexture						: register(t4);

#endif
