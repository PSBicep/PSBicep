using System;
using System.Collections.Concurrent;
using System.IO;
using System.Reflection;
using System.Runtime.Loader;

namespace BicepNet.PS.LoadContext;

public class DependencyAssemblyLoadContext(string dependencyDirPath) : AssemblyLoadContext(nameof(DependencyAssemblyLoadContext))
{
    private static readonly string s_psHome = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);
    
    private static readonly ConcurrentDictionary<string, DependencyAssemblyLoadContext> s_dependencyLoadContexts = new();

    internal static DependencyAssemblyLoadContext GetForDirectory(string directoryPath)
    {
        return s_dependencyLoadContexts.GetOrAdd(directoryPath, (path) => new DependencyAssemblyLoadContext(path));
    }

    private readonly string _dependencyDirPath = dependencyDirPath;

    protected override Assembly Load(AssemblyName assemblyName)
    {
        string assemblyFileName = $"{assemblyName.Name}.dll";

        // Make sure we allow other common PowerShell dependencies to be loaded by PowerShell
        // But specifically exclude certain assemblies like Newtonsoft.Json and System.Text.Json since we want to use different versions here for Bicep
        if (!assemblyName.Name.Equals("Newtonsoft.Json", StringComparison.OrdinalIgnoreCase) &&
            !assemblyName.Name.Equals("System.Text.Json", StringComparison.OrdinalIgnoreCase) &&
            !assemblyName.Name.Equals("System.Text.Encodings.Web", StringComparison.OrdinalIgnoreCase))
        {
            string psHomeAsmPath = Path.Join(s_psHome, assemblyFileName);
            if (File.Exists(psHomeAsmPath))
            {
                // With this API, returning null means nothing is loaded
                return null;
            }
        }

        // Now try to load the assembly from the dependency directory
        string dependencyAsmPath = Path.Join(_dependencyDirPath, assemblyFileName);
        if (File.Exists(dependencyAsmPath))
        {
            return LoadFromAssemblyPath(dependencyAsmPath);
        }

        return null;
    }
}