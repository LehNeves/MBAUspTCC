using System.Diagnostics.Tracing;

namespace Fibonacci;

internal class OtelDiagnosticListener : EventListener
{
    protected override void OnEventSourceCreated(EventSource source)
    {
        if (source.Name.StartsWith("OpenTelemetry"))
            EnableEvents(source, EventLevel.Verbose);
    }

    protected override void OnEventWritten(EventWrittenEventArgs e)
    {
        // Ignora EventCounters (ruído)  
        if (e.EventName == "EventCounters") return;

        var msg = string.Join(", ", e.Payload ?? []);
        Console.WriteLine($"[OTEL-DIAG] {e.Level} | {e.EventName}: {msg}");
    }
}
