namespace PSBicep.Models;

public class BicepConfigInfo
{
    public BicepConfigInfo(string path, string config) => (Path, Config) = (path, config);
    public BicepConfigInfo(PSBicep.Core.Models.BicepConfigInfo config) => (Path, Config) = (config.Path, config.Config);
    
    public string Path { get; }
    public string Config { get; }

    public override string ToString() => Config;
}
