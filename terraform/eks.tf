resource "aws_eks_cluster" "worker_cluster" {
  name     = local.eks_cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_a.id,
      aws_subnet.eks_subnet_b.id
    ]

    endpoint_public_access  = true
    endpoint_private_access = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = aws_eks_cluster.worker_cluster.name
  node_group_name = "worker-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    aws_subnet.eks_subnet_a.id,
    aws_subnet.eks_subnet_b.id
  ]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1
  }

  instance_types = ["t3.micro"]
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = aws_iam_role.eks_admin.arn
        username = "eks-admin"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [aws_eks_cluster.worker_cluster]
}

resource "helm_release" "grafana_agent" {
  name             = "grafana-agent"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana-agent"
  namespace        = "monitoring"
  create_namespace = true

  values = [
    yamlencode({
      cluster = {
        name = "eks-tcc"
      }

      traces = {
        enabled = true

        configs = [
          {
            name = "default"

            receivers = {
              otlp = {
                protocols = {
                  grpc = {}
                  http = {}
                }
              }
            }

            remote_write = [
              {
                endpoint = var.grafana_cloud_tempo_url

                basic_auth = {
                  username = var.grafana_cloud_instance_id
                  password = var.grafana_cloud_api_key
                }
              }
            ]
          }
        ]
      }
    })
  ]

  depends_on = [
    aws_eks_cluster.worker_cluster,
    aws_eks_node_group.default
  ]
}