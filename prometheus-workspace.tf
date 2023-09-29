resource "aws_cloudwatch_log_group" "prometheus_eks" {
  name              = "/aws/prometheus/prometheus_eks"
  retention_in_days = 14
}

resource "aws_prometheus_workspace" "prometheus_eks" {
  alias = "prometheus-eks"

  logging_configuration {
    log_group_arn = "${aws_cloudwatch_log_group.prometheus_eks.arn}:*"
  }
}
