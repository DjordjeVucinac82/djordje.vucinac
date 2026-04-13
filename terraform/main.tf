# =============================================================
# main.tf — djordje.vucinac.com AWS infrastructure
#
# Architecture:
#   S3 (private bucket) ← CloudFront OAC → CloudFront CDN → users
#
# Phase 1 (no domain): S3 + CloudFront only, accessed via CloudFront URL
# Phase 2 (domain set): adds ACM certificate + Route53 records
#
# Cost notes (10-20 users/day):
#   - S3: ~$0.00 (< 1GB storage, minimal requests)
#   - CloudFront PriceClass_100: cheapest class (US, CA, EU)
#   - ACM: free
#   - Route53: $0.50/month per hosted zone (if domain is set)
#   Total estimate: < $1/month
# =============================================================

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local state is fine for a personal project.
  # To use S3 backend (recommended for team use), uncomment below and run:
  #   terraform init -reconfigure
  #
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "vucinac/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ACM certificates for CloudFront MUST be in us-east-1 — this is an AWS hard requirement.
# All other resources use the default provider above (eu-central-1).
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = var.aws_profile
}

# ── Local values ─────────────────────────────────────────────
locals {
  # Unique origin ID used to link CloudFront behavior to the S3 origin
  s3_origin_id = "s3-${var.project}-origin"

  # Common tags applied to all resources
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # True when a custom domain has been provided
  has_domain = var.domain_name != ""
}

# ─────────────────────────────────────────────────────────────
# S3 Bucket — stores the static site files
# ─────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "site" {
  # Bucket name must be globally unique across all AWS accounts.
  # Using project name as prefix to keep it recognisable.
  bucket = "${var.project}-portfolio-site"

  tags = local.common_tags
}

# Block all public S3 access — CloudFront accesses the bucket via OAC (not public URLs)
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning so you can roll back a bad deployment
resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─────────────────────────────────────────────────────────────
# CloudFront Origin Access Control (OAC)
# Modern replacement for Origin Access Identity (OAI).
# Signs requests from CloudFront to S3 using SigV4, so the
# bucket can stay private.
# ─────────────────────────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project}-oac"
  description                       = "OAC for ${var.project} S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ─────────────────────────────────────────────────────────────
# ACM Certificate (only created when domain_name is set)
# Must be in us-east-1 for CloudFront — this is an AWS requirement.
# ─────────────────────────────────────────────────────────────

resource "aws_acm_certificate" "site" {
  count = local.has_domain ? 1 : 0

  # Must use the us-east-1 alias — CloudFront only accepts ACM certs from us-east-1
  provider = aws.us_east_1

  domain_name = var.domain_name

  # Also cover www subdomain with the same certificate
  subject_alternative_names = ["www.${var.domain_name}"]

  # DNS validation is fully automated via Route53 below
  validation_method = "DNS"

  # Create new certificate before destroying the old one
  # to avoid downtime during certificate rotation
  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

# ─────────────────────────────────────────────────────────────
# Route53 — fetch the existing hosted zone for the domain
# ─────────────────────────────────────────────────────────────

data "aws_route53_zone" "site" {
  count = local.has_domain ? 1 : 0

  # Use zone_name (parent domain) not domain_name.
  # For djordje.vucinac.com the hosted zone is vucinac.com, not the subdomain itself.
  name         = var.zone_name
  private_zone = false
}

# ─────────────────────────────────────────────────────────────
# ACM DNS Validation records in Route53
# ACM gives us CNAME records to prove we own the domain.
# ─────────────────────────────────────────────────────────────

resource "aws_route53_record" "cert_validation" {
  # For each domain validation option from the certificate (apex + www)
  for_each = local.has_domain ? {
    for dvo in aws_acm_certificate.site[0].domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.site[0].zone_id
}

# Wait until the certificate is fully validated before using it in CloudFront
resource "aws_acm_certificate_validation" "site" {
  count = local.has_domain ? 1 : 0

  # Must use the same provider as the certificate — both must be in us-east-1
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.site[0].arn

  # Reference all validation CNAME records so Terraform waits for them
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

# ─────────────────────────────────────────────────────────────
# CloudFront Distribution
# ─────────────────────────────────────────────────────────────

resource "aws_cloudfront_distribution" "site" {
  # The S3 bucket is the single origin
  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project} portfolio site"

  # CloudFront returns index.html for requests to the root URL (/)
  # index.html redirects to aboutme.html via meta refresh
  default_root_object = "index.html"

  # Custom domain aliases — only set when domain_name is provided
  aliases = local.has_domain ? [var.domain_name, "www.${var.domain_name}"] : []

  # Default cache behaviour — applies to all paths (GET/HEAD only for a static site)
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false # Static site has no query params to forward

      cookies {
        forward = "none" # Static site has no cookies
      }
    }

    # Force HTTPS — redirect any HTTP requests to HTTPS
    viewer_protocol_policy = "redirect-to-https"

    # Cache for 1 day by default (HTML/CSS/JS rarely change between deployments)
    # Run the deploy script to invalidate after each deployment
    min_ttl     = 0
    default_ttl = 86400    # 1 day
    max_ttl     = 31536000 # 1 year (for assets with cache-busting)

    # Enable gzip/brotli compression to reduce bandwidth costs
    compress = true
  }

  # PriceClass_100 = US, Canada, Europe only — cheapest option.
  # Good for a portfolio aimed at European/US audiences.
  # Upgrade to PriceClass_200 or PriceClass_All if you need global performance.
  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none" # No geo-blocking
    }
  }

  # TLS certificate:
  # - When domain_name is set: use the ACM certificate (SNI, TLS 1.2+)
  # - When domain_name is empty: use the default *.cloudfront.net certificate
  viewer_certificate {
    cloudfront_default_certificate = local.has_domain ? null : true
    acm_certificate_arn            = local.has_domain ? aws_acm_certificate_validation.site[0].certificate_arn : null
    ssl_support_method             = local.has_domain ? "sni-only" : null
    # TLSv1.2_2021 is the most secure option supported by all modern browsers
    minimum_protocol_version = local.has_domain ? "TLSv1.2_2021" : null
  }

  tags = local.common_tags

  # CloudFront depends on the certificate being validated before it can be applied
  depends_on = [aws_acm_certificate_validation.site]
}

# ─────────────────────────────────────────────────────────────
# S3 Bucket Policy — allow CloudFront OAC to read objects
# Grants cloudfront.amazonaws.com GetObject access,
# but only from THIS specific CloudFront distribution (via SourceArn condition).
# This is tighter than a public bucket policy.
# ─────────────────────────────────────────────────────────────

data "aws_iam_policy_document" "site" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    # Restrict to only this CloudFront distribution — prevents other CF distributions
    # from accessing the bucket even if they reference it as an origin
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json

  # Must run after the public access block to avoid a race condition
  # where the policy is applied before public access is blocked
  depends_on = [aws_s3_bucket_public_access_block.site]
}

# ─────────────────────────────────────────────────────────────
# Route53 A Records (only when domain_name is set)
# Alias records point apex and www to the CloudFront distribution.
# Using aliases instead of CNAMEs: free, no TTL, faster resolution.
# ─────────────────────────────────────────────────────────────

# Apex domain (e.g. djordje.vucinac.com → CloudFront)
resource "aws_route53_record" "apex" {
  count = local.has_domain ? 1 : 0

  zone_id = data.aws_route53_zone.site[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# www subdomain (e.g. www.djordje.vucinac.com → CloudFront)
resource "aws_route53_record" "www" {
  count = local.has_domain ? 1 : 0

  zone_id = data.aws_route53_zone.site[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
