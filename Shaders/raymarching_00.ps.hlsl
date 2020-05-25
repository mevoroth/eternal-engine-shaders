#include "postprocess.common.hlsl"

cbuffer PerFrameConstants : register(b0)
{
	float ElapsedTime;
	float _Pad0;
	float _Pad1;
	float _Pad2;
};

struct LightInfo
{
	float3 LightPosition;
	float Radius;
	float3 LightColor;
	float LightIntensity;
};

static const float Pi = 3.14159265359f;

static const float3 SphereCenter = float3(0, 0, 300);
static const float SphereRadius = 15;

static const float3 LeftPlaneNormal = float3(1, 0, 0);
static const float3 LeftPlaneOrigin = float3(-650, 0, 0);
static const float4 LeftPlane = float4(LeftPlaneNormal, -dot(LeftPlaneOrigin, LeftPlaneNormal));

static const float3 RightPlaneNormal = float3(-1, 0, 0);
static const float3 RightPlaneOrigin = float3(650, 0, 0);
static const float4 RightPlane = float4(RightPlaneNormal, -dot(RightPlaneOrigin, RightPlaneNormal));

static const float3 FarPlaneNormal = float3(0, 0, -1);
static const float3 FarPlaneOrigin = float3(0, 0, 800);
static const float4 FarPlane = float4(FarPlaneNormal, -dot(FarPlaneOrigin, FarPlaneNormal));

static const float3 UpPlaneNormal = float3(0, -1, 0);
static const float3 UpPlaneOrigin = float3(0, 400, 0);
static const float4 UpPlane = float4(UpPlaneNormal, -dot(UpPlaneOrigin, UpPlaneNormal));

static const float3 DownPlaneNormal = float3(0, 1, 0);
static const float3 DownPlaneOrigin = float3(0, -400, 0);
static const float4 DownPlane = float4(DownPlaneNormal, -dot(DownPlaneOrigin, DownPlaneNormal));

static const float3 SmokeVolumeCenter = float3(300, 0, 750);
static const float3 SmokeVolumeForward = normalize(float3(-1, 0, 2));
static const float3 SmokeVolumeRight = normalize(cross(float3(0, 1, 0), SmokeVolumeForward));
static const float3 SmokeVolumeUp = normalize(cross(SmokeVolumeForward, SmokeVolumeRight));
static const float3 SmokeVolumeSize = 350.0f;
static const float4 SmokeVolumeForwardPlane = float4(SmokeVolumeForward, -dot(SmokeVolumeForward, SmokeVolumeCenter)) * 2.0f / SmokeVolumeSize.z;
static const float4 SmokeVolumeRightPlane = float4(SmokeVolumeRight, -dot(SmokeVolumeRight, SmokeVolumeCenter)) * 2.0f / SmokeVolumeSize.x;
static const float4 SmokeVolumeUpPlane = float4(SmokeVolumeUp, -dot(SmokeVolumeUp, SmokeVolumeCenter)) * 2.0f / SmokeVolumeSize.y;

static const int LightCount = 2;
static LightInfo Lights[LightCount] = {
	{ float3(-300, 300, 200), 1500, float3(0, 0.95, 0), 200000.0f },
	{ float3(100, 100, 400), 1700, float3(1, 0.45, 0), 100000.0f }
};

static const float RayMarchMaxSteps = 128.0f;
static const float RayMarchThreshold = 0.1f;
static const float RayMarchMaxDistance = (FarPlaneOrigin.z * 2.0f) / RayMarchMaxSteps;

static const float ScreenWidth = 1600.0f;
static const float ScreenHeight = 900.0f;
static const float ScreenRatio = ScreenWidth / ScreenHeight;

static const float3 CameraPosition = float3(0, 0, 0);
static const float3 CameraRight = float3(1, 0, 0);
static const float3 CameraUp = float3(0, 1, 0);
static const float3 CameraForward = float3(0, 0, 1);

float PhaseFunction()
{
	return 1.0f / (4.0f * Pi);
}

uint4 WangHash(uint4 Seed)
{
	Seed = (Seed ^ 61) ^ (Seed >> 16);
	Seed *= 9;
	Seed = Seed ^ (Seed >> 4);
	Seed *= 0x27d4eb2d;
	Seed = Seed ^ (Seed >> 15);
	return Seed;
}

float2 WangHash01FromPosition(float3 Position)
{
	uint Seed = asuint(Position.z);
	Seed = (Seed >> 16) | ((Seed & 0xFFFF) << 16);
	uint2 PositionUint = asuint(Position.xy) ^ Seed;
	return float2(WangHash(PositionUint.xyxy).xy) * (1.0 / 4294967296.0);
}

float EvaluateSphere(float3 CurrentPosition, float3 SphereCenter, float Radius)
{
	return distance(CurrentPosition, SphereCenter) - Radius;
}

float EvaluatePlane(float3 CurrentPosition, float4 PlaneEquation)
{
	return dot(float4(CurrentPosition, 1), PlaneEquation);
}

float EvaluateDistance(float3 CurrentPosition)
{
	return min(
		// Sphere
		EvaluateSphere(CurrentPosition, SphereCenter, SphereRadius),
		// Box
		min(
			min(
				min(
					EvaluatePlane(CurrentPosition, LeftPlane),
					EvaluatePlane(CurrentPosition, RightPlane)
				),
				min(
					EvaluatePlane(CurrentPosition, DownPlane),
					EvaluatePlane(CurrentPosition, UpPlane)
				)
			),
			EvaluatePlane(CurrentPosition, FarPlane)
		)
	);
}

struct MaterialInfo
{
	float3 EmissiveColor;
	float3 BaseColor;
	float3 Normal;
	float Roughness;
	float Specular;
};

MaterialInfo EvaluateMaterial(float3 CurrentPosition)
{
	MaterialInfo Material = (MaterialInfo)0;

	float3 Normal = float3(
		EvaluateDistance(CurrentPosition + float3(1, 0, 0)) - EvaluateDistance(CurrentPosition - float3(1, 0, 0)),
		EvaluateDistance(CurrentPosition + float3(0, 1, 0)) - EvaluateDistance(CurrentPosition - float3(0, 1, 0)),
		EvaluateDistance(CurrentPosition + float3(0, 0, 1)) - EvaluateDistance(CurrentPosition - float3(0, 0, 1))
	);
	Material.Normal = normalize(Normal);

	[branch]
	if (EvaluateSphere(CurrentPosition, SphereCenter, SphereRadius) < RayMarchThreshold)
	{
		Material.BaseColor = float3(0.75, 0.75, 0.75);
		Material.Specular = 0.8;
	}
	else if (EvaluatePlane(CurrentPosition, LeftPlane) < RayMarchThreshold)
	{
		Material.BaseColor = float3(0.447, 0.184, 0.216);
		Material.Roughness = 0.85f;
	}
	else if (EvaluatePlane(CurrentPosition, RightPlane) < RayMarchThreshold)
	{
		Material.BaseColor = float3(0.004, 0.475, 0.435);
		Material.Roughness = 0.85f;
	}
	else if (EvaluatePlane(CurrentPosition, FarPlane) < RayMarchThreshold)
	{
		Material.BaseColor = float3(0.45, 0.45, 0.45);
		Material.Roughness = 0.9f;
	}
	else if (EvaluatePlane(CurrentPosition, UpPlane) < RayMarchThreshold)
	{
		Material.BaseColor = float3(0.45, 0.45, 0.45);
		Material.Roughness = 0.9f;
	}
	else if (EvaluatePlane(CurrentPosition, DownPlane) < RayMarchThreshold)
	{
		Material.BaseColor = float3(0.45, 0.45, 0.45);
		Material.Roughness = 0.9f;
	}

	return Material;
}

float3 EvaluatePointLight(float3 CurrentPosition, LightInfo Info)
{
	float3 LightToPosition = Info.LightPosition - CurrentPosition;
	float DistanceSquare = max(dot(LightToPosition, LightToPosition), 0.00001f);
	float LightAttenuation = 1.0f / DistanceSquare;
	return Info.LightColor * Info.LightIntensity * LightAttenuation;
}

float3 EvaluateSurfaceLighting(float3 CurrentPosition)
{
	MaterialInfo Material = EvaluateMaterial(CurrentPosition);

	float3 Radiance = Material.EmissiveColor;
	for (int LightIndex = 0; LightIndex < LightCount; ++LightIndex)
	{
		float NdotL = saturate(dot(normalize(Lights[LightIndex].LightPosition - CurrentPosition), Material.Normal));
		Radiance += Material.BaseColor * EvaluatePointLight(CurrentPosition, Lights[LightIndex]) * NdotL;
	}

	return Radiance;
}

float3 EvaluateLighting(float3 CurrentPosition)
{
	float3 Radiance = 0.0f;
	for (int LightIndex = 0; LightIndex < LightCount; ++LightIndex)
	{
		Radiance += EvaluatePointLight(CurrentPosition, Lights[LightIndex]);
	}
	return Radiance;
}

void EvaluateParticipatingMedia(float3 CurrentPosition, out float OutExtinction)
{
	OutExtinction = 0.0;

	const float ConstantFog = 0.00005f;
	const float BoxFog = 0.0008f;

	float4 CurrentPositionVector4 = float4(CurrentPosition, 1);

	float SmokeMask = abs(dot(CurrentPositionVector4, SmokeVolumeForwardPlane)) < 1.0f ? 1.0f : 0.0f;
	SmokeMask *= abs(dot(CurrentPositionVector4, SmokeVolumeRightPlane)) < 1.0f ? 1.0f : 0.0f;
	SmokeMask *= abs(dot(CurrentPositionVector4, SmokeVolumeUpPlane)) < 1.0f ? 1.0f : 0.0f;

	float2 Noise2 = WangHash01FromPosition(CurrentPosition * 0.000001f);
	float Noise = (Noise2.x + Noise2.y) * 0.5f;

	OutExtinction = ConstantFog + BoxFog * Noise * SmokeMask;
}

float4 PS(PSIn IN) : SV_Target0
{
	const float2 PositionSS		= (float2(IN.UV.x, 1.0f - IN.UV.y) * 2.0f - 1.0f) * float2(ScreenRatio, 1.0f);
	const float3 RayDirection	= normalize(PositionSS.x * CameraRight + PositionSS.y * CameraUp + CameraForward);
	
	float3 RayPosition = CameraPosition;
	int Steps = (int)RayMarchMaxSteps;
	float CurrentDistance = 100000000.0f;
	float DistanceMarched = 0.0f;
	float3 Scattering = 0.0f;
	float Transmittance = 1.0f;

	RayPosition += RayDirection * WangHash01FromPosition(RayDirection).y * 200.0f;

	for (; Steps >= 0 && abs(CurrentDistance) > RayMarchThreshold; --Steps)
	{
		float Extinction = 0.0f;
		EvaluateParticipatingMedia(RayPosition, Extinction);

		float ExtinctionClamped = max(Extinction, 0.0000001f);

		float3 LocalScattering = EvaluateLighting(RayPosition) * Extinction * PhaseFunction();
		float3 LocalScatteringIntegrated = (LocalScattering - LocalScattering * exp(-ExtinctionClamped * DistanceMarched)) / ExtinctionClamped;
		Scattering += LocalScatteringIntegrated * Transmittance;
		Transmittance *= exp(-ExtinctionClamped * DistanceMarched);

		CurrentDistance = EvaluateDistance(RayPosition);
		CurrentDistance = min(CurrentDistance, RayMarchMaxDistance);

		DistanceMarched += CurrentDistance;
		RayPosition += RayDirection * CurrentDistance;
	}

	//float3 OutColor = (CurrentDistance < RayMarchThreshold) ? float3((float)Steps / MaxSteps, 0, 0) : (float3)0.0f;
	//float3 OutColor = (CurrentDistance < RayMarchThreshold) ? float3(1.0f - (DistanceMarched / 1000.0f), 0.0f, 0.0f) : float3(0, 0, 1);
	float3 OutColor = (CurrentDistance < RayMarchThreshold) ? EvaluateSurfaceLighting(RayPosition) : float3(0, 0, 0);
	OutColor = OutColor * Transmittance + Scattering;
	return float4(OutColor, 1.0f);
	//return float4(ElapsedTime * 0.01f, 0, 0, 1);
	//return float4(SmokeVolumeUp, 1.0f);
}
