data "aws_iam_role" "github_role" {
  name = var.github_role_name
}

data "aws_caller_identity" "current" {}
