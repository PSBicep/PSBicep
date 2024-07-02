using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace BicepNet.PS.Commands;

public partial class BicepNetBaseCommand : ILogger
{
    private readonly List<LogLevel> logLevels = [
        LogLevel.Trace,
        LogLevel.Debug,
        LogLevel.Information,
        LogLevel.Warning,
        LogLevel.Error
    ];

    public IDisposable BeginScope<TState>(TState state) => default!;

    public bool IsEnabled(LogLevel logLevel) => logLevels.Contains(logLevel);

    public void Log<TState>(
        LogLevel logLevel,
        EventId eventId,
        TState state,
        Exception exception,
        Func<TState, Exception, string> formatter)
    {
        if (!IsEnabled(logLevel))
        {
            return;
        }

        switch (logLevel)
        {
            case LogLevel.Trace:
                WriteVerbose(formatter(state, exception));
                break;
            case LogLevel.Debug:
                WriteDebug(formatter(state, exception));
                break;
            case LogLevel.Information:
                WriteVerbose(formatter(state, exception));
                break;
            case LogLevel.Warning:
                WriteWarning(formatter(state, exception));
                break;
            case LogLevel.Error:
                WriteError(new ErrorRecord(exception ?? new Exception(formatter(state, exception)), name, ErrorCategory.WriteError, null));
                break;
            default:
                break;
        }
    }
}
