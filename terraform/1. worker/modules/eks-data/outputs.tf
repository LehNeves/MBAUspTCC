output "github_role_arn" {
  value = data.aws_iam_role.github_role.arn
}

output "current_identity_arn" {
  value = data.aws_caller_identity.current.arn
}