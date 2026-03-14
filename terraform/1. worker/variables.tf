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

variable "github_role_name" {
  description = "Role name do GitHub"
  type        = string
  default = "GitHubRole"
}
