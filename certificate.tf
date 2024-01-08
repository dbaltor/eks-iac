resource "tls_private_key" "eks_cluster_ingress_tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "eks_cluster_ingress_tls_cert" {
  private_key_pem = tls_private_key.eks_cluster_ingress_tls_key.private_key_pem

  subject {
    country             = "UK"
    common_name         = "*.dbaltor.online"
  }

  validity_period_hours = 1825 //  1825 days or 5 years

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "aws_acm_certificate" "eks_cluster_certificate" {
  private_key      = tls_private_key.eks_cluster_ingress_tls_key.private_key_pem
  certificate_body = tls_self_signed_cert.eks_cluster_ingress_tls_cert.cert_pem
}

# TLS secret used when enabling TLS to the ingress
# resource "kubernetes_secret" "eks_cluster_ingress_tls" {
#     metadata {
#       name = "${local.cluster_name}-ingress-tls"
#       namespace = "kube-system"
#     }

#     data = {
#       "tls.crt" = tls_self_signed_cert.eks_cluster_ingress_tls_cert.cert_pem
#       "tls.key" = tls_private_key.eks_cluster_ingress_tls_key.private_key_pem
#     }

#     type = "kubernetes.io/tls"
#   }