#include "vertexcolor.common.hlsl"

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0;

	OUT.Diffuse = 1.0;//IN.Col;
	OUT.Depth = IN.Pos.z;

	return OUT;
}
