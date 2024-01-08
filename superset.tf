################################
# Secrets
################################

resource "aws_secretsmanager_secret" "superset" {
  name        = "prod/superset"
}

resource "random_password" "superset_secret_key" {
  length           = 42
  special          = false
}

resource "random_password" "superset_postgresql_password" {
  length           = 12
  special          = false
}

variable "secrets" {
  type = map(string)
  default = {}
}

locals {
  superset_secrets = merge(
    var.secrets,
    {
      secret-key = random_password.superset_secret_key.result
      postgresql-password = random_password.superset_postgresql_password.result
      smtp-password = var.smtp_password
      alb-cert-arn = aws_acm_certificate.eks_cluster_certificate.arn
    }
  )
}

resource "aws_secretsmanager_secret_version" "superset_secrets" {
  secret_id     = aws_secretsmanager_secret.superset.id
  secret_string = jsonencode(local.superset_secrets)
}


################################
# Superset
################################

resource "kubernetes_namespace" "superset" {
  metadata {
    name = "superset"
  }

  depends_on = [module.eks]
}

# Superset helm chart
# resource "kubectl_manifest" "superset_helm" {
#   yaml_body = templatefile("${path.module}/superset/superset.yaml", {
#     superset_secret_key = var.superset_secret_key
#   })

#   depends_on = [helm_release.argocd]
# }

# PostgreSQL password K8s secret (used when deploying postgres with Superset)
# resource "kubernetes_secret" "superset_postgres" {
#   metadata {
#     name = "superset-postgres"
#     namespace = "superset"
#   }

#   data = {
#     password = random_password.superset_postgresql_password.result
#     postgres-password = random_password.superset_postgresql_password.result
#   }

#   depends_on = [
#     kubernetes_namespace.superset,
#     aws_secretsmanager_secret_version.superset_secrets
#   ]
# }

# Superset umbrella helm chart (with ArgoCD Vault Plugin)
resource "kubectl_manifest" "superset_helm" {
  yaml_body = file("${path.module}/superset/superset-umbrella-chart.yaml")

  depends_on = [
    kubernetes_namespace.superset,
    helm_release.argocd,
    aws_db_instance.superset,
    aws_acm_certificate.eks_cluster_certificate,
    # kubernetes_secret.superset_ingress_tls
  ]
}
