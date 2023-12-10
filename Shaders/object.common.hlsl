#ifndef _OBJECT_COMMON_HLSL_
#define _OBJECT_COMMON_HLSL_

#include "platform.common.hlsl"
#include "common.hlsl"
#include "perview.common.hlsl"
#include "perinstance.common.hlsl"
#include "ShadersReflection/HLSLPerDrawConstants.hpp"

#ifndef OBJECT_NEEDS_NORMAL
#define OBJECT_NEEDS_NORMAL			(0)
#endif

#ifndef OBJECT_NEEDS_TANGENT
#define OBJECT_NEEDS_TANGENT		(0)
#endif

#ifndef OBJECT_NEEDS_BINORMAL
#define OBJECT_NEEDS_BINORMAL		(0)
#endif

#ifndef OBJECT_NEEDS_UV
#define OBJECT_NEEDS_UV				(0)
#endif

struct ShaderVertexIn
{
	float3 PositionWS	: POSITION;
	uint InstanceIndex	: SV_InstanceID;
#if OBJECT_NEEDS_NORMAL
	float3 Normal		: NORMAL;
#endif
#if OBJECT_NEEDS_TANGENT
	float3 Tangent		: TANGENT;
#endif
#if OBJECT_NEEDS_BINORMAL
	float3 Binormal		: BINORMAL;
#endif
#if OBJECT_NEEDS_UV
	float2 UV			: TEXCOORD0;
#endif
};

struct ShaderPixelIn
{
	float4 SVPosition	: SV_Position;
#if OBJECT_NEEDS_NORMAL
	float3 Normal		: NORMAL;
#endif
#if OBJECT_NEEDS_TANGENT
	float3 Tangent		: TANGENT;
#endif
#if OBJECT_NEEDS_BINORMAL
	float3 Binormal		: BINORMAL;
#endif
#if OBJECT_NEEDS_UV
	float2 UV			: TEXCOORD0;
#endif
};

struct ShaderPixelOut
{
	float3 Emissive						: SV_Target0;
	float4 Albedo						: SV_Target1;
	float4 Normal						: SV_Target2;
	float4 RoughnessMetallicSpecular	: SV_Target3;
};

ShaderPixelIn ComputeShaderPixelIn(ShaderVertexIn IN, PerDrawConstants PerDrawConstantBuffer, PerViewConstants PerViewConstantBuffer, PerInstanceInformation PerInstanceInformationStructuredBuffer)
{
	ShaderPixelIn OUT = (ShaderPixelIn)0;
	
	OUT.SVPosition = mul(float4(IN.PositionWS, 1.0f), PerDrawConstantBuffer.SubMeshToWorldTransposed);
	OUT.SVPosition = mul(PerInstanceInformationStructuredBuffer.InstanceWorldToWorld, OUT.SVPosition);
	OUT.SVPosition = mul(PerViewConstantBuffer.WorldToClip, OUT.SVPosition);
#if OBJECT_NEEDS_NORMAL
	OUT.Normal = IN.Normal;

	float3 Tangent = cross(OUT.Normal, float3(1.0f, 0.0f, 0.0f));
	float3 Binormal = cross(Tangent, OUT.Normal);
	(float3)Binormal;

	#if OBJECT_NEEDS_TANGENT
		OUT.Tangent = IN.Tangent;
		//OUT.Tangent = normalize(Tangent);
	#endif
	#if OBJECT_NEEDS_BINORMAL
		OUT.Binormal = IN.Binormal;
		//OUT.Binormal = normalize(Binormal);
	#endif
#endif
#if OBJECT_NEEDS_UV
	OUT.UV = IN.UV;
#endif

	return OUT;
}

#endif
