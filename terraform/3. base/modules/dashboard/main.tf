locals {
  region       = var.aws_region
  lambda_queue = "${var.project_name}-lambda-queue"
  worker_queue = "${var.project_name}-worker-queue"
  lambda_dlq   = "${var.project_name}-lambda-queue-dlq"
  worker_dlq   = "${var.project_name}-worker-queue-dlq"
  sns_topic    = "${var.project_name}-fanout-topic"
  lambda_fn    = "${var.project_name}-lambda"
  eks_cluster  = "${var.project_name}-eks"
  worker_ns    = "default"
  worker_pod   = "sqs-worker-low-load"
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
          stat   = "Sum"
          metrics = [
            ["ContainerInsights", "pod_status_running",
            "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns]
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
          title  = "Workers - CPU (Uso vs Limit)"
          region = local.region
          period = 60
          stat   = "Average"
          yAxis = {
            left = {
              label     = "Milicores (m)"
              showUnits = false
            }
          }
          metrics = [
            ["ContainerInsights", "pod_cpu_usage_total",
              "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "cpu_usage", label = "CPU Uso" }],
            ["ContainerInsights", "pod_cpu_limit",
              "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "cpu_limit", label = "CPU Limit", color = "#d62728" }]
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
          title  = "Workers - Memória (Uso vs Limit)"
          region = local.region
          period = 60
          stat   = "Average"
          yAxis = {
            left = {
              label     = "Megabytes (MB)"
              showUnits = false
            }
          }
          metrics = [
            ["ContainerInsights", "pod_memory_working_set",
              "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "mem_usage", label = "Memória Uso" }],
            ["ContainerInsights", "pod_memory_limit",
              "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "mem_limit", label = "Memória Limit", color = "#d62728" }]
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

resource "aws_cloudwatch_dashboard" "cost_analysis" {
  dashboard_name = "${var.project_name}-cost-analysis"

  dashboard_body = jsonencode({

    widgets = flatten([

      # =====================================================
      #  TÍTULO
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 0
        width  = 24
        height = 1
        properties = {
          markdown = "# 💰 Análise de Custos — Lambda vs Worker (us-east-1)"
        }
      }],

      # =====================================================
      #  CUSTO ESTIMADO - LAMBDA
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 1
        width  = 24
        height = 1
        properties = {
          markdown = "## ⚡ Custo Estimado — Lambda (512 MB, us-east-1)"
        }
      }],

      # --- GB-Segundos consumidos ---
      [{
        type   = "metric"
        x      = 0
        y      = 2
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - GB-Segundos Consumidos"
          region = local.region
          period = 60
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "duration_ms", visible = false }],
            [{ expression = "duration_ms / 1000 * 0.5", label = "GB-Segundos", id = "gb_seconds" }]
          ]
        }
      }],

      # --- Custo de Invocações ---
      [{
        type   = "metric"
        x      = 8
        y      = 2
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Custo de Invocações ($)"
          region = local.region
          period = 60
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "invocations", visible = false }],
            [{ expression = "invocations * 0.0000002", label = "Custo Invocações ($)", id = "cost_invocations" }]
          ]
        }
      }],

      # --- Custo de Computação (GB-s) ---
      [{
        type   = "metric"
        x      = 16
        y      = 2
        width  = 8
        height = 6
        properties = {
          title  = "Lambda - Custo de Computação ($)"
          region = local.region
          period = 60
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "dur_ms", visible = false }],
            [{ expression = "(dur_ms / 1000 * 0.5) * 0.0000166667", label = "Custo Computação ($)", id = "cost_compute" }]
          ]
        }
      }],

      # --- Custo Total Lambda (acumulado no período) ---
      [{
        type   = "metric"
        x      = 0
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Custo Total Estimado ($)"
          region = local.region
          period = 3600
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "inv", visible = false }],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "dur", visible = false }],
            [{ expression = "(inv * 0.0000002) + ((dur / 1000 * 0.5) * 0.0000166667)", label = "Custo Total Lambda ($)", id = "lambda_total", color = "#ff9900" }]
          ]
        }
      }],

      # --- Duração Média (contexto) ---
      [{
        type   = "metric"
        x      = 12
        y      = 8
        width  = 12
        height = 6
        properties = {
          title  = "Lambda - Duração Média (ms)"
          region = local.region
          period = 60
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn, { stat = "Average", label = "Média" }],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn, { stat = "p99", label = "p99" }]
          ]
        }
      }],

      # =====================================================
      #  CUSTO ESTIMADO - WORKER / EKS
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 14
        width  = 24
        height = 1
        properties = {
          markdown = "## 🐳 Custo Estimado — Worker/EKS (2x t3.medium, us-east-1)"
        }
      }],

      # --- Custo Fixo por Hora ---
      [{
        type   = "metric"
        x      = 0
        y      = 15
        width  = 8
        height = 6
        properties = {
          title  = "Worker - Custo Fixo por Hora ($)"
          region = local.region
          period = 3600
          view   = "singleValue"
          metrics = [
            ["ContainerInsights", "node_number_of_running_pods",
            "ClusterName", local.eks_cluster,
            { stat = "Average", id = "dummy", visible = false }],
            [{ expression = "(FILL(dummy, 0) * 0) + 0.10 + (2 * 0.0416)", label = "Custo/Hora (EKS + 2x t3.medium)", id = "worker_hourly" }]
          ]
        }
      }],

      # --- Custo Fixo por Dia ---
      [{
        type   = "metric"
        x      = 8
        y      = 15
        width  = 8
        height = 6
        properties = {
          title  = "Worker - Custo Fixo por Dia ($)"
          region = local.region
          period = 3600
          view   = "singleValue"
          metrics = [
            ["ContainerInsights", "node_number_of_running_pods",
            "ClusterName", local.eks_cluster,
            { stat = "Average", id = "dummy2", visible = false }],
            [{ expression = "(FILL(dummy2, 0) * 0) + (0.10 + (2 * 0.0416)) * 24", label = "Custo/Dia ($)", id = "worker_daily" }]
          ]
        }
      }],

      # --- Custo Fixo por Mês ---
      [{
        type   = "metric"
        x      = 16
        y      = 15
        width  = 8
        height = 6
        properties = {
          title  = "Worker - Custo Fixo por Mês ($)"
          region = local.region
          period = 3600
          view   = "singleValue"
          metrics = [
            ["ContainerInsights", "node_number_of_running_pods",
            "ClusterName", local.eks_cluster,
            { stat = "Average", id = "dummy3", visible = false }],
            [{ expression = "(FILL(dummy3, 0) * 0) + (0.10 + (2 * 0.0416)) * 24 * 30", label = "Custo/Mês ($)", id = "worker_monthly" }]
          ]
        }
      }],

      # --- Eficiência CPU ---
      [{
        type   = "metric"
        x      = 0
        y      = 21
        width  = 12
        height = 6
        properties = {
          title  = "Worker - Eficiência CPU (Uso vs Capacidade)"
          region = local.region
          period = 60
          stat   = "Average"
          yAxis = {
            left = {
              label     = "Milicores"
              showUnits = false
            }
          }
          metrics = [
            ["ContainerInsights", "pod_cpu_usage_total",
            "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "cpu_use", label = "CPU Usado" }],
            ["ContainerInsights", "pod_cpu_limit",
            "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "cpu_lim", label = "CPU Limit", color = "#d62728" }]
          ]
        }
      }],

      # --- Eficiência Memória ---
      [{
        type   = "metric"
        x      = 12
        y      = 21
        width  = 12
        height = 6
        properties = {
          title  = "Worker - Eficiência Memória (Uso vs Capacidade)"
          region = local.region
          period = 60
          stat   = "Average"
          yAxis = {
            left = {
              label     = "Megabytes"
              showUnits = false
            }
          }
          metrics = [
            ["ContainerInsights", "pod_memory_working_set",
            "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "mem_use", label = "Memória Usado" }],
            ["ContainerInsights", "pod_memory_limit",
            "ClusterName", local.eks_cluster, "PodName", local.worker_pod, "Namespace", local.worker_ns,
            { id = "mem_lim", label = "Memória Limit", color = "#d62728" }]
          ]
        }
      }],

      # =====================================================
      #  COMPARATIVO
      # =====================================================

      [{
        type   = "text"
        x      = 0
        y      = 27
        width  = 24
        height = 1
        properties = {
          markdown = "## 📊 Comparativo Lambda vs Worker"
        }
      }],

      # --- Throughput Comparativo ---
      [{
        type   = "metric"
        x      = 0
        y      = 28
        width  = 8
        height = 6
        properties = {
          title  = "Throughput - Msgs Processadas"
          region = local.region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.lambda_queue, { label = "Lambda" }],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.worker_queue, { label = "Worker" }]
          ]
        }
      }],

      # --- Custo por Mensagem ---
      [{
        type   = "metric"
        x      = 8
        y      = 28
        width  = 8
        height = 6
        properties = {
          title  = "Custo por Mensagem ($)"
          region = local.region
          period = 3600
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "l_inv", visible = false }],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "l_dur", visible = false }],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.lambda_queue,
            { stat = "Sum", id = "l_msgs", visible = false }],
            ["AWS/SQS", "NumberOfMessagesDeleted", "QueueName", local.worker_queue,
            { stat = "Sum", id = "w_msgs", visible = false }],
            [{ expression = "IF(l_msgs > 0, ((l_inv * 0.0000002) + ((l_dur / 1000 * 0.5) * 0.0000166667)) / l_msgs, 0)", label = "Lambda ($/msg)", id = "lambda_per_msg", color = "#ff9900" }],
            [{ expression = "IF(w_msgs > 0, ((0.10 + 2 * 0.0416) / 3600) / w_msgs, 0)", label = "Worker ($/msg)", id = "worker_per_msg", color = "#1f77b4" }]
          ]
        }
      }],

      # --- Custo Total Comparativo ---
      [{
        type   = "metric"
        x      = 16
        y      = 28
        width  = 8
        height = 6
        properties = {
          title  = "Custo Total Estimado ($)"
          region = local.region
          period = 3600
          view   = "timeSeries"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "t_inv", visible = false }],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_fn,
            { stat = "Sum", id = "t_dur", visible = false }],
            ["ContainerInsights", "node_number_of_running_pods", "ClusterName", local.eks_cluster,
            { stat = "Average", id = "t_dummy", visible = false }],
            [{ expression = "(FILL(t_inv, 0) * 0.0000002) + ((FILL(t_dur, 0) / 1000 * 0.5) * 0.0000166667)", label = "Lambda ($)", id = "total_lambda", color = "#ff9900" }],
            [{ expression = "(FILL(t_dummy, 0) * 0) + 0.10 + (2 * 0.0416)", label = "Worker ($)", id = "total_worker", color = "#1f77b4" }]
          ]
        }
      }]

    ])
  })
}
