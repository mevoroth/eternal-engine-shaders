#include "opaque.common.hlsl"

#ifdef USE_DEPTH
#include "depthonly.ps.hlsl"
#else

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0;

	//float4 NormalWS = mul(float4(normalize(IN.Normal.xyz), 1.0f), Model[0]);
	//NormalWS.xyz /= NormalWS.w;
	float3 NormalWS = normalize(IN.Normal.xyz);

	OUT.Diffuse		= float4(DiffuseTexture.Sample(OpaqueSampler, IN.UV).xyz, 1.0f);
	OUT.Emissive	= float4(EmissiveTexture.Sample(OpaqueSampler, IN.UV).xyz, 1.0f);
	OUT.Specular	= float4(SpecularTexture.Sample(OpaqueSampler, IN.UV).xyz, 1.0f);
	OUT.Normal		= float4(NormalWS.xyz * 0.5 + 0.5, 0.0f);//float4(NormalTexture.Sample(OpaqueSampler, IN.UV).xyz /** 0.5f + 0.5f*/, 1.0f);
	OUT.Roughness	= float4(IN.RoughnessDebug, 0.f, 0.f, 1.0f);
	OUT.W			= IN.W;
	OUT.WorldPos	= IN.WorldPos;
	//OUT.Depth		= IN.LinearDepth;
	OUT.Depth		= 1.0f - IN.Pos.z;

	return OUT;
}

#endif
