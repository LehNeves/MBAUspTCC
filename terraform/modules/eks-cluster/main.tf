resource "aws_eks_cluster" "worker_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = [
      var.eks_subnet_a_id,
      var.eks_subnet_b_id
    ]

    endpoint_public_access  = true
    endpoint_private_access = false
  }

  access_config {
    authentication_mode = "API"
  }
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.worker_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_openid" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_oidc.url
}
