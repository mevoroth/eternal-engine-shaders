#if ETERNAL_PLATFORM_VULKAN

#define VOID_RESOURCE(ResourceType, ResourceName)									

#define VULKAN_STRINGIFY(TEXT)														#TEXT
#define VULKAN_CONCATENATE_REGISTER(Binding, ShaderResource)						Binding ShaderResource

#define REGISTER_T(ShaderResource, Index, Set)										VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_SHADER_RESOURCES*/, Set)]],		ShaderResource)
#define REGISTER_B(ShaderResource, Index, Set)										VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_CONSTANT_BUFFERS*/, Set)]],		ShaderResource)
#define REGISTER_U(ShaderResource, Index, Set)										VULKAN_CONCATENATE_REGISTER([[vk::binding(Index + REGISTER_OFFSET_UNORDERED_ACCESSES, Set)]],		ShaderResource)
#define REGISTER_S(ShaderResource, Index, Set)										VULKAN_CONCATENATE_REGISTER([[vk::binding(Index /*+ REGISTER_OFFSET_SAMPLERS*/, Set)]],				ShaderResource)

#define CONSTANT_BUFFER(StructName, BufferName, Index, Set)							struct StructName##_Internal { \
																						StructName InternalValue; \
																					}; \
																					REGISTER_B(ConstantBuffer<StructName##_Internal> BufferName##_Internal, Index, Set); \
																					static StructName BufferName = BufferName##_Internal.InternalValue

#define RW_RESOURCE(ResourceType, Type, FormatType, ResourceName, Index, Set)		[[spv::FormatType]] \
																					REGISTER_U(ResourceType<Type> ResourceName, Index, Set)

#endif
