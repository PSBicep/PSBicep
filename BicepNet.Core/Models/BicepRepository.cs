using System.Collections.Generic;

namespace BicepNet.Core.Models;

public class BicepRepository(string name, string endpoint)
{
    public string Name { get; } = name;
    public string Endpoint { get; } = endpoint;
    public IList<BicepRepositoryModule> ModuleVersions { get; set; } = [];

    public override string ToString() => Name;
}
