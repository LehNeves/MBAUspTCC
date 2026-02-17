using Amazon.SQS;
using Amazon.SQS.Model;

namespace Fibonacci;

public class Worker(ILogger<Worker> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var clientSQS = new AmazonSQSClient(Amazon.RegionEndpoint.SAEast1);

            var mensagens = await SQSFibonacci.LerMensagensAsync(clientSQS);

            foreach (var mensagem in mensagens)
            {
                await ProcessMessageAsync(mensagem);
                await clientSQS.DeleteMessageAsync("https://sqs.sa-east-1.amazonaws.com/676617883170/FibonacciWorkerSQS", mensagem.ReceiptHandle);
            }
        }
    }

    private async Task ProcessMessageAsync(Message mensagem)
    {
        int numero = int.Parse(mensagem.Body);
        bool resultado = EhFibonacci(numero);

        logger.LogInformation(string.Format("O número \"{0}\" {1}pertence a sequência de Fibonacci!", numero, resultado ? "" : "não "));

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
