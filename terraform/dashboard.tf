resource "aws_cloudwatch_dashboard" "experiment_dashboard" {
  dashboard_name = "architecture-experiment"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          title = "SNS Messages Published"
          region = "${var.aws_region}"
          metrics = [
            [ "AWS/SNS", "NumberOfMessagesPublished", "TopicName", "events-topic" ]
          ]
          period = 60
          stat   = "Sum"
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6
        properties = {
          title = "Queue Size"
          region = "${var.aws_region}"
          metrics = [
            [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "events-queue" ]
          ]
          stat = "Average"
          period = 60
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 6
        width = 12
        height = 6
        properties = {
          title = "Lambda Invocations"
          region = "${var.aws_region}"
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", "message-processor" ]
          ]
          stat = "Sum"
          period = 60
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 6
        width = 12
        height = 6
        properties = {
          title = "Lambda Duration"
          region = "${var.aws_region}"
          metrics = [
            [ "AWS/Lambda", "Duration", "FunctionName", "message-processor" ]
          ]
          stat = "Average"
          period = 60
        }
      },
      {
        type = "metric"
        x    = 0
        y    = 12
        width = 12
        height = 6
        properties = {
          title = "Lambda Concurrent Executions"
          region = "${var.aws_region}"
          metrics = [
            [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "message-processor" ]
          ]
          stat = "Maximum"
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 12
        width = 12
        height = 6
        properties = {
          title = "Queue Oldest Message Age"
          region = "${var.aws_region}"
          metrics = [
            [ "AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", "events-queue" ]
          ]
          stat = "Maximum"
        }
      }
    ] 
  })
}
