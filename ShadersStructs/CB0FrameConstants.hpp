#ifndef _CB0_FRAME_CONSTANTS_HPP_
#define _CB0_FRAME_CONSTANTS_HPP_

#include "Types/Types.hpp"

namespace Eternal
{
	namespace Shaders
	{
		using namespace Eternal::Types;
		struct CB0FrameConstants
		{
			Matrix4x4 ViewProjection;
			Matrix4x4 ViewProjectionInverse;
			Vector4 CameraPosition;
		};
	}
}

#endif
