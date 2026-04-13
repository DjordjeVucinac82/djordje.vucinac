# djordje.vucinac.com — Commands

## Prerequisites
- Node.js 24+
- npm
- Terraform >= 1.5 (for infra)
- AWS CLI configured (for deployment)

## Install dependencies
```bash
npm install
npx playwright install chromium
```

## Run locally (development preview)
```bash
npx http-server site -p 8080
```
Then open: http://localhost:8080/aboutme.html

## Run Playwright tests (headless)
```bash
npm test
```

## Run tests with browser visible (headed)
```bash
npm run test:headed
```

## Run tests with Playwright interactive UI explorer
```bash
npm run test:ui
```

## Docker — build and run locally

```bash
# Build the image
docker build -t vucinac .

# Run on port 8081 (or any free port)
docker run --rm -p 8081:80 vucinac
```
Then open: http://localhost:8081/aboutme.html

---

## Update content
All site content lives in `site/*.html`.
Edit the relevant file and refresh the browser — no build step needed.
- `site/aboutme.html` — name, role, skills, contact
- `site/education.html` — degree, certifications
- `site/experience.html` — work history
- `site/hobbies.html` — hobbies and interests

---

## Terraform — AWS Infrastructure

### Prerequisites
- Terraform >= 1.5 (`brew install terraform`)
- AWS CLI configured with `vucinac` profile (`aws configure --profile vucinac`)
- AWS credentials with permissions for S3, CloudFront, ACM, Route53

### Deploy infrastructure
```bash
cd terraform
terraform init
terraform plan -var="domain_name=djordje.vucinac.com" -var="zone_name=vucinac.com"
terraform apply -var="domain_name=djordje.vucinac.com" -var="zone_name=vucinac.com"
```
After apply, the site URL is printed as `site_url` output (https://djordje.vucinac.com).
- `domain_name` — subdomain the site is served on: `djordje.vucinac.com`
- `zone_name` — parent Route53 hosted zone: `vucinac.com` (hosted zone ID: `Z014736319T5HMNYUSKNU`)

### Destroy all infrastructure
```bash
cd terraform
terraform destroy
```

---

## Deploy site files to AWS

**Normal workflow:** push to `dev` — GitHub Actions handles S3 sync and CloudFront invalidation automatically.

**Manual deploy** (if needed outside of CI/CD):
```bash
./scripts/deploy.sh
```

This script:
1. Reads S3 bucket name and CloudFront distribution ID from Terraform outputs
2. Syncs `site/` to S3 (with `--delete` to remove old files; `*.pdf` files are excluded from deletion to preserve manually uploaded assets like the CV)
3. Creates a CloudFront invalidation to flush the cache

---

## GitHub Actions — CI/CD setup

The workflow (`.github/workflows/deploy.yml`) auto-deploys on every push to `dev` (including merged PRs).

### Repository secrets (already configured)

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | from local `vucinac` AWS profile |
| `AWS_SECRET_ACCESS_KEY` | from local `vucinac` AWS profile |
| `S3_BUCKET_NAME` | `vucinac-portfolio-site` |
| `CLOUDFRONT_DISTRIBUTION_ID` | `E3KR8GF7MNX17R` |

To re-set secrets from the local `vucinac` profile:
```bash
gh secret set AWS_ACCESS_KEY_ID --body "$(aws configure get aws_access_key_id --profile vucinac)" --repo DjordjeVucinac82/djordje.vucinac
gh secret set AWS_SECRET_ACCESS_KEY --body "$(aws configure get aws_secret_access_key --profile vucinac)" --repo DjordjeVucinac82/djordje.vucinac
```

### IAM permissions for the vucinac profile (minimal required)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:DeleteObject", "s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::vucinac-portfolio-site",
        "arn:aws:s3:::vucinac-portfolio-site/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::646485834024:distribution/E3KR8GF7MNX17R"
    }
  ]
}
```

---

## Terraform variables reference

| Variable       | Default        | Description                                      |
|----------------|----------------|--------------------------------------------------|
| `project`      | `"vucinac"`    | Used for resource naming and tags                |
| `environment`  | `"production"` | Tag value                                        |
| `aws_profile`  | `"vucinac"`    | AWS CLI profile used for authentication |
| `domain_name`  | `""`           | Custom domain e.g. `djordje.vucinac.com` — leave empty until domain is ready |
| `zone_name`    | `""`           | Parent Route53 hosted zone e.g. `vucinac.com` — required when domain_name is set |
| `aws_region`   | `"eu-central-1"` | S3/CloudFront region; ACM always uses us-east-1 automatically |
