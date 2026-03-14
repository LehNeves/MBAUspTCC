output "lambda_queue_arn" {
  value = aws_sqs_queue.lambda_queue.arn
}

output "lambda_queue_url" {
  value = aws_sqs_queue.lambda_queue.id
}
