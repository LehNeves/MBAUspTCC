resource "aws_lambda_function" "fibonacci" {
  function_name = "${var.project_name}-lambda"
  role          = var.lambda_role_arn
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:${var.image_tag}"

  timeout     = 30
  memory_size = 512

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.lambda_queue_arn
  function_name    = aws_lambda_function.fibonacci.arn
  batch_size       = 10
  enabled          = true
}
