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

variable "zone_name" {
  description = <<-EOT
    Route53 hosted zone name — the parent domain that owns the hosted zone.
    For a subdomain like djordje.vucinac.com, this should be "vucinac.com".
    For an apex domain like vucinac.com, this should be "vucinac.com".
    Must already exist as a hosted zone in your AWS account.
  EOT
  type        = string
  default     = ""
}

variable "aws_profile" {
  description = "AWS CLI profile to use for authentication (from ~/.aws/credentials or ~/.aws/config)"
  type        = string
  default     = "vucinac"
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
