using Amazon.SQS;
using Amazon.SQS.Model;

namespace Fibonacci;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;
    private readonly IAmazonSQS _sqsClient;
    readonly string _queueUrl;
    readonly int _batchSize;
    readonly int _polling;

    public Worker(ILogger<Worker> logger, IAmazonSQS sqsClient, IConfiguration config)
    {
        _logger = logger;
        _sqsClient = sqsClient;
        _queueUrl = config["SQS_QUEUE_URL"] ?? throw new Exception("SQS_QUEUE_URL missing");
        _batchSize = config.GetValue<int?>("WORKER_BATCH_SIZE") ?? 1;
        _polling = config.GetValue<int?>("POLL_INTERVAL_SECONDS") ?? 20;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            var request = new ReceiveMessageRequest
            {
                QueueUrl = _queueUrl,
                MaxNumberOfMessages = _batchSize,
                WaitTimeSeconds = _polling
            };

            var response = await _sqsClient.ReceiveMessageAsync(request, stoppingToken);

            var messages = response?.Messages ?? [];

            foreach (var mensagem in messages)
            {
                await ProcessMessageAsync(mensagem);
                await _sqsClient.DeleteMessageAsync(_queueUrl, mensagem.ReceiptHandle, stoppingToken);
            }
        }
    }

    private async Task ProcessMessageAsync(Message mensagem)
    {
        int numero = int.Parse(mensagem.Body);
        bool resultado = EhFibonacci(numero);

        _logger.LogInformation(string.Format("O número \"{0}\" {1}pertence a sequência de Fibonacci!", numero, resultado ? "" : "não "));
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
