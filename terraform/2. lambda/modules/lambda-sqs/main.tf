resource "aws_sqs_queue" "lambda_dlq" {
  name = "${var.project_name}-lambda-queue-dlq"

  message_retention_seconds = 259200

  tags = {
    Project = var.project_name
    UsedBy  = "lambda"
    Type    = "dlq"
  }
}

resource "aws_sqs_queue" "lambda_queue" {
  name = "${var.project_name}-lambda-queue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 259200

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lambda_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Project = var.project_name
    UsedBy  = "lambda"
    Type    = "main"
  }
}
