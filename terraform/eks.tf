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
