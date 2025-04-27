using System;
using System.Collections.Immutable;

namespace PSBicep.Core.Models;

public class BicepResourceTypeReference
{
    public BicepResourceTypeReference(string type, string? version)
    {
        if (type.Length <= 0)
        {
            throw new ArgumentException("Type must be non-empty.");
        }

        Name = version is null ? type : $"{type}@{version}";
        Type = type;
        TypeSegments = [.. type.Split('/')];
        ApiVersion = version;
    }

    public ImmutableArray<string> TypeSegments { get; }
    public string Name { get; }
    public string Type { get; }
    public string? ApiVersion { get; }
    public override string ToString() => this.Name;
}
