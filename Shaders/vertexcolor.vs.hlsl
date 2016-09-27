#include "vertexcolor.common.hlsl"

PSIn VS( VSIn IN )
{
	PSIn OUT = (PSIn) 0;

	OUT.Pos = mul(IN.Pos, ViewProjection);
	OUT.Col = IN.Col;

	return OUT;
}
