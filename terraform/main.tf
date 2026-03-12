module "eks_vpc" {
  source = "./modules/eks-vpc"

  aws_region = var.aws_region
  vpc_name = "${var.project_name}-vpc"
  eks_cluster_name = "${var.project_name}-eks"
}

module "eks_cluster" {
  source = "./modules/eks-cluster"

  eks_cluster_name = "${var.project_name}-eks"
  eks_cluster_role_arn = aws_iam_role.eks_cluster_role.arn
  eks_subnet_a_id = module.eks_vpc.eks_subnet_a_id
  eks_subnet_b_id = module.eks_vpc.eks_subnet_b_id

  depends_on = [
    module.eks_vpc,
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

module "eks_nodegroup" {
  source = "./modules/eks-node-group"

  eks_cluster_name = module.eks_cluster.cluster_name
  eks_node_role_arn = aws_iam_role.eks_node_role.arn
  eks_subnet_a_id = module.eks_vpc.eks_subnet_a_id
  eks_subnet_b_id = module.eks_vpc.eks_subnet_b_id
}

module "eks_access" {
  source = "./modules/eks-access"

  eks_cluster_name = module.eks_cluster.cluster_name
  github_role_arn = data.aws_iam_role.github_role.arn
  eks_admin_arn = aws_iam_role.eks_admin.arn
  eks_node_role_arn = aws_iam_role.eks_node_role.arn

  depends_on = [
    module.eks_cluster,
    module.eks_nodegroup
  ]
}

module "eks_helm" {
  source = "./modules/eks-helm"

  providers = {
    helm = helm
  }

  depends_on = [
    module.eks_cluster,
    module.eks_nodegroup,
    module.eks_access
  ]
}
