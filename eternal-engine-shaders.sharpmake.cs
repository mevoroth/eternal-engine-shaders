using Sharpmake;

[module: Sharpmake.Include(@"..\eternal-engine\eternal-engine.sharpmake.cs")]

namespace EternalEngine
{
	[Sharpmake.Generate]
	public class EternalEngineShadersProject : EternalEngineProject
	{
		public EternalEngineShadersProject()
			: base("shaders")
		{
			SourceFilesExtensions.Add(".hlsl");
			ExtensionBuildTools[".hlsl"] = "FxCompile";
		}

		public override void ConfigureAll(Configuration InConfiguration, Target InTarget)
		{
			base.ConfigureAll(InConfiguration, InTarget);

			InConfiguration.Output = Configuration.OutputType.Utility;
			InConfiguration.SourceFilesBuildExcludeRegex.Add(@".*\.hlsl$");
		}
	}
}
