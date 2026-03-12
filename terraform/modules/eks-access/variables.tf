variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "github_role_arn" {
  type        = string
  description = "ARN do GitHubRole"
}

variable "eks_admin_arn" {
  type        = string
  description = "ARN do EKS Admin"
}

variable "eks_node_role_arn" {
  type        = string
  description = "ARN do EKS Node Role"
}
