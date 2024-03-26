data "aws_iam_policy_document" "grafana_eks" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"      
      values   = ["system:serviceaccount:monitoring:grafana"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]        
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_grafana" {
  assume_role_policy = data.aws_iam_policy_document.grafana_eks.json
  name               = "${local.cluster_name}-eks-grafana"
}

resource "aws_iam_role_policy_attachment" "grafana_eks_query_access" {
  role       = aws_iam_role.eks_grafana.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess"
}
