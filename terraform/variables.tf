variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para prefixar recursos"
  type        = string
  default     = "tcc-mba-usp"
}

locals {
  name_prefix      = "${var.project_name}"
  oidc_host = module.eks_cluster.cluster_oidc_host
  eks_openid_arn = module.eks_cluster.eks_openid_arn
}

variable "github_provider_oidc_arn" {
  description = "OIDC provider ARN do GitHub"
  type        = string
  sensitive   = true
}

variable "github_role_name" {
  description = "Role name do GitHub"
  type        = string
  sensitive   = true
}
