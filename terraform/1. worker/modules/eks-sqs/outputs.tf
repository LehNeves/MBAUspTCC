output "worker_queue_arn" {
  value       = aws_sqs_queue.worker_queue.arn
  description = "ARN da fila SQS"
}
