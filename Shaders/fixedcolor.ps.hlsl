#include "object.common.hlsl"

#ifndef FIXED_COLOR_RED
#define FIXED_COLOR_RED		(1.0f)
#endif

#ifndef FIXED_COLOR_BLUE
#define FIXED_COLOR_BLUE	(0.0f)
#endif

#ifndef FIXED_COLOR_GREEN
#define FIXED_COLOR_GREEN	(0.0f)
#endif

#ifndef FIXED_COLOR_ALPHA
#define FIXED_COLOR_ALPHA	(1.0f)
#endif

struct PSOutFixedColor
{
	float4 Color : SV_Target0;
};

PSOutFixedColor PS( PSIn IN )
{
	PSOutFixedColor OUT = (PSOutFixedColor)0;

	OUT.Color = float4(
		FIXED_COLOR_RED,
		FIXED_COLOR_GREEN,
		FIXED_COLOR_BLUE,
		FIXED_COLOR_ALPHA
	);

	return OUT;
}
