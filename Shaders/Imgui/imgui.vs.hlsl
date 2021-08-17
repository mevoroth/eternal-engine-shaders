#include "imgui/imgui.common.hlsl"

REGISTER_B(ConstantBuffer<ProjectionConstants> ProjectionConstantBuffer,	0, 0);

PSIn VS( VSIn IN )
{
	PSIn OUT = (PSIn)0;
	OUT.SVPosition	= mul(ProjectionConstantBuffer.ProjectionMatrix, float4(IN.Position.xy, 0.0f, 1.0f));
	OUT.Color		= IN.Color;
	OUT.UV			= IN.UV;
	return OUT;
}
