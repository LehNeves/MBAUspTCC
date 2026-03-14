module "dashboard" {
  source = "./modules/dashboard"

  aws_region   = var.aws_region
  project_name = var.project_name
}

module "sns" {
  source = "./modules/sns"

  aws_region   = var.aws_region
  project_name = var.project_name
}
