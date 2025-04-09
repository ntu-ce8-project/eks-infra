locals {
  prefix = "ce8-g1-capstone"
  allowed_usernames = [
    "jasonleong84",
    "Royston88",
    "jsstrn",
    "vseow7474",
    "mal1610-cohort8"
  ]

  # merged_users_raw = data.aws_iam_group.ce8.users

  filtered_users = [
    for u in data.aws_iam_group.ce8.users : u
    if contains(local.allowed_usernames, u.user_name)
  ]

  merged_users = concat(local.filtered_users, data.aws_iam_group.instructor.users)

  user_arn_list = [for obj in local.merged_users : obj["arn"]]
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  bootstrap_self_managed_addons = true

  cluster_name    = "${local.prefix}-cluster"
  cluster_version = "1.31"

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni = {
      # most_recent    = true
      # before_compute = true
      # configuration_values = jsonencode({
      #   env = {
      #     ENABLE_PREFIX_DELEGATION = "true"
      #     WARM_PREFIX_TARGET       = "1"
      #   }
      # })
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = try(module.ebs_csi_driver_role[0].iam_role_arn, null)
    }
  }

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  enable_irsa = true # To create a OIDC provider/issuer for this cluster to be able to create IRSAs

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    CE8-G1-capstone-eks-ng = {
      ami_type = "AL2023_x86_64_STANDARD"
      # instance_types = ["m5.large"]
      # instance_types = ["t2.micro"] # too underpowered
      instance_types = ["t3.medium"]

      min_size     = 4
      max_size     = 5
      desired_size = 4
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

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.34.0"

  cluster_name                    = module.eks.cluster_name
  enable_pod_identity             = true
  create_pod_identity_association = true
  namespace                       = "kube-system"
  iam_role_name                   = "${local.prefix}-karpenter_controller"
  iam_role_use_name_prefix        = false
  iam_policy_name                 = "${local.prefix}-KarpenterControllerPolicy"
  iam_policy_use_name_prefix      = false
  iam_policy_description         = "Karpenter controller policy with all necessary permissions"
  node_iam_role_name              = "${local.prefix}-KarpenterNodeRole"
  node_iam_role_use_name_prefix   = false
  node_iam_role_description       = "Karpenter node role with all necessary permissions"
  # create_node_iam_role = false
  # node_iam_role_arn    = module.eks.eks_managed_node_groups["CE8-G1-capstone-eks-ng"].iam_role_arn
  queue_name                      = "${module.eks.cluster_name}"
  # rule_name_prefix                = "${local.prefix}-karpenter"

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEKS_CNI_Policy                = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    AmazonEKSWorkerNodePolicy           = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8.1"

  name                    = "${local.prefix}-vpc"
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
    "karpenter.sh/discovery" = "${local.prefix}-cluster"
  }
}
