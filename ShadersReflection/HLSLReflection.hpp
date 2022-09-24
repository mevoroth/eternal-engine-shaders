#ifndef _HLSL_REFLECTION_HPP_
#define _HLSL_REFLECTION_HPP_

#define HLSL_BEGIN_STRUCT(StructName)						struct StructName {
#define HLSL_END_STRUCT(StructName)							};

#define HLSL_ARRAY(Type, VariableName, Count, PaddingCount)	struct \
															{ \
																Type Value; \
																Type##PaddingCount _Pad; \
															} VariableName[Count]

#define HLSL_ARRAY_VEC1(Type, VariableName, Count)			HLSL_ARRAY(Type, VariableName, Count, 3)
#define HLSL_ARRAY_VEC2(Type, VariableName, Count)			HLSL_ARRAY(Type, VariableName, Count, 2)
#define HLSL_ARRAY_VEC3(Type, VariableName, Count)			HLSL_ARRAY(Type, VariableName, Count, 1)

#endif
