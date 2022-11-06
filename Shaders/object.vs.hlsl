#include "object.common.hlsl"

CONSTANT_BUFFER(PerDrawConstants, PerDrawConstantBuffer,			0, 0);
REGISTER_B_PER_VIEW_CONSTANT_BUFFER(								1, 0);

PSIn VS( VSIn IN )
{
	PSIn OUT = ComputePSIn(IN, PerDrawConstantBuffer, PerViewConstantBuffer);

	return OUT;
}
