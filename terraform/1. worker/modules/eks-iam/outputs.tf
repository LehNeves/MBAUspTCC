output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_admin_arn" {
  value = aws_iam_role.eks_admin.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}