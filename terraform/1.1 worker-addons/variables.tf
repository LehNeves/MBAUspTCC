variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "tcc-mba-usp"
}

variable "eks_cluster_name" {
  description = "Nome do cluster EKS (deve ser passado do step 1. worker)"
  type        = string
  default     = "tcc-mba-usp-eks"
}
