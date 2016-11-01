#include "lighting.common.hlsl"
#include "postprocess.common.hlsl"
#include "functions.common.hlsl"
#include "constants.common.hlsl"

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0;

	float4 PosSS = float4(UVToClipXY(IN.UV), 0.0f, 1.0f);
	PosSS.z = DepthTexture.Sample(BilinearSampler, IN.UV.xy).x;

	float4 PosWS = mul(PosSS.xyzw, ViewProjectionInversed);
	PosWS.xyzw /= PosWS.wwww;

	//float DebugDepth = DepthDebugTexture.Sample(BilinearSampler, IN.UV.xy).z;
	float3 DebugWorldPos = DepthDebugTexture.Sample(BilinearSampler, IN.UV.xy).xyz;
	//PosWS.xyz = DebugWorldPos;

	float3 DiffuseColor		= DiffuseTexture.Sample(BilinearSampler, IN.UV.xy).xyz;
	float3 SpecularColor	= SpecularTexture.Sample(BilinearSampler, IN.UV.xy).zzz;
	float Roughness			= RoughnessTexture.Sample(BilinearSampler, IN.UV.xy).x;

	float3 LightToPixel = Lights[0].Position.xyz - PosWS.xyz;
	float3 L = normalize(LightToPixel.xyz);
	float3 N = NormalTexture.Sample(BilinearSampler, IN.UV.xy).xyz * 2.0f - 1.0f;
	//N = normalize(N);
	float3 V = normalize(CameraPosition.xyz - PosWS.xyz);
	float3 H = normalize(V + L);

	float VdotH = saturate(dot(V, H));
	float NdotH = saturate(dot(N, H));
	float NdotV = max(dot(N, V), EPSILON);
	float NdotL = saturate(dot(N, L));

	//float Roughness2 = Roughness * Roughness;
	float Roughness2 = 1.f;

	float LightToPixelSquared = dot(LightToPixel, LightToPixel);
	
	//float Distance = distance(Lights[0].Position.xyz, DebugWorldPos);
	float Distance = sqrt(LightToPixelSquared);

	const float LightAttenuation = Lights[0].Distance / (Distance + EPSILON);
	const float3 LightColor = Lights[0].Color.xyz;

	OUT.Light.xyz = NdotL * LightAttenuation * LightColor;
	OUT.Light.xyz *= Lights[0].Intensity * SpecularBRDF(Lights[0].Distance / 1000.0f, Roughness2, VdotH, NdotH, NdotV, NdotL);
	OUT.Light.xyz += NdotL * DiffuseBRDF(DiffuseColor.xyz);

	OUT.Light.w = 1.0f;

	return OUT;
}
