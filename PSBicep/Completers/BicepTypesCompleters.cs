using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using PSBicep.LoadContext;

namespace PSBicep.Completers;

internal static class BicepTypeCompletion
{
    internal static CompletionResult Create(string completionText, string toolTip, string listItemText = null) =>
        new(completionText, listItemText ?? completionText, CompletionResultType.ParameterValue, toolTip);

    internal static string GetBoundValue(IDictionary parameters, string name) =>
        parameters.Contains(name) ? parameters[name]?.ToString() ?? string.Empty : string.Empty;

    internal static IEnumerable<CompletionResult> CompleteApiVersions(string resourceType, string wordToComplete)
    {
        try
        {
            return BicepLoader.PSBicep.coreService.GetApiVersions(resourceType)
                .Where(version => version.StartsWith(wordToComplete, StringComparison.OrdinalIgnoreCase))
                .Select(version => Create(version, $"{resourceType}@{version}"));
        }
        catch (ArgumentException)
        {
            return [];
        }
        catch (InvalidOperationException)
        {
            return [];
        }
    }
}

public sealed class BicepResourceProviderCompleter : IArgumentCompleter
{
    public IEnumerable<CompletionResult> CompleteArgument(
        string commandName,
        string parameterName,
        string wordToComplete,
        CommandAst commandAst,
        IDictionary fakeBoundParameters) =>
        BicepLoader.PSBicep.coreService.GetResourceProviderNames(wordToComplete ?? string.Empty)
            .Select(provider => BicepTypeCompletion.Create(provider, provider));
}

public sealed class BicepResourceCompleter : IArgumentCompleter
{
    public IEnumerable<CompletionResult> CompleteArgument(
        string commandName,
        string parameterName,
        string wordToComplete,
        CommandAst commandAst,
        IDictionary fakeBoundParameters)
    {
        var provider = BicepTypeCompletion.GetBoundValue(fakeBoundParameters, "ResourceProvider");

        return BicepLoader.PSBicep.coreService
            .GetResourceTypeNames(provider, wordToComplete ?? string.Empty, fullyQualified: true)
            .Select(resourceType => BicepTypeCompletion.Create(
                resourceType.Split('/')[^1],
                resourceType));
    }
}

public sealed class BicepResourceChildCompleter : IArgumentCompleter
{
    public IEnumerable<CompletionResult> CompleteArgument(
        string commandName,
        string parameterName,
        string wordToComplete,
        CommandAst commandAst,
        IDictionary fakeBoundParameters)
    {
        var provider = BicepTypeCompletion.GetBoundValue(fakeBoundParameters, "ResourceProvider");
        var resource = BicepTypeCompletion.GetBoundValue(fakeBoundParameters, "Resource");

        return BicepLoader.PSBicep.coreService
            .GetChildResourceTypeNames(provider, resource, wordToComplete ?? string.Empty, fullyQualified: true)
            .Select(childType =>
            {
                int firstSlash = childType.IndexOf('/');
                int secondSlash = childType.IndexOf('/', firstSlash + 1);

                return BicepTypeCompletion.Create(
                    childType[(secondSlash + 1)..],
                    childType);
            });
    }
}

public sealed class BicepResourceApiVersionCompleter : IArgumentCompleter
{
    public IEnumerable<CompletionResult> CompleteArgument(
        string commandName,
        string parameterName,
        string wordToComplete,
        CommandAst commandAst,
        IDictionary fakeBoundParameters)
    {
        var provider = BicepTypeCompletion.GetBoundValue(fakeBoundParameters, "ResourceProvider");
        var resource = BicepTypeCompletion.GetBoundValue(fakeBoundParameters, "Resource");

        if (string.IsNullOrEmpty(provider) || string.IsNullOrEmpty(resource))
        {
            return [];
        }

        var child = BicepTypeCompletion.GetBoundValue(fakeBoundParameters, "Child");
        var resourceType = string.IsNullOrEmpty(child)
            ? $"{provider}/{resource}"
            : $"{provider}/{resource}/{child}";

        return BicepTypeCompletion.CompleteApiVersions(resourceType, wordToComplete ?? string.Empty);
    }
}

public abstract class BicepTypeCompleter : IArgumentCompleter
{
    protected abstract bool IncludeApiVersions { get; }

    public IEnumerable<CompletionResult> CompleteArgument(
        string commandName,
        string parameterName,
        string wordToComplete,
        CommandAst commandAst,
        IDictionary fakeBoundParameters)
    {
        wordToComplete ??= string.Empty;

        if (!wordToComplete.Contains('/'))
        {
            return BicepLoader.PSBicep.coreService.GetResourceProviderNames(wordToComplete)
                .Select(provider => BicepTypeCompletion.Create($"{provider}/", provider));
        }

        return BicepLoader.PSBicep.coreService.GetResourceTypeNamesByPrefix(wordToComplete, IncludeApiVersions)
            .Select(type => BicepTypeCompletion.Create(type, type));
    }
}

public sealed class BicepTypeCompleterWithApiVersions : BicepTypeCompleter
{
    protected override bool IncludeApiVersions => true;
}

public sealed class BicepTypeCompleterWithoutApiVersions : BicepTypeCompleter
{
    protected override bool IncludeApiVersions => false;
}
