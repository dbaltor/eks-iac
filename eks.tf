module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.28"
  enable_irsa     = true

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64" # Amazon Linux 2 (x86-64)
  }

  eks_managed_node_groups = {
    default = {
      name = "test-eks-node-group"
      instance_types = ["t3.xlarge"]
      capacity_type = "ON_DEMAND"
      min_size     = 2 # Minimum required to run Karpenter in HA
      max_size     = 5 # Ignored by Karpenter
      desired_size = 3 # one per az

      iam_role_additional_policies = {
        # Needed by the aws-ebs-csi-driver
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        # Needed by the ArgoCD Vault Plugin
        AllowGetSecretsRole = aws_iam_policy.allow_get_secrets_role.arn
      }
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    # We need to add in the Karpenter node IAM role for nodes launched by Karpenter
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      rolearn  = aws_iam_role.developer.arn
      username = "developer"
      groups   = ["reader"]
    },
  ]

    tags = {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = local.cluster_name
  }
}
