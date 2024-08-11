using Bicep.Core.Diagnostics;
using Bicep.Core.Semantics;
using Bicep.Core.Text;
using Bicep.Core.Workspaces;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;
using System.Management.Automation;

namespace PSBicep.Core.Logging;

public record DiagnosticSummary(
    bool HasErrors);

public record DiagnosticOptions(
    DiagnosticsFormat Format,
    bool SarifToStdout)
{
    public static DiagnosticOptions Default => new(
        Format: DiagnosticsFormat.Default,
        SarifToStdout: false);
}

public enum DiagnosticsFormat
{
    Default,
    Sarif
}

public class DiagnosticLogger(PSCmdlet cmdlet) : ILogger
{
    private readonly PSCmdlet cmdlet = cmdlet;

    public DiagnosticSummary LogDiagnostics(Compilation compilation)
    {
        if (compilation is null)
        {
            throw new InvalidOperationException("Compilation is null. A compilation must exist before logging the diagnostics.");
        }

        return LogDiagnostics(
            new DiagnosticOptions(DiagnosticsFormat.Default, false),
            compilation
        );
    }

    public DiagnosticSummary LogDiagnostics(DiagnosticOptions options, Compilation compilation)
        => LogDiagnostics(options, compilation.GetAllDiagnosticsByBicepFile());

    public DiagnosticSummary LogDiagnostics(DiagnosticOptions options, ImmutableDictionary<BicepSourceFile, ImmutableArray<IDiagnostic>> diagnosticsByBicepFile)
    {
        switch (options.Format)
        {
            case DiagnosticsFormat.Default:
                LogDefaultDiagnostics(cmdlet, diagnosticsByBicepFile);
                break;
            case DiagnosticsFormat.Sarif:
                throw new NotImplementedException("SARIF logging is not implemented.");
            default:
                throw new ArgumentOutOfRangeException(nameof(options.Format), "Unsupported diagnostics format.");
        }

        var hasErrors = diagnosticsByBicepFile.Values.SelectMany(x => x).Any(x => x.Level == DiagnosticLevel.Error);

        return new DiagnosticSummary(
            HasErrors: hasErrors);
    }

    private void LogDefaultDiagnostics(PSCmdlet cmdlet, ImmutableDictionary<BicepSourceFile, ImmutableArray<IDiagnostic>> diagnosticsByBicepFile)
    {
        foreach (var (bicepFile, diagnostics) in diagnosticsByBicepFile)
        {
            foreach (var diagnostic in diagnostics)
            {
                (var line, var character) = TextCoordinateConverter.GetPosition(bicepFile.LineStarts, diagnostic.Span.Position);

                // build a a code description link if the Uri is assigned
                var codeDescription = diagnostic.Uri == null ? string.Empty : $" [{diagnostic.Uri.AbsoluteUri}]";

                var message = $"{bicepFile.FileUri.LocalPath}({line + 1},{character + 1}) : {diagnostic.Level} {diagnostic.Code}: {diagnostic.Message}{codeDescription}";
                
                WriteLog(diagnosticToLogLevel[diagnostic.Level], message);
            }
        }
    }

    private void WriteLog(LogLevel logLevel, string message, Exception? exception = null)
    {
        switch (logLevel)
        {
            case LogLevel.Trace:
                cmdlet.WriteVerbose(message);
                break;
            case LogLevel.Debug:
                cmdlet.WriteDebug(message);
                break;
            case LogLevel.Information:
                HostInformationMessage informationMessage = new() { Message = message };
                cmdlet.WriteInformation(informationMessage, ["PSHOST"]);
                break;
            case LogLevel.Warning:
                cmdlet.WriteWarning(message);
                break;
            case LogLevel.Error:
                cmdlet.WriteError(new ErrorRecord(exception ?? new Exception(message), cmdlet.MyInvocation.InvocationName, ErrorCategory.WriteError, null));
                break;
            default:
                break;
        }
    }

    private readonly List<LogLevel> logLevels = [
        LogLevel.Trace,
        LogLevel.Debug,
        LogLevel.Information,
        LogLevel.Warning,
        LogLevel.Error
    ];

    private readonly Dictionary<DiagnosticLevel, LogLevel> diagnosticToLogLevel = new()
    {
        { DiagnosticLevel.Info,  LogLevel.Information},
        { DiagnosticLevel.Warning, LogLevel.Warning },
        { DiagnosticLevel.Error, LogLevel.Error  }
    };

    public IDisposable? BeginScope<TState>(TState state) where TState : notnull => default!;

    public bool IsEnabled(LogLevel logLevel) => logLevels.Contains(logLevel);

    public void Log<TState>(
        LogLevel logLevel,
        EventId eventId,
        TState state,
        Exception? exception,
        Func<TState, Exception?, string> formatter)
    {
        if (!IsEnabled(logLevel))
        {
            return;
        }

        WriteLog(logLevel, formatter(state, exception), exception);
    }

}
