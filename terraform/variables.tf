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

variable "eks_cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
  default     = ""
}

locals {
  name_prefix      = "${var.project_name}"
  eks_cluster_name = "${local.name_prefix}-eks"
}

variable "grafana_cloud_account_id" {
  description = "Account Id do Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_external_id" {
  description = "External Id do Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_api_key" {
  description = "API Key do Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_instance_id" {
  description = "Instance Id do Grafana Cloud"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_tempo_url" {
  description = "Url do Traces do Grafana Cloud"
  type        = string
  sensitive   = true
}