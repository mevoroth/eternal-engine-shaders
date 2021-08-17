#include "opaque.common.hlsl"
#include "ShadersReflection/HLSLPerDrawConstants.hpp"

REGISTER_B(ConstantBuffer<PerDrawConstants> PerDrawConstantBuffer,	0, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(								1, 0);

PSIn VS( VSIn IN )
{
	PSIn OUT = (PSIn)0;

	OUT.SVPosition	= mul(PerDrawConstantBuffer.SubMeshToLocal, IN.Position);
	OUT.SVPosition	= mul(PerViewConstantBuffer.WorldToClip, OUT.SVPosition);
	OUT.Normal		= IN.Normal;
	OUT.Tangent		= IN.Tangent;
	OUT.Binormal	= IN.Binormal;
	OUT.UV			= IN.UV;

	return OUT;
}
