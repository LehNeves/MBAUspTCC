using Amazon.SQS;
using Amazon.SQS.Model;

namespace Fibonacci;

internal static class SQSFibonacci
{
    public async static Task<IEnumerable<Message>> LerMensagensAsync(AmazonSQSClient clientSQS)
    {
        var requisicao = new ReceiveMessageRequest
        {
            QueueUrl = "",
            MaxNumberOfMessages = 10,
            WaitTimeSeconds = 10
        };

        var resultado = await clientSQS.ReceiveMessageAsync(requisicao);
        return resultado.Messages ?? [];
    }
}
