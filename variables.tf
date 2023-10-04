variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "monitoring_namespace" {
  description = "Monitoring namespace"
  type        = string
  default     = "monitoring"
}

variable "opensearch_domain_endpoint" {
  description = "OpenSearch domain endpoint"
  type        = string
}


