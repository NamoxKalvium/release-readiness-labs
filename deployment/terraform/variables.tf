variable "aws_secret_key" {
  type        = string
  description = "AWS secret access key supplied securely via CI/CD secrets at runtime"
  sensitive   = true
}

variable "environment" {
  type        = string
  description = "Deployment target environment"
  default     = "production"
}

variable "app_version" {
  type        = string
  description = "Immutable release version tag"
  default     = "v2.3.0"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name for container orchestration"
  default     = "orderflow-prod-cluster"
}
