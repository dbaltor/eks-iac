provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

terraform {
  required_providers {
    kubectl = {
      # fix https://github.com/gavinbunney/terraform-provider-kubectl/issues/270#issuecomment-1642437458
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    # https://registry.terraform.io/providers/cyrilgdn/postgresql/latest
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "postgresql" {
  host            = aws_db_instance.superset.address
  port            = aws_db_instance.superset.port
  database        = aws_db_instance.superset.db_name
  username        = aws_db_instance.superset.username
  password        = random_password.superset_postgresql_password.result
  sslmode         = "require"
  connect_timeout = 15
}
