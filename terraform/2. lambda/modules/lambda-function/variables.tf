variable "project_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "ecr_repository_url" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "lambda_queue_arn" {
  type = string
}
