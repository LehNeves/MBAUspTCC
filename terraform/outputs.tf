output "aws_region" {
  description = "Região AWS utilizada"
  value       = var.aws_region
}

output "project_name" {
  value = var.project_name
}

output "sns_topic_arn" {
  description = "ARN do SNS Fan-out Topic"
  value       = aws_sns_topic.fanout_topic.arn
}

output "ecr_repository_url" {
  description = "URL do repositório ECR do Worker"
  value       = aws_ecr_repository.worker_repo.repository_url
}

output "worker_queue_arn" {
  value = aws_sqs_queue.worker_queue.arn
}

output "lambda_queue_arn" {
  value = aws_sqs_queue.lambda_queue.arn
}

output "worker_queue_url" {
  value = aws_sqs_queue.worker_queue.id
}

output "lambda_queue_url" {
  value = aws_sqs_queue.lambda_queue.id
}
