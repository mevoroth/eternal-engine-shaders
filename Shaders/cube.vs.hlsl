#include "cube.common.hlsl"
#include "ShadersReflection/HLSLCubePerInstanceInformation.hpp"

REGISTER_B_PER_VIEW_CONSTANT_BUFFER(														0, 0);
REGISTER_T(StructuredBuffer<CubePerInstanceInformation> CubePerInstanceStructuredBuffer,	0, 0);

struct PSIn
{
	uint VertexIndex	: SV_VertexID;
	uint InstanceIndex	: SV_InstanceID;
};

float3 CubeVertices[] =
{
	float3(-1.0f, -1.0f, -1.0f),
	float3( 1.0f, -1.0f, -1.0f),
	float3(-1.0f,  1.0f, -1.0f),
	float3( 1.0f,  1.0f, -1.0f),
	float3(-1.0f, -1.0f,  1.0f),
	float3( 1.0f, -1.0f,  1.0f),
	float3(-1.0f,  1.0f,  1.0f),
	float3( 1.0f,  1.0f,  1.0f)
};

uint Lines[] =
{
	0, 1,
	1, 2,
	2, 3,
	3, 0
	4, 5,
	5, 6,
	6, 7,
	7, 4
	0, 4,
	1, 5,
	2, 6,
	3, 7
};

PSIn VS( VSIn IN )
{
	PSIn OUT = (PSIn)0;

	float3 CubeVertex = CubeVertices[Lines[IN.VertexIndex]] * CubePerInstanceStructuredBuffer[IN.InstanceIndex].CubeExtent + CubePerInstanceStructuredBuffer[IN.InstanceIndex].CubeOrigin;
	OUT.SVPosition = mul(CubePerInstanceStructuredBuffer[IN.InstanceIndex].InstanceWorldToWorld, float4(CubeVertex, 1.0f));
	OUT.SVPosition = mul(PerViewConstantBuffer.WorldToClip, OUT.SVPosition);

	return OUT;
}
