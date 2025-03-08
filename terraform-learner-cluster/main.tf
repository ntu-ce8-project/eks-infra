locals {
  merged_users  = concat(data.aws_iam_group.ce8.users, data.aws_iam_group.instructor.users)
  user_arn_list = [for obj in local.merged_users : obj["arn"]]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  bootstrap_self_managed_addons = true

  cluster_name    = "shared-eks-cluster"
  cluster_version = "1.31"

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = false

  enable_irsa = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    learner_ng = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["m5.large"]

      min_size     = 3
      max_size     = 5
      desired_size = 3
    }
  }

  access_entries = {
    for arn in local.user_arn_list : arn => {
      principal_arn = arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name                    = "eks_shared_vpc"
  cidr                    = "172.31.0.0/16"
  azs                     = data.aws_availability_zones.available.names
  public_subnets          = ["172.31.101.0/24", "172.31.102.0/24"]
  private_subnets         = ["172.31.1.0/24", "172.31.2.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
