resource "aws_eks_node_group" "worker_nodes" {
  cluster_name    = var.eks_cluster_name
  node_group_name = "worker-nodes"
  node_role_arn   = var.eks_node_role_arn
  subnet_ids = [
    var.eks_subnet_a_id,
    var.eks_subnet_b_id
  ]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  instance_types = ["t3.medium"]
}