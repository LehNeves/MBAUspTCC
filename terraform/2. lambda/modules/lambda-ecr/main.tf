resource "aws_ecr_repository" "lambda_repo" {
  name = "${var.project_name}-lambda"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Project = var.project_name
    UsedBy  = "lambda"
  }
}
