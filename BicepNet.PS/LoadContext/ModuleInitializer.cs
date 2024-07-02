using System.IO;
using System.Management.Automation;
using System.Reflection;
using System.Runtime.Loader;

namespace BicepNet.PS.LoadContext;

public class BicepNetModuleInitializer : IModuleAssemblyInitializer
{
    private static readonly string s_binBasePath = Path.GetFullPath(
        Path.Combine(
            Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location),
            ".."));

    private static readonly string s_binCommonPath = Path.Combine(s_binBasePath, "BicepNet.Core");

    public void OnImport()
    {
        AssemblyLoadContext.Default.Resolving += ResolveAssembly_NetCore;
    }

    private static Assembly ResolveAssembly_NetCore(
        AssemblyLoadContext assemblyLoadContext,
        AssemblyName assemblyName)
    {
        // In .NET Core, PowerShell deals with assembly probing so our logic is much simpler
        // We only care about our Engine assembly
        if (!assemblyName.Name.Equals("BicepNet.Core"))
        {
            return null;
        }

        // Now load the Engine assembly through the dependency ALC, and let it resolve further dependencies automatically
        return DependencyAssemblyLoadContext.GetForDirectory(s_binCommonPath).LoadFromAssemblyName(assemblyName);
    }
}
