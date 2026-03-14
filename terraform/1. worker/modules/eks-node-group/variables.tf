variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "eks_node_role_arn" {
  type        = string
  description = "ARN do role do node group EKS"
}

variable "eks_subnet_a_id" {
  type        = string
  description = "Identificador da Subnet A"
}

variable "eks_subnet_b_id" {
  type        = string
  description = "Identificador da Subnet B"
}
