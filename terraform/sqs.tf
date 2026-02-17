resource "aws_sqs_queue" "worker_dlq" {
  name = "${local.name_prefix}-worker-dlq"

  message_retention_seconds = 259200

  tags = {
    Project     = var.project_name
    UsedBy      = "worker"
    Type        = "dlq"
  }
}

resource "aws_sqs_queue" "lambda_dlq" {
  name = "${local.name_prefix}-lambda-dlq"

  message_retention_seconds = 259200

  tags = {
    Project     = var.project_name
    UsedBy      = "lambda"
    Type        = "dlq"
  }
}

resource "aws_sqs_queue" "worker_queue" {
  name = "${local.name_prefix}-worker-queue"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 259200

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.worker_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Project     = var.project_name
    UsedBy      = "worker"
    Type        = "main"
  }
}

resource "aws_sqs_queue" "lambda_queue" {
  name = "${local.name_prefix}-lambda-queue"

  visibility_timeout_seconds = 60
  message_retention_seconds  = 259200

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.lambda_dlq.arn
    maxReceiveCount     = 5
  })

  tags = {
    Project     = var.project_name
    UsedBy      = "lambda"
    Type        = "main"
  }
}
