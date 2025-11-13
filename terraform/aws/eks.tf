module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = ">= 19.0.0"

  cluster_name    = "mce-eks-${var.project_suffix}"
  cluster_version = "1.27"
  subnets         = aws_subnet.private[*].id
  vpc_id          = aws_vpc.main.id

  node_groups = {
    mce_nodes = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1
      instance_types   = ["t3.medium"]
    }
  }

  manage_aws_auth = true
}
