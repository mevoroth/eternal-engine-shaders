#include "opaque.common.hlsl"

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0;

	OUT.Emissive					= 0.0f;
	OUT.Albedo						= float4(1, 0, 0, 1);
	OUT.Normal						= float4(IN.Normal, 1);
	OUT.RoughnessMetallicSpecular	= 0.0f;

	return OUT;
}
