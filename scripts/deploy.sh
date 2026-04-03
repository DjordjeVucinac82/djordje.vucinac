#!/usr/bin/env bash
# =============================================================
# deploy.sh — Upload site files to S3 and invalidate CloudFront cache
#
# Usage:
#   ./scripts/deploy.sh
#
# Requirements:
#   - AWS CLI configured (aws configure)
#   - Terraform applied (terraform apply) — reads outputs for bucket/distribution IDs
#   - Run from the project root directory
# =============================================================

set -euo pipefail

# ── Read outputs from Terraform ───────────────────────────────
echo "Reading Terraform outputs..."

BUCKET_NAME=$(terraform -chdir=terraform output -raw s3_bucket_name)
DISTRIBUTION_ID=$(terraform -chdir=terraform output -raw cloudfront_distribution_id)
SITE_URL=$(terraform -chdir=terraform output -raw site_url)

echo "S3 bucket:      $BUCKET_NAME"
echo "Distribution:   $DISTRIBUTION_ID"
echo "Site URL:       $SITE_URL"
echo ""

# ── Upload site files to S3 ───────────────────────────────────
echo "Syncing site/ to s3://$BUCKET_NAME ..."

aws s3 sync site/ "s3://$BUCKET_NAME" \
  --delete \
  --cache-control "max-age=86400" \
  --exclude ".DS_Store" \
  --exclude "*.swp" \
  --exclude "*.pdf"

echo "Upload complete."
echo ""

# ── Invalidate CloudFront cache ───────────────────────────────
# This forces CloudFront to fetch the latest files from S3.
# Without this, users may see stale cached content for up to 24h.
echo "Creating CloudFront invalidation..."

INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*" \
  --query "Invalidation.Id" \
  --output text)

echo "Invalidation created: $INVALIDATION_ID"
echo ""

# ── Done ──────────────────────────────────────────────────────
echo "Deployment complete!"
echo "Site available at: $SITE_URL"
echo ""
echo "Note: CloudFront invalidation takes ~30-60 seconds to propagate."
