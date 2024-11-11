#if ETERNAL_PLATFORM_DX12

#if ETERNAL_PLATFORM_FXC
#define VOID_RESOURCE(ResourceType, ResourceName)									(ResourceType)ResourceName;
#else
#define VOID_RESOURCE(ResourceType, ResourceName)									(void)ResourceName;
#endif

#define DX12_CONCATENATE_REGISTER(ShaderResource, Register)							ShaderResource Register

#define REGISTER_T(ShaderResource, Index, Set)										DX12_CONCATENATE_REGISTER(ShaderResource, : register(t##Index))
#define REGISTER_B(ShaderResource, Index, Set)										DX12_CONCATENATE_REGISTER(ShaderResource, : register(b##Index))
#define REGISTER_U(ShaderResource, Index, Set)										DX12_CONCATENATE_REGISTER(ShaderResource, : register(u##Index))
#define REGISTER_S(ShaderResource, Index, Set)										DX12_CONCATENATE_REGISTER(ShaderResource, : register(s##Index))

#define CONSTANT_BUFFER(StructName, BufferName, Index, Set)							REGISTER_B(ConstantBuffer<StructName> BufferName, Index, Set)
#define RW_RESOURCE(ResourceType, Type, FormatType, ResourceName, Index, Set)		REGISTER_U(ResourceType<Type> ResourceName, Index, Set)

#endif
