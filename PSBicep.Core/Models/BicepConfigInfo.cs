﻿namespace PSBicep.Core.Models;

public class BicepConfigInfo(string path, string config)
{
    public string Path { get; } = path;
    public string Config { get; } = config;

    public override string ToString() => Config;
}
