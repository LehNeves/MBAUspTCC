using Amazon.SQS;
using Amazon.SQS.Model;

namespace Fibonacci;

internal static class SQSFibonacci
{
    public async static Task<IEnumerable<Message>> LerMensagensAsync(AmazonSQSClient clientSQS)
    {
        string SQS_QUEUE_URL = Environment.GetEnvironmentVariable("URL_WORKER_SNS") ?? throw new Exception("Environment variable URL_WORKER_SNS not defined"); ;
        int WORKER_BATCH_SIZE = int.Parse(Environment.GetEnvironmentVariable("WORKER_BATCH_SIZE" ?? "1")!);
        int POLL_INTERVAL_SECONDS = int.Parse(Environment.GetEnvironmentVariable("POLL_INTERVAL_SECONDS") ?? "20");

        var requisicao = new ReceiveMessageRequest
        {
            QueueUrl = SQS_QUEUE_URL,
            MaxNumberOfMessages = WORKER_BATCH_SIZE,
            WaitTimeSeconds = POLL_INTERVAL_SECONDS
        };

        var resultado = await clientSQS.ReceiveMessageAsync(requisicao);
        return resultado.Messages ?? [];
    }
}
