resource "aws_sns_topic" "fanout_topic" {
  name = "${local.name_prefix}-fanout-topic"

  tags = {
    Project     = var.project_name
    Purpose     = "fanout-comparison"
  }
}

resource "aws_sns_topic_policy" "fanout_policy" {
  arn = aws_sns_topic.fanout_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "SNS:Publish"
      Resource  = aws_sns_topic.fanout_topic.arn
    }]
  })
}

resource "aws_sqs_queue_policy" "worker_queue_policy" {
  queue_url = aws_sqs_queue.worker_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "Allow-SNS-SendMessage"
      Effect    = "Allow"
      Principal = "*"
      Action    = "SQS:SendMessage"
      Resource  = aws_sqs_queue.worker_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.fanout_topic.arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "lambda_queue_policy" {
  queue_url = aws_sqs_queue.lambda_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "Allow-SNS-SendMessage"
      Effect    = "Allow"
      Principal = "*"
      Action    = "SQS:SendMessage"
      Resource  = aws_sqs_queue.lambda_queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_sns_topic.fanout_topic.arn
        }
      }
    }]
  })
}

resource "aws_sns_topic_subscription" "worker_subscription" {
  topic_arn = aws_sns_topic.fanout_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.worker_queue.arn

  raw_message_delivery = true
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  topic_arn = aws_sns_topic.fanout_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.lambda_queue.arn

  raw_message_delivery = true
}
