#include "MipMap/mipmap.common.hlsl"

#define MIPMAP_TEXTURE_TYPE_TEXTURE1D			(0)
#define MIPMAP_TEXTURE_TYPE_TEXTURE1DARRAY		(1)
#define MIPMAP_TEXTURE_TYPE_TEXTURE2D			(2)
#define MIPMAP_TEXTURE_TYPE_TEXTURE2DARRAY		(3)
#define MIPMAP_TEXTURE_TYPE_TEXTURE3D			(4)

#define MIPMAP_CONCATENATE_RW(TextureType)		RW ## TextureType

#ifndef MIPMAP_SPIRV_FORMAT
#define MIPMAP_SPIRV_FORMAT						SPIRV_FORMAT_RGBA8
#endif

#ifndef MIPMAP_TEXTURE_TYPE
#define MIPMAP_TEXTURE_TYPE						MIPMAP_TEXTURE_TYPE_TEXTURE2D
#endif

#if MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE1D
#define MIPMAP_TEXTURE_TYPE_TOKEN				Texture1D
#elif MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE1DARRAY
#define MIPMAP_TEXTURE_TYPE_TOKEN				Texture1DArray
#elif MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE2D
#define MIPMAP_TEXTURE_TYPE_TOKEN				Texture2D
#elif MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE2DARRAY
#define MIPMAP_TEXTURE_TYPE_TOKEN				Texture2DArray
#elif MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE3D
#define MIPMAP_TEXTURE_TYPE_TOKEN				Texture3D
#endif

#ifndef MIPMAP_TEXTURE_TYPE_RW
#define MIPMAP_TEXTURE_TYPE_RW					MIPMAP_CONCATENATE_RW(MIPMAP_TEXTURE_TYPE_TOKEN)
#endif

#ifndef MIPMAP_TEXTURE_FORMAT
#define MIPMAP_TEXTURE_FORMAT					float4
#endif

#define MIPMAP_TEXTURE							MIPMAP_TEXTURE_TYPE_TOKEN<MIPMAP_TEXTURE_FORMAT>

REGISTER_T(MIPMAP_TEXTURE TextureMip0,															0, 0);
RW_RESOURCE(MIPMAP_TEXTURE_TYPE_RW, MIPMAP_TEXTURE_FORMAT, MIPMAP_SPIRV_FORMAT,	OutTextureMip1,	0, 0);
//REGISTER_B_PER_VIEW_CONSTANT_BUFFER(															0, 0);
CONSTANT_BUFFER(MipMapConstants, MipMapConstantBuffer,											0, 0);

#if MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE1D
#define MIPMAP_ANY( Value )						(Value)
#else
#define MIPMAP_ANY( Value )						(any(Value))
#endif

[numthreads(THREAD_GROUP_COUNT_X, THREAD_GROUP_COUNT_Y, THREAD_GROUP_COUNT_Z)]
void ShaderCompute( uint3 DTid : SV_DispatchThreadID )
{
#if MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE1D
	uint Pixel = DTid.x;
	uint PixelMip0 = Pixel * 2;
	uint TextureSize = MipMapConstantBuffer.TextureSize.x;
	uint Offsets[] = { 0, 1 };
	const uint OffsetsCount = 2;
#elif MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE1DARRAY || MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE2D
	uint2 Pixel = DTid.xy;
	uint2 PixelMip0 = Pixel * 2;
	uint2 TextureSize = MipMapConstantBuffer.TextureSize.xy;
	uint2 Offsets[] =
	{
		uint2(0, 0), uint2(1, 0),
		uint2(0, 1), uint2(1, 1)
	};
	const uint OffsetsCount = 4;
#else // MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE2DARRAY || MIPMAP_TEXTURE_TYPE == MIPMAP_TEXTURE_TYPE_TEXTURE3D
	uint3 Pixel = DTid.xyz;
	uint3 PixelMip0 = Pixel * 2;
	uint3 TextureSize = MipMapConstantBuffer.TextureSize.xyz;
	uint3 Offsets[] =
	{
		uint3(0, 0, 0), uint3(1, 0, 0),
		uint3(0, 1, 0), uint3(1, 1, 0),
		uint3(0, 0, 1), uint3(1, 0, 1),
		uint3(0, 1, 1), uint3(1, 1, 1)
	};
	const uint OffsetsCount = 8;
#endif
	const float SamplesCountRcp = rcp((float) OffsetsCount);
	
	MIPMAP_TEXTURE_FORMAT AccumulatedValue = (MIPMAP_TEXTURE_FORMAT)0.0f;
	
	if (MIPMAP_ANY(Pixel >= TextureSize))
		return;
	
	for (uint SampleIndex = 0; SampleIndex < OffsetsCount; ++SampleIndex)
	{
		AccumulatedValue += TextureMip0[min(PixelMip0 + Offsets[SampleIndex], TextureSize - 1)];
	}
	
	OutTextureMip1[Pixel] = AccumulatedValue * SamplesCountRcp;
}
