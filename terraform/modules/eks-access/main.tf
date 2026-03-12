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

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "terraform_user" {
  cluster_name  = var.eks_cluster_name
  principal_arn = data.aws_caller_identity.current.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = data.aws_caller_identity.current.arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}