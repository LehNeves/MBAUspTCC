module "lambda_iam" {
  source = "./modules/lambda-iam"

  project_name = var.project_name
}

module "lambda_sqs" {
  source = "./modules/lambda-sqs"

  project_name = var.project_name
}

module "lambda_ecr" {
  source = "./modules/lambda-ecr"

  project_name = var.project_name
}
