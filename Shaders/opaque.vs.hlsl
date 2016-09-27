#include "opaque.common.hlsl"

PSIn VS( VSIn IN )
{
	PSIn OUT = (PSIn)0;
	OUT.Pos = IN.Pos;

	OUT.Pos = mul(OUT.Pos, transpose(Model));
	OUT.Pos = mul(OUT.Pos, ViewProjection);

	OUT.UV		= IN.UV;
	OUT.Normal	= IN.Normal;

	return OUT;
}
