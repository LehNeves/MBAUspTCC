variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
}

variable "vpc_name" {
  description = "Nome do VPC"
  type        = string
}

variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}
