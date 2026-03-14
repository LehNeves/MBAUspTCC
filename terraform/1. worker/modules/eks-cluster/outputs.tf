output "cluster_name" {
  value = aws_eks_cluster.worker_cluster.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.worker_cluster.endpoint
}

output "cluster_ca" {
  value = aws_eks_cluster.worker_cluster.certificate_authority[0].data
}

output "cluster_oidc_host" {
  value = replace(
    replace(aws_eks_cluster.worker_cluster.identity[0].oidc[0].issuer, "https://", ""),
    "/$", ""
  )
}

output "eks_openid_arn" {
  value = aws_iam_openid_connect_provider.eks_openid.arn
}
