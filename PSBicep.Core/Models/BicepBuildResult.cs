namespace PSBicep.Core.Models;

public record BuildResult(
    string? Parameters,
    string? TemplateSpecId,
    string? Template,
    string? SourceMap);
