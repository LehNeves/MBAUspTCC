resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = var.github_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = var.github_role_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_entry" "eks_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = var.eks_admin_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "eks_admin_policy" {
  cluster_name  = var.eks_cluster_name
  principal_arn = var.eks_admin_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = var.current_identity_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_role" "cloudwatch_agent" {
  name = "${var.eks_cluster_name}-cw-agent"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_openid_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.eks_openid_arn, "https://", "")}:sub" = "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
        }
      }
    }]
  })
}

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "amazon-cloudwatch-observability"
  service_account_role_arn = aws_iam_role.cloudwatch_agent.arn
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "worker_role" {
  name = "${var.eks_cluster_name}-worker-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = var.eks_openid_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(var.eks_openid_arn, "https://", "")}:sub" = "system:serviceaccount:default:worker-sqs-sa"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "${var.eks_cluster_name}-worker-sqs-policy"
  role = aws_iam_role.worker_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.worker_queue_arn
      }
    ]
  })
}
