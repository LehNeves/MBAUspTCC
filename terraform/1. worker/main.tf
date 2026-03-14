module "eks_data" {
  source = "./modules/eks-data"

  github_role_name = var.github_role_name
}

module "eks_iam" {
  source = "./modules/eks-iam"

  project_name = var.project_name
}

module "eks_sqs" {
  source = "./modules/eks-sqs"

  project_name = var.project_name
}

module "eks_ecr" {
  source = "./modules/eks-ecr"

  project_name = var.project_name
}

module "eks_vpc" {
  source = "./modules/eks-vpc"

  aws_region       = var.aws_region
  vpc_name         = "${var.project_name}-vpc"
  eks_cluster_name = "${var.project_name}-eks"
}

module "eks_cluster" {
  source = "./modules/eks-cluster"

  eks_cluster_name     = "${var.project_name}-eks"
  eks_cluster_role_arn = module.eks_iam.eks_cluster_role_arn
  eks_subnet_a_id      = module.eks_vpc.eks_subnet_a_id
  eks_subnet_b_id      = module.eks_vpc.eks_subnet_b_id

  depends_on = [
    module.eks_vpc,
    module.eks_iam
  ]
}

module "eks_nodegroup" {
  source = "./modules/eks-node-group"

  eks_node_role_arn = module.eks_iam.eks_node_role_arn

  eks_subnet_a_id = module.eks_vpc.eks_subnet_a_id
  eks_subnet_b_id = module.eks_vpc.eks_subnet_b_id

  eks_cluster_name = module.eks_cluster.cluster_name

  depends_on = [
    module.eks_iam,
    module.eks_vpc,
    module.eks_cluster
  ]
}

module "eks_access" {
  source = "./modules/eks-access"

  current_identity_arn = module.eks_data.current_identity_arn
  github_role_arn      = module.eks_data.github_role_arn

  eks_admin_arn     = module.eks_iam.eks_admin_arn
  eks_node_role_arn = module.eks_iam.eks_node_role_arn

  eks_cluster_name = module.eks_cluster.cluster_name
  eks_openid_arn   = module.eks_cluster.eks_openid_arn

  depends_on = [
    module.eks_cluster,
    module.eks_nodegroup
  ]
}
