variable "aws_region" {
  description = "Região da AWS onde os recursos serão provisionados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto para prefixar recursos"
  type        = string
  default     = "tcc-arquitetura"
}

variable "environment" {
  description = "Ambiente do projeto"
  type        = string
  default     = "dev"
}

variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
  default     = ""
}

locals {
  name_prefix      = "${var.project_name}-${var.environment}"
  eks_cluster_name = "${local.name_prefix}-eks"
}
