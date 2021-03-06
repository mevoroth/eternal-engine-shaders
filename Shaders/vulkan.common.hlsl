#if PLATFORM_VULKAN

#define VULKAN_CONCATENATE_REGISTER(Binding, ShaderResource)			Binding ShaderResource

#define REGISTER_T(ShaderResource, Index, Set)							VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_SHADER_RESOURCES*/, Set)]],		ShaderResource)
#define REGISTER_B(ShaderResource, Index, Set)							VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_CONSTANT_BUFFERS*/, Set)]],		ShaderResource)
#define REGISTER_U(ShaderResource, Index, Set)							VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_UNORDERED_ACCESSES*/, Set)]],	ShaderResource)
#define REGISTER_S(ShaderResource, Index, Set)							VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_SAMPLERS*/, Set)]],				ShaderResource)

#endif
