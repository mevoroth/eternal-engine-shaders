#ifndef _CB1_LIGHT_CONSTANTS_HPP_
#define _CB1_LIGHT_CONSTANTS_HPP_

#include "Types/Types.hpp"

namespace Eternal
{
	namespace Shaders
	{
		using namespace Eternal::Types;
		struct Light
		{
			Vector4 Position;
			Vector4 Color;
			float Distance;
			float Intensity;
		};
		struct CB1LightConstants
		{
			Light Lights[8];
			int LightsCount;
		};
	}
}

#endif
