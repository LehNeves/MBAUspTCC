locals {
  region       = var.aws_region
  lambda_queue = "${var.project_name}-lambda-queue"
  worker_queue = "${var.project_name}-worker-queue"
  lambda_dlq   = "${var.project_name}-lambda-queue-dlq"
  worker_dlq   = "${var.project_name}-worker-queue-dlq"
  sns_topic    = "${var.project_name}-fanout-topic"
  lambda_fn    = "${var.project_name}-lambda"
  eks_cluster  = "${var.project_name}-eks"
  worker_ns    = "workers"
}

resource "aws_cloudwatch_dashboard" "experiment" {
  dashboard_name = "${var.project_name}-experiment"

  dashboard_body = jsonencode({

    widgets = flatten([

      # =====================================================
      #  FLUXO DE MENSAGENS (SNS → SQS)
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# 📊 Fluxo de Mensagens (SNS → SQS)"
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "SNS - Msgs Publicadas"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SNS", "NumberOfMessagesPublished", "TopicName", local.sns_topic]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 8
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "SNS - Notificações Entregues"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SNS", "NumberOfNotificationsDelivered", "TopicName", local.sns_topic]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 16
        y      = 1
        width  = 8
        height = 6
        properties = {
          title  = "SNS - Falhas de Entrega"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SNS", "NumberOfNotificationsFailed", "TopicName", local.sns_topic]
          ]
        }
      }],

      # --- SQS Backlog Comparativo ---

      [{
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "SQS Backlog - Comparativo"
          region = local.region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", local.lambda_queue],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", local.worker_queue]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 12
        y      = 7
        width  = 12
        height = 6
        properties = {
          title  = "Idade da Msg Mais Antiga (s) - Comparativo"
          region = local.region
          period = 60
          stat   = "Maximum"
          metrics = [
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", local.lambda_queue],
            ["AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", local.worker_queue]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "Msgs In Flight - Comparativo"
          region = local.region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesNotVisible", "QueueName", local.lambda_queue],
            ["AWS/SQS", "ApproximateNumberOfMessagesNotVisible", "QueueName", local.worker_queue]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 12
        y      = 13
        width  = 12
        height = 6
        properties = {
          title  = "Msgs Processadas (Deleted) - Comparativo"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.lambda_queue],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.worker_queue]
          ]
        }
      }],

      # =====================================================
      #  SERVERLESS (Lambda)
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 19
        width  = 24
        height = 1
        properties = {
          markdown = "# ⚡ Arquitetura Serverless (Lambda)"
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 20
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Invocações"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_fn]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 8
        y      = 20
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Duração (ms) p50/p95/p99"
          region = local.region
          period = 60
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn, { stat = "p50", label = "p50" }],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn, { stat = "p95", label = "p95" }],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn, { stat = "p99", label = "p99" }]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 16
        y      = 20
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Erros"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", local.lambda_fn]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 26
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Execuções Concorrentes"
          region = local.region
          period = 60
          stat   = "Maximum"
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", local.lambda_fn]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 8
        y      = 26
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Throttles"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Throttles", "FunctionName", local.lambda_fn]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 16
        y      = 26
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Taxa de Erro (%)"
          region = local.region
          period = 60
          view   = "singleValue"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "errors", visible = false }],
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "invocations", visible = false }],
            [{ expression = "100 * errors / invocations", label = "Taxa de Erro %", id = "error_rate" }]
          ]
        }
      }],

      # =====================================================
      #  WORKERS (Kubernetes / EKS)
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 32
        width  = 24
        height = 1
        properties = {
          markdown = "# 🐳 Arquitetura Workers (Kubernetes/EKS)"
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 33
        width  = 8
        height = 6
        properties = {
          title  = "Workers - Pod Count"
          region = local.region
          period = 60
          stat   = "Average"
          metrics = [
            ["ContainerInsights", "pod_number_running",
            "ClusterName", local.eks_cluster, "Namespace", local.worker_ns]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 8
        y      = 33
        width  = 8
        height = 6
        properties = {
          title  = "Workers - CPU Utilization (%)"
          region = local.region
          period = 60
          stat   = "Average"
          metrics = [
            ["ContainerInsights", "pod_cpu_utilization",
            "ClusterName", local.eks_cluster, "Namespace", local.worker_ns]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 16
        y      = 33
        width  = 8
        height = 6
        properties = {
          title  = "Workers - Memory Utilization (%)"
          region = local.region
          period = 60
          stat   = "Average"
          metrics = [
            ["ContainerInsights", "pod_memory_utilization",
            "ClusterName", local.eks_cluster, "Namespace", local.worker_ns]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 39
        width  = 12
        height = 6
        properties = {
          title  = "Worker Queue - Received vs Deleted"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SQS", "NumberOfMessagesReceived", "QueueName", local.worker_queue],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.worker_queue]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 12
        y      = 39
        width  = 12
        height = 6
        properties = {
          title  = "Worker Queue - Empty Receives"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SQS", "NumberOfEmptyReceives", "QueueName", local.worker_queue]
          ]
        }
      }],

      # =====================================================
      #  DEAD LETTER QUEUES
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 45
        width  = 24
        height = 1
        properties = {
          markdown = "# ⚠️ Dead Letter Queues (Falhas)"
        }
      }],

      [{
        type   = "metric"
        x      = 0
        y      = 46
        width  = 12
        height = 6
        properties = {
          title  = "DLQ Lambda - Msgs Acumuladas"
          region = local.region
          period = 60
          stat   = "Average"
          view   = "singleValue"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", local.lambda_dlq]
          ]
        }
      }],

      [{
        type   = "metric"
        x      = 12
        y      = 46
        width  = 12
        height = 6
        properties = {
          title  = "DLQ Worker - Msgs Acumuladas"
          region = local.region
          period = 60
          stat   = "Average"
          view   = "singleValue"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", local.worker_dlq]
          ]
        }
      }]
    ])
  })
}
