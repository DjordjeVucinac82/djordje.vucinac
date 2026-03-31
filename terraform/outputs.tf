# =============================================================
# outputs.tf — Useful values after terraform apply
# =============================================================

output "s3_bucket_name" {
  description = "S3 bucket name — use this in the deploy script to upload site files"
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.site.arn
}

output "cloudfront_url" {
  description = "CloudFront distribution URL — use this to access the site before a custom domain is configured"
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID — needed to run cache invalidations after deployments"
  value       = aws_cloudfront_distribution.site.id
}

output "site_url" {
  description = "The site URL (custom domain when configured, otherwise the CloudFront URL)"
  value       = local.has_domain ? "https://${var.domain_name}" : "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "acm_certificate_arn" {
  description = "ACM certificate ARN (null when no domain_name is set)"
  value       = local.has_domain ? aws_acm_certificate.site[0].arn : null
}
