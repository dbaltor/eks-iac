variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "dns_domain" {
  description = "DNS domain"
  type        = string
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

variable "smtp_password" {
  description = "SMTP password to be used by Superset"
  type        = string
}