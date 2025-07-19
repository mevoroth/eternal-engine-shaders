using Sharpmake;

[module: Sharpmake.Include(@"..\eternal-engine\eternal-engine-project.sharpmake.cs")]

namespace EternalEngine
{
	public class EternalEngineShadersProjectUtils
	{
		public static void Construct(Project InProject)
		{
			InProject.SourceFilesExtensions.Add(".hlsl");
			InProject.ExtensionBuildTools[".hlsl"] = "FxCompile";
		}

		public static void ConfigureAll(Project.Configuration InConfiguration, ITarget InTarget)
		{
			InConfiguration.Output = Project.Configuration.OutputType.Utility;
			InConfiguration.SourceFilesBuildExcludeRegex.Add(@".*\.hlsl$");
		}
	}

	[Sharpmake.Generate]
	public class EternalEngineShadersProject : EternalEngineBaseProject
	{
		public EternalEngineShadersProject()
			: base(
				typeof(Target),
				"shaders"
			)
		{
			EternalEngineShadersProjectUtils.Construct(this);
		}

		public override void ConfigureAll(Configuration InConfiguration, ITarget InTarget)
		{
			base.ConfigureAll(InConfiguration, InTarget);
			EternalEngineShadersProjectUtils.ConfigureAll(InConfiguration, InTarget);
		}
	}

	[Sharpmake.Generate]
	public class EternalEngineShadersAndroidProject : EternalEngineBaseAndroidProject
	{
		public EternalEngineShadersAndroidProject()
			: base(
				typeof(AndroidTarget),
				"shaders"
			)
		{
			EternalEngineShadersProjectUtils.Construct(this);
		}

		public override void ConfigureAll(Configuration InConfiguration, ITarget InTarget)
		{
			base.ConfigureAll(InConfiguration, InTarget);
			EternalEngineShadersProjectUtils.ConfigureAll(InConfiguration, InTarget);
		}
	}
}
