using System;

namespace BicepNet.Core.Models;

public class BicepRepositoryModuleTag(string name, string digest, string target, DateTimeOffset createdOn, DateTimeOffset updatedOn)
{
    public string Name { get; } = name;
    public string Digest { get; } = digest;
    public string Target { get; } = target;

    public DateTimeOffset CreatedOn { get; } = createdOn;
    public DateTimeOffset UpdatedOn { get; } = updatedOn;

    public override string ToString() => Name;
}
