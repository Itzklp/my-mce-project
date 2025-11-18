# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.24.0"

#   cluster_name    = "mce-eks-${var.project_suffix}"
#   cluster_version = "1.33"

#   vpc_id     = aws_vpc.main.id
#   subnet_ids = aws_subnet.private[*].id

#   cluster_endpoint_public_access = true

#   eks_managed_node_group_defaults = {
#     ami_type = "AL2_x86_64"
#   }

#   eks_managed_node_groups = {
#     mce_nodes = {
#       min_size       = 1
#       desired_size   = 2
#       max_size       = 4
#       instance_types = ["t3.medium"]
#     }
#   }

#   tags = {
#     Project = var.project_suffix
#   }
# }


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.0"

  cluster_name    = "mce-eks-${var.project_suffix}"
  cluster_version = "1.33"

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  # THIS LINE IS REMOVED: It is deprecated and was causing the "Unexpected attribute" error.
  # manage_aws_auth = true 

  eks_managed_node_groups = {
    mce_nodes = {
      min_size       = 1
      desired_size   = 2
      max_size       = 4
      instance_types = ["t3.medium"]
      iam_role_arn   = aws_iam_role.eks_node.arn
    }
  }

  tags = {
    Project = var.project_suffix
  }
}
