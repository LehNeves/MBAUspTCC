variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "eks_cluster_role_arn" {
  type        = string
  description = "ARN do cluster EKS"
}

variable "eks_subnet_a_id" {
  type        = string
  description = "Identificador da Subnet A"
}

variable "eks_subnet_b_id" {
  type        = string
  description = "Identificador da Subnet B"
}
