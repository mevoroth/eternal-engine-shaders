#ifndef _CONSTANTS_COMMON_HLSL_
#define _CONSTANTS_COMMON_HLSL_

#define EPSILON						(1e-5f)
#define PI							(3.14159265358979323846f)
#define PI_2						(PI * 2.0f)
#define PI_RCP						(1.0f / PI)
#define PI_2_RCP					(1.0f / PI_2)
#define MIN_DIELECTRICS_F0			(0.04f)

// Spir-V
#define SPIRV_FORMAT_RGBA32F		format_rgba32f
#define SPIRV_FORMAT_RGBA16F		format_rgba16f
#define SPIRV_FORMAT_R32F			format_r32f
#define SPIRV_FORMAT_RGBA8			format_rgba8
#define SPIRV_FORMAT_RGBA8SNORM		format_rgba8snorm
#define SPIRV_FORMAT_RG32F			format_rg32f
#define SPIRV_FORMAT_RG16F			format_rg16f
#define SPIRV_FORMAT_R11FG11FB10F	format_r11fg11fb10f
#define SPIRV_FORMAT_R16F			format_r16f
#define SPIRV_FORMAT_RGBA16			format_rgba16
#define SPIRV_FORMAT_RGB10A2		format_rgb10a2
#define SPIRV_FORMAT_RG16			format_rg16
#define SPIRV_FORMAT_RG8			format_rg8
#define SPIRV_FORMAT_R16			format_r16
#define SPIRV_FORMAT_R8				format_r8
#define SPIRV_FORMAT_RGBA16SNORM	format_rgba16snorm
#define SPIRV_FORMAT_RG16SNORM		format_rg16snorm
#define SPIRV_FORMAT_RG8SNORM		format_rg8snorm
#define SPIRV_FORMAT_R16SNORM		format_r16snorm
#define SPIRV_FORMAT_R8SNORM		format_r8snorm
#define SPIRV_FORMAT_RGBA32I		format_rgba32i
#define SPIRV_FORMAT_RGBA16I		format_rgba16i
#define SPIRV_FORMAT_RGBA8I			format_rgba8i
#define SPIRV_FORMAT_R32I			format_r32i
#define SPIRV_FORMAT_RG32I			format_rg32i
#define SPIRV_FORMAT_RG16I			format_rg16i
#define SPIRV_FORMAT_RG8I			format_rg8i
#define SPIRV_FORMAT_R16I			format_r16i
#define SPIRV_FORMAT_R8I			format_r8i
#define SPIRV_FORMAT_RGBA32UI		format_rgba32ui
#define SPIRV_FORMAT_RGBA16UI		format_rgba16ui
#define SPIRV_FORMAT_RGBA8UI		format_rgba8ui
#define SPIRV_FORMAT_R32UI			format_r32ui
#define SPIRV_FORMAT_RGB10A2UI		format_rgb10a2ui
#define SPIRV_FORMAT_RG32UI			format_rg32ui
#define SPIRV_FORMAT_RG16UI			format_rg16ui
#define SPIRV_FORMAT_RG8UI			format_rg8ui
#define SPIRV_FORMAT_R16UI			format_r16ui
#define SPIRV_FORMAT_R8UI			format_r8ui

#endif
