module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.7.2"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  # Self-managed Addons 
  enable_aws_efs_csi_driver = true
  aws_efs_csi_driver = {
    chart         = "aws-efs-csi-driver"
    chart_version = "2.4.9"
    repository    = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
    namespace  = "kube-system"    
  }

  enable_aws_load_balancer_controller    = true
  enable_metrics_server                  = true
#   enable_cluster_autoscaler              = true ## disabled to use karpenter

## BROKEN - this addon version does not configure the service account properly
#   enable_karpenter                       = true
#   karpenter = {
#     chart         = "karpenter"
#     chart_version = "v0.30.0"
#     repository    = "oci://public.ecr.aws/karpenter"
#     namespace  = "karpenter"  
#   }

  tags = {
    Environment = "TESTING EKS"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        # This requires the awscli to be installed locally where Terraform is executed
        args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

  