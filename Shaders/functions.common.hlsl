#ifndef _FUNCTIONS_COMMON_HLSL_
#define _FUNCTIONS_COMMON_HLSL_

float2 UVToClipXY(float2 UV)
{
    return UV * float2(2.0f, -2.0f) + float2(-1.0f, 1.0f);
}

#endif
