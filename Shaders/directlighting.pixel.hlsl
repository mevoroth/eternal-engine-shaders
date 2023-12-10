#include "directlighting.common.hlsl"
#include "brdf.common.hlsl"

CONSTANT_BUFFER(DirectLightingConstants,			DirectLightingBuffer,		0, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(											1, 0);
REGISTER_T(Texture2D<float>							DepthTexture,				0, 0);
REGISTER_T(Texture2D<float4>						AlbedoTexture,				1, 0);
REGISTER_T(Texture2D<float4>						NormalsTexture,				2, 0);
REGISTER_T(Texture2D<float4>						RoughnessMetallicSpecular,	3, 0);
REGISTER_T(StructuredBuffer<LightInformation>		LightsBuffer,				4, 0);
REGISTER_S(SamplerState								PointSampler,				0, 0);

BRDFInput InitializeBRDFInput( ShaderPixelIn IN )
{
	BRDFInput Out = (BRDFInput)0;

	float DepthSample						= DepthTexture.Sample(PointSampler, IN.UV).x;
	float3 AlbedoSample						= AlbedoTexture.Sample(PointSampler, IN.UV).rgb;
	float3 NormalsSample					= NormalsTexture.Sample(PointSampler, IN.UV).xyz;
	float3 RoughnessMetallicSpecularSample	= RoughnessMetallicSpecular.Sample(PointSampler, IN.UV).xyz;

	float3 WorldPosition		= UVDepthToWorldPosition(IN.UV, DepthSample, PerViewConstantBuffer.ClipToWorld);

	Out.Albedo					= AlbedoSample;
	Out.Specular				= ComputeF0(RoughnessMetallicSpecularSample.z, Out.Albedo, RoughnessMetallicSpecularSample.y);
	Out.Roughness				= RoughnessMetallicSpecularSample.x;
	Out.LinearRoughness			= Out.Roughness * Out.Roughness;
	Out.LinearRoughnessSquared	= Out.LinearRoughness * Out.LinearRoughness;

	Out.V						= SafeNormalize(PerViewConstantBuffer.ViewPosition.xyz - WorldPosition);
	Out.N						= SafeNormalize(NormalsSample);
	
	Out.NdotV					= max(dot(Out.N, Out.V), 0.0f);

	return Out;
}

void InitializeBRDFInput_DirectionalLight( inout BRDFInput InOutBRDFInput, LightInformation InLight )
{
	InOutBRDFInput.L		= -InLight.Direction;
	InOutBRDFInput.H		= normalize(InOutBRDFInput.L + InOutBRDFInput.V);

	InOutBRDFInput.NdotL	= max(dot(InOutBRDFInput.N, InOutBRDFInput.L), 0.0f);
	InOutBRDFInput.LdotH	= max(dot(InOutBRDFInput.L, InOutBRDFInput.H), 0.0f);
	InOutBRDFInput.NdotH	= max(dot(InOutBRDFInput.N, InOutBRDFInput.H), 0.0f);
	InOutBRDFInput.VdotH	= max(dot(InOutBRDFInput.V, InOutBRDFInput.H), 0.0f);
}

ShaderPixelOut ShaderPixel( ShaderPixelIn IN )
{
	ShaderPixelOut OUT = (ShaderPixelOut)0;

	BRDFInput Input = InitializeBRDFInput(IN);

	const uint LightsCount = DirectLightingBuffer.LightsCount;
	
	for (uint LightIndex = 0; LightIndex < LightsCount; ++LightIndex)
	{
		InitializeBRDFInput_DirectionalLight(Input, LightsBuffer[LightIndex]);

		LuminanceOuput BRDF = EvaluateDirectLighting(Input);
		OUT.Luminance.rgb += BRDF.Luminance * LightsBuffer[LightIndex].Radiance * Input.NdotL;
	}

	return OUT;
}
