module "lambda_sqs" {
  source = "./modules/lambda-sqs"

  project_name = var.project_name
}

module "lambda_iam" {
  source = "./modules/lambda-iam"

  project_name     = var.project_name
  lambda_queue_arn = module.lambda_sqs.lambda_queue_arn
}

module "lambda_ecr" {
  source = "./modules/lambda-ecr"

  project_name = var.project_name
}

module "lambda_function" {
  source = "./modules/lambda-function"

  project_name       = var.project_name
  lambda_role_arn    = module.lambda_iam.lambda_role_arn
  ecr_repository_url = module.lambda_ecr.repository_url
  lambda_queue_arn   = module.lambda_sqs.lambda_queue_arn
}
