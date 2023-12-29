module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "1.12.0"

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
  # The kube-prometheus stack includes a resource metrics API server, so the metrics-server addon is not necessary.
  enable_metrics_server                  = false
  enable_cert_manager                    = true
#   enable_cluster_autoscaler              = true ## disabled to use karpenter

  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    name          = "kube-prometheus-stack"
    chart_version = "51.1.0"
    repository    = "https://prometheus-community.github.io/helm-charts"
    namespace     = var.monitoring_namespace
    values        = [templatefile("${path.module}/prometheus/values.yaml", {
      region = var.region,
      grafana_eks_role_arn = aws_iam_role.grafana_eks.arn,
      workspace_query_url = aws_prometheus_workspace.prometheus_eks.prometheus_endpoint
      prometheus_remote_writer_role_arn = aws_iam_role.prometheus_remote_writer.arn,
      workspace_write_url = "${aws_prometheus_workspace.prometheus_eks.prometheus_endpoint}api/v1/remote_write"
    })]
  }

  tags = {
    Environment = "TESTING EKS"
  }

  depends_on = [
    aws_iam_role.prometheus_remote_writer,
    aws_iam_role.grafana_eks,
    aws_prometheus_workspace.prometheus_eks
  ]
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

  