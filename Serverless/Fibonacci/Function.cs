using Amazon.Lambda.Core;
using Amazon.Lambda.SQSEvents;
using OpenTelemetry;
using OpenTelemetry.Instrumentation.AWSLambda;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;


// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace Fibonacci;

public class Function
{
    /// <summary>
    /// Default constructor. This constructor is used by Lambda to construct the instance. When invoked in a Lambda environment
    /// the AWS credentials will come from the IAM role associated with the function and the AWS region will be set to the
    /// region the Lambda function is executed in.
    /// </summary>
    public Function()
    {
        var endpoint = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT")!;
        var headers = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_HEADERS")!;

        Sdk.CreateTracerProviderBuilder()
            .SetResourceBuilder(ResourceBuilder.CreateDefault()
                .AddService("lambda-tcc"))
            .AddAWSLambdaConfigurations()
            .AddHttpClientInstrumentation()
            .AddOtlpExporter(options =>
            {
                options.Endpoint = new Uri(endpoint);
                options.Headers = headers;
            })
            .Build();
    }

    /// <summary>
    /// This method is called for every Lambda invocation. This method takes in an SQS event object and can be used 
    /// to respond to SQS messages.
    /// </summary>
    /// <param name="evnt">The event for the Lambda function handler to process.</param>
    /// <param name="context">The ILambdaContext that provides methods for logging and describing the Lambda environment.</param>
    /// <returns></returns>
    public async Task FunctionHandler(SQSEvent evnt, ILambdaContext context)
    {
        foreach(var message in evnt.Records)
        {
            await ProcessMessageAsync(message, context);
        }
    }

    private async Task ProcessMessageAsync(SQSEvent.SQSMessage message, ILambdaContext context)
    {
        int numero = int.Parse(message.Body);
        bool resultado =  EhFibonacci(numero);

        context.Logger.LogInformation(string.Format("O número \"{0}\" {1}pertence a sequência de Fibonacci!", numero, resultado ? "" : "não "));

        // TODO: Do interesting work based on the new message
        await Task.CompletedTask;
    }

    private static bool EhFibonacci(int valor)
    {
        if (valor < 0) return false;
        if (valor == 0 || valor == 1) return true;

        int anterior = 0;
        int atual = 1;

        while (atual < valor)
        {
            int temp = anterior + atual;
            anterior = atual;
            atual = temp;
        }

        return atual == valor;
    }
}