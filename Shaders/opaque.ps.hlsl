#include "opaque.common.hlsl"

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0;

	float4 NormalWS = mul(float4(normalize(IN.Normal.xyz), 1.0f), Model);
	NormalWS.xyz /= NormalWS.w;
	//float3 NormalWS = normalize(IN.Normal.xyz);

	OUT.Diffuse		= float4(DiffuseTexture.Sample(OpaqueSampler, IN.UV).xyz, 1.0f);
	OUT.Emissive	= float4(EmissiveTexture.Sample(OpaqueSampler, IN.UV).xyz, 1.0f);
	OUT.Specular	= float4(SpecularTexture.Sample(OpaqueSampler, IN.UV).xyz, 1.0f);
	OUT.Normal		= float4(NormalWS.xyz * 0.5 + 0.5, 0);//float4(NormalTexture.Sample(OpaqueSampler, IN.UV).xyz /** 0.5f + 0.5f*/, 1.0f);
	OUT.WorldPos	= IN.WorldPos;
	OUT.Depth		= IN.Pos.z;

	return OUT;
}
