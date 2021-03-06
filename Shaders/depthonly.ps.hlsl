#ifndef _DEPTH_ONLY_PS_HLSL_
#define _DEPTH_ONLY_PS_HLSL_

struct DepthOnlyPSOut
{
	float Depth :	SV_Depth;
};

DepthOnlyPSOut PS( PSIn IN )
{
	DepthOnlyPSOut OUT;

	OUT.Depth = 1.0f - IN.Pos.z;

	return OUT;
}

#endif
