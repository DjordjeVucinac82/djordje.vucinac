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
Then open: http://localhost:8080/about.html

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
Then open: http://localhost:8081/about.html

---

## Update content
All site content lives in `site/*.html`.
Edit the relevant file and refresh the browser — no build step needed.
- `site/about.html` — name, role, skills, contact
- `site/education.html` — degree, certifications
- `site/experience.html` — work history
- `site/hobbies.html` — hobbies and interests

---

## Terraform — AWS Infrastructure

### Prerequisites
- Terraform >= 1.5 (`brew install terraform`)
- AWS CLI configured (`aws configure`)
- AWS credentials with permissions for S3, CloudFront, ACM, Route53

### Phase 1 — Deploy without custom domain (S3 + CloudFront only)
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
After apply, the site URL is printed as `cloudfront_url` output.

### Phase 2 — Add custom domain (when domain_name is ready)
```bash
cd terraform
terraform apply -var="domain_name=djordje.vucinac.com"
```
This creates the ACM certificate, validates it via Route53 DNS, and configures CloudFront with the custom domain.

### Destroy all infrastructure
```bash
cd terraform
terraform destroy
```

---

## Deploy site files to AWS

After `terraform apply`, upload the site and invalidate CloudFront:
```bash
./scripts/deploy.sh
```

This script:
1. Reads S3 bucket name and CloudFront distribution ID from Terraform outputs
2. Syncs `site/` to S3 (with `--delete` to remove old files)
3. Creates a CloudFront invalidation to flush the cache

---

## Terraform variables reference

| Variable       | Default        | Description                                      |
|----------------|----------------|--------------------------------------------------|
| `project`      | `"vucinac"`    | Used for resource naming and tags                |
| `environment`  | `"production"` | Tag value                                        |
| `domain_name`  | `""`           | Custom domain — leave empty until domain is ready |
| `aws_region`   | `"eu-central-1"` | S3/CloudFront region; ACM always uses us-east-1 automatically |
