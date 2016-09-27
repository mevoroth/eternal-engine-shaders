#include "lighting.common.hlsl"

#include "postprocess.common.hlsl"

PSOut PS( PSIn IN )
{
    PSOut OUT = (PSOut)0;

    OUT.Refraction = 1.f;

    return OUT;
}
