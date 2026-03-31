# =============================================================
# variables.tf — Input variables for djordje.vucinac.com infrastructure
# =============================================================

variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "vucinac"
}

variable "environment" {
  description = "Deployment environment (used for tagging)"
  type        = string
  default     = "production"
}

variable "domain_name" {
  description = <<-EOT
    Primary domain name (e.g. "djordje.vucinac.com").
    Leave empty ("") to deploy without a custom domain.
    When empty: S3 + CloudFront are deployed and the CloudFront URL is the site URL.
    When set:  ACM certificate + Route53 records are also created.
    NOTE: The Route53 hosted zone for this domain must already exist in your AWS account.
  EOT
  type        = string
  default     = ""
}

variable "aws_region" {
  description = <<-EOT
    AWS region for S3 and other non-global resources.
    ACM certificates for CloudFront are always created in us-east-1 (AWS hard requirement)
    regardless of this value — a separate provider alias handles that automatically.
  EOT
  type        = string
  default     = "eu-central-1"
}
