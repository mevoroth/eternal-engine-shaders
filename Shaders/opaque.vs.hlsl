#include "opaque.common.hlsl"

PSIn VS( VSIn IN, uint InstanceID: SV_InstanceID )
{
	PSIn OUT = (PSIn)0;
	OUT.Pos = IN.Pos;

	OUT.Pos = mul(OUT.Pos, InstanceStructuredBufferData[InstanceID].Model);
	OUT.Pos = mul(OUT.Pos, ObjectModel);
	OUT.Pos = mul(OUT.Pos, ViewProjection);

	OUT.UV		= IN.UV;
	OUT.Normal	= IN.Normal;

	OUT.WorldPos = IN.Pos;

	OUT.RoughnessDebug = (InstanceID.x % 10) / 9.f;

	return OUT;
}
