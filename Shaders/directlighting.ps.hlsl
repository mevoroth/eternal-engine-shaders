#include "directlighting.common.hlsl"
#include "brdf.common.hlsl"

REGISTER_B(ConstantBuffer<DirectLightingConstants>	DirectLightingBuffer,		0, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(											1, 0);
REGISTER_T(Texture2D<float>							DepthTexture,				0, 0);
REGISTER_T(Texture2D<float4>						AlbedoTexture,				1, 0);
REGISTER_T(Texture2D<float4>						NormalsTexture,				2, 0);
REGISTER_T(Texture2D<float4>						RoughnessMetallicSpecular,	3, 0);
REGISTER_T(StructuredBuffer<LightInformation>		LightsBuffer,				4, 0);
REGISTER_S(SamplerState								PointSampler,				0, 0);

BRDFInput InitializeBRDFInput( PSIn IN )
{
	BRDFInput Out = (BRDFInput)0;

	float DepthSample						= DepthTexture.Sample(PointSampler, IN.UV).x;
	float3 AlbedoSample						= AlbedoTexture.Sample(PointSampler, IN.UV).rgb;
	float3 NormalsSample					= NormalsTexture.Sample(PointSampler, IN.UV).xyz;
	float3 RoughnessMetallicSpecularSample	= RoughnessMetallicSpecular.Sample(PointSampler, IN.UV).xyz;

	float3 WorldPosition		= UVDepthToWorldPosition(IN.UV, DepthSample, PerViewConstantBuffer.WorldToClip);

	Out.Albedo					= AlbedoTexture.Sample(PointSampler, IN.UV).rgb;
	Out.Specular				= ComputeF0(RoughnessMetallicSpecularSample.z, Out.Albedo, RoughnessMetallicSpecularSample.y);
	Out.Roughness				= RoughnessMetallicSpecularSample.x;
	Out.LinearRoughness			= Out.Roughness * Out.Roughness;
	Out.LinearRoughnessSquared	= Out.LinearRoughness * Out.LinearRoughness;

	Out.V						= normalize(PerViewConstantBuffer.ViewPosition.xyz - WorldPosition);
	Out.N						= NormalsSample;
	
	Out.NdotV					= dot(Out.N, Out.V);

	//float3 Specular;

	return Out;
}

void InitializeBRDFInput_DirectionalLight( inout BRDFInput InOutBRDFInput, LightInformation InLight )
{
	InOutBRDFInput.L		= -InLight.Direction;
	InOutBRDFInput.H		= normalize(InOutBRDFInput.L + InOutBRDFInput.V);

	InOutBRDFInput.NdotL	= saturate(dot(InOutBRDFInput.N, InOutBRDFInput.L));
	InOutBRDFInput.LdotH	= saturate(dot(InOutBRDFInput.L, InOutBRDFInput.H));
	InOutBRDFInput.NdotH	= saturate(dot(InOutBRDFInput.N, InOutBRDFInput.H));
	InOutBRDFInput.VdotH	= saturate(dot(InOutBRDFInput.V, InOutBRDFInput.H));
}

PSOut PS( PSIn IN )
{
	PSOut OUT = (PSOut)0;

	BRDFInput Input = InitializeBRDFInput(IN);

	const uint LightsCount = DirectLightingBuffer.LightsCount;
	
	LuminanceOuput Lighting = (LuminanceOuput)0;
	
	for (uint LightIndex = 0; LightIndex < LightsCount; ++LightIndex)
	{
		InitializeBRDFInput_DirectionalLight(Input, LightsBuffer[LightIndex]);

		LuminanceOuput BRDF = EvaluateDirectLighting(Input);
		OUT.Luminance.rgb += BRDF.Luminance * LightsBuffer[LightIndex].Radiance * Input.NdotL;
	}

	return OUT;
}
