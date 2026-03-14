variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto"
}

variable "github_role_arn" {
  type        = string
  description = "ARN do GitHubRole"
}

variable "current_identity_arn" {
  type        = string
  description = "ARN do Usuário Logado"
}

variable "eks_admin_arn" {
  type        = string
  description = "ARN do EKS Admin"
}

variable "eks_node_role_arn" {
  type        = string
  description = "ARN do EKS Node Role"
}

variable "eks_openid_arn" {
  type        = string
  description = "ARN do OIDC"
}

variable "eks_openid_url" {
  type        = string
  description = "URL do OIDC"
}

variable "worker_queue_arn" {
  type        = string
  description = "ARN da fila SQS"
}
