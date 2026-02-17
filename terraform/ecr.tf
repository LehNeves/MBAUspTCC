resource "aws_ecr_repository" "worker_repo" {
  name = "${local.name_prefix}-worker"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = {
    Project     = var.project_name
    Environment = var.environment
    UsedBy      = "eks-worker"
  }
}
