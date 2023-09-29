
# ######################################################
# ## self-assuming role failed attempt
# ######################################################
# locals {
#   aws_account_id = data.aws_caller_identity.current.account_id
# }

# resource "aws_iam_role" "prometheus_remote_writer" {
#   name = "prometheus-remote-writer"

#   assume_role_policy = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#           "Action": "sts:AssumeRole",
#           "Principal": {
#               "Service": "eks.amazonaws.com"
#           },
#           "Effect": "Allow"
#         },
#         {
#           "Effect": "Allow",
#           "Action": "sts:AssumeRoleWithWebIdentity",
#           "Principal": {
#               "Federated": "${module.eks.oidc_provider_arn}"
#           },
#           "Condition":{
#             "StringEquals":{
#                 "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub":[
#                   "system:serviceaccount:monitoring:prometheus"
#                 ]
#             }
#           }
#         },
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                 "AWS": "arn:aws:iam::${local.aws_account_id}:root"
#             },
#             "Effect": "Allow",
#             "Condition": {
#               "ArnEquals": {
#                 "aws:PrincipalArn": "arn:aws:iam::${local.aws_account_id}:role/prometheus-remote-writer"
#               }
#             }
#         }     
#     ]
# }
# POLICY
# }

# #######################################################

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

