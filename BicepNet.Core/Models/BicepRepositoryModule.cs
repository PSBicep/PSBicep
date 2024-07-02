using System;
using System.Collections.Generic;
using System.Linq;

namespace BicepNet.Core.Models;

public class BicepRepositoryModule(string digest, string repository, List<BicepRepositoryModuleTag> tags, DateTimeOffset createdOn, DateTimeOffset updatedOn)
{
    public string Digest { get; } = digest;
    public string Repository { get; } = repository;
    public List<BicepRepositoryModuleTag> Tags { get; } = tags;
    public DateTimeOffset CreatedOn { get; } = createdOn;
    public DateTimeOffset UpdatedOn { get; } = updatedOn;

    // Return a string of comma-separated tags or 'null'
    public override string ToString()
        => Tags.Count != 0 ? string.Join(", ", Tags.OrderByDescending(t => t.UpdatedOn).Select(t => t.ToString())) : "null";
}
