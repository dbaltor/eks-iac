# data "aws_iam_policy_document" "allow_assume_prometheus_role" {
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:monitoring:prometheus"]
#     }

#     principals {
#       identifiers = [module.eks.oidc_provider_arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "prometheus_sa" {
#   assume_role_policy = data.aws_iam_policy_document.allow_assume_prometheus_role.json
#   name               = "prometheus-sa"
# }


# data "aws_iam_policy_document" "allow_assume_web_identity" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:monitoring:prometheus"]
#     }

#     principals {
#       identifiers = [module.eks.oidc_provider_arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "prometheus_remote_writer" {
#   assume_role_policy = data.aws_iam_policy_document.allow_assume_web_identity.json
#   name               = "prometheus-remote-writer"
# }


# resource "aws_iam_policy" "allow_assume_prometheus_remote_writer_role" {
#   name = "AllowAssumePrometheusRemoteWriterRole"

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "sts:AssumeRole",
#       "Resource": "${aws_iam_role.prometheus_remote_writer.arn}"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "allow_prometheus_sa_assume_prometheus_remote_writer_role" {
#   role       = aws_iam_role.prometheus_sa.name
#   policy_arn = aws_iam_policy.allow_assume_prometheus_remote_writer_role.arn
# }


# resource "aws_iam_policy" "prometheus_eks_ingest_access" {
#   name = "PrometheusEKSIngestAccess"

#   policy = jsonencode({
#     Statement = [{
#       Action = [
#         "aps:RemoteWrite"
#       ]
#       Effect   = "Allow"
#       Resource = aws_prometheus_workspace.prometheus_eks.arn
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "prometheus_eks_ingest_access" {
#   role       = aws_iam_role.prometheus_remote_writer.name
#   policy_arn = aws_iam_policy.prometheus_eks_ingest_access.arn
# }

