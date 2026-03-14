module "eks_helm" {
  source = "./eks-helm"

  aws_region       = var.aws_region
  eks_cluster_name = var.eks_cluster_name
}
