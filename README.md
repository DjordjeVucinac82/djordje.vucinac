# djordje.vucinac.com

Personal portfolio website with a terminal / YAML aesthetic.

Black background, red YAML keys, yellow YAML values — styled to look like a macOS iTerm2 session.

## Pages

| Page | File | Content |
|---|---|---|
| About Me | `site/about.html` | Name, role, skills, contact links |
| Education | `site/education.html` | MSc Economics, BSc Marketing, CCNA |
| Experience | `site/experience.html` | 5 jobs: AxiomQ, Jaggaer, HTEC, Noubis, Symlink |
| Hobbies | `site/hobbies.html` | Scuba diving, hiking, open source, reading, AI |

## Tech Stack

- **Frontend** — plain HTML / CSS / JS, no framework, JetBrains Mono font
- **Testing** — Playwright (Chromium)
- **Container** — Docker (`nginx:stable-alpine`)
- **Infra** — Terraform: S3 (private) + CloudFront (OAC) + ACM + Route 53
- **Hosting** — AWS S3 + CloudFront (CDN + HTTPS)

## Run locally

```bash
npm install
npx playwright install chromium
npx http-server site -p 8080
# open http://localhost:8080/about.html
```

## Run tests

```bash
npm test
```

## Docker

```bash
docker build -t vucinac .
docker run --rm -p 8081:80 vucinac
# open http://localhost:8081/about.html
```

## Deploy to AWS

```bash
# 1. Provision infrastructure (first time only)
cd terraform
terraform init
terraform apply

# 2. Upload site files and invalidate CloudFront cache
./scripts/deploy.sh
```

With a custom domain:

```bash
terraform apply -var="domain_name=djordje.vucinac.com"
```

See `COMMANDS.md` for the full reference (Terraform variables, headed tests, teardown, etc).

## Project structure

```
vucinac/
├── site/               # Frontend — HTML, CSS, JS, images
├── terraform/          # AWS infrastructure (S3, CloudFront, ACM, Route 53)
├── tests/              # Playwright E2E tests
├── scripts/
│   └── deploy.sh       # S3 sync + CloudFront invalidation
├── Dockerfile
├── COMMANDS.md         # All commands to run, test, and deploy
└── CLAUDE.md           # Project notes and decisions
```
