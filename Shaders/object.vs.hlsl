#include "object.common.hlsl"
#include "ShadersReflection/HLSLPerDrawConstants.hpp"

REGISTER_B(ConstantBuffer<PerDrawConstants> PerDrawConstantBuffer,	0, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(								1, 0);

PSIn VS( VSIn IN )
{
	PSIn OUT = (PSIn)0;

	OUT.SVPosition	= mul(PerDrawConstantBuffer.SubMeshToLocal, IN.Position);
	OUT.SVPosition	= mul(PerViewConstantBuffer.WorldToClip, OUT.SVPosition);
#if OBJECT_NEEDS_NORMAL
	OUT.Normal		= IN.Normal;
#endif
#if OBJECT_NEEDS_TANGENT
	OUT.Tangent		= IN.Tangent;
#endif
#if OBJECT_NEEDS_BINORMAL
	OUT.Binormal	= IN.Binormal;
#endif
#if OBJECT_NEEDS_UV
	OUT.UV			= IN.UV;
#endif

	return OUT;
}
