resource "aws_sqs_queue" "worker_dlq" {
  name = "${var.project_name}-worker-queue-dlq"

  message_retention_seconds = 259200

  tags = {
    Project     = var.project_name
    UsedBy      = "worker"
    Type        = "dlq"
  }
}

resource "aws_sqs_queue" "worker_queue" {
  name = "${var.project_name}-worker-queue"

  visibility_timeout_seconds = 30
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
