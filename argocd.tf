# Policy to have access to AWS Secrets Manager
resource "aws_iam_policy" "allow_get_secrets_role" {
  name = "AllowGetSecretsRole"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1644847676679",
      "Action": [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:ListSecrets"
      ],
      "Effect": "Allow",
      "Resource": "${aws_secretsmanager_secret_version.superset_secrets.arn}"
    }
  ]
}
POLICY
}

# ArgoCD namespace. It's required for creating secrets before deploying ArgoCD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [module.eks_blueprints_addons]
}

# ArgoCD Vault Plugin configmap configuration
# See Usage -> ArgoCD -> With Helm and With additional Helm arguments
# https://argocd-vault-plugin.readthedocs.io/en/stable/usage/
resource "kubectl_manifest" "cmp_plugin" {
  yaml_body = <<-YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: cmp-plugin
  namespace: argocd
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: argocd-vault-plugin-helm
    spec:
      allowConcurrency: true
      discover:
        find:
          command:
            - sh
            - "-c"
            - "find . -name 'Chart.yaml' && find . -name 'values.yaml'"
      init:
       command:
          - bash
          - "-c"
          - |
            helm repo add bitnami https://charts.bitnami.com/bitnami
            helm dependency build
      generate:
        command:
          - bash
          - "-c"
          - |
            helm template $ARGOCD_APP_NAME -n $ARGOCD_APP_NAMESPACE -f <(echo "$ARGOCD_ENV_HELM_VALUES") . |
            argocd-vault-plugin generate -
      lockRepo: false
  YAML

  depends_on = [kubernetes_namespace.argocd]
}

# ArgoCD helm chart
resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = false
  # helm chart version must be < 4 https://github.com/argoproj/argo-cd/issues/16542
  version          = "3.35.4"
  values = [templatefile("argocd/values.yaml", {
    argocd_image_version = "v2.6.6"
    avp_version = "1.17.0"
    region = var.region
    eks_cluster_certificate_arn = aws_acm_certificate.eks_cluster_certificate.arn
    argocd_url = "argocd.${var.dns_domain}"
  })]

    depends_on = [
      kubectl_manifest.cmp_plugin,
      aws_acm_certificate.eks_cluster_certificate]
}


# ArgoCD secret
data "kubernetes_secret" "argocd" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
  binary_data = {
    "password" = ""
  }

  depends_on = [helm_release.argocd]
}

resource "aws_secretsmanager_secret" "argocd" {
  name = "prod/argocd-initial-admin-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = base64decode(data.kubernetes_secret.argocd.binary_data.password)

  depends_on = [ helm_release.argocd ]
}