# djordje.vucinac.com — Personal Portfolio Site

## Project Overview
Personal portfolio website with a terminal/YAML aesthetic.
- **Design:** Black background, red YAML keys, yellow YAML values, macOS iTerm2 terminal look
- **Pages:** About Me (landing), Education, Work Experience, Hobbies
- **Domain:** djordje.vucinac.com (subdomain of vucinac.com)
- **Repo:** git@github.com:DjordjeVucinac82/djordje.vucinac.git

---

## Tech Stack
- **Frontend:** Plain HTML / CSS / JS — static site, no framework
- **Testing:** Playwright (Chromium)
- **Containerisation:** Docker (nginx:stable-alpine)
- **Infra provisioning:** Terraform
- **Hosting:** AWS S3 (private bucket) + CloudFront (CDN + HTTPS, OAC)

---

## Project Plan

### Phase 1 — Frontend (HTML/CSS/JS) ✅
- [x] Define site structure and navigation (4 pages + redirect)
- [x] Build base layout: JetBrains Mono font, black background, macOS terminal window chrome
- [x] Design YAML-style content rendering (red keys, yellow values, green comments)
- [x] Build pages:
  - [x] `index.html` — redirect to about.html
  - [x] `about.html` — About Me / landing (real CV data, clickable LinkedIn + GitHub links)
  - [x] `education.html` — MSc Economics + BSc Marketing (Megatrend), CCNA cert
  - [x] `experience.html` — 5 real jobs: AxiomQ, Jaggaer, HTEC, Noubis, Symlink
  - [x] `hobbies.html` — Scuba Diving + Hiking (photo placeholders), Open Source, Reading, AI Engineering
- [x] Add navigation between pages (tab bar)
- [x] Fixed terminal width to 920px across all pages
- [x] Clickable links styled as `.yaml-link` (yellow, hover underline)
- [x] Scroll-to-top on refresh (`history.scrollRestoration = 'manual'`)
- [x] Photo grid placeholders for hobbies (3 slots per hobby, `site/images/hobbies/`)
- [x] Test locally (`npx http-server site -p 8080`)
- [x] Playwright E2E tests passing
- [x] Dockerfile — `nginx:stable-alpine`, serves `site/` on port 80

### Phase 2 — Terraform Infra ✅
- [x] S3 bucket (private, OAC — not public read)
- [x] S3 bucket policy (CloudFront OAC only, scoped by SourceArn)
- [x] CloudFront distribution (OAC, PriceClass_100, redirect-to-https)
- [x] ACM certificate (conditional on domain_name, us-east-1 via provider alias)
- [x] Route 53 DNS records (conditional on domain_name)
- [x] Outputs: CloudFront URL, S3 bucket name, distribution ID, site URL

### Phase 3 — Deployment
- [ ] Upload site files to S3 (`./scripts/deploy.sh`)
- [ ] Verify CloudFront distribution serves the site
- [ ] Configure custom domain (`terraform apply -var="domain_name=djordje.vucinac.com" -var="zone_name=vucinac.com"`)
- [x] Set up CI/CD (GitHub Actions → S3 sync) — `.github/workflows/deploy.yml`, triggers on push to dev

---

## Decisions & Notes
- Domain name: **djordje.vucinac.com** — subdomain of vucinac.com; Route 53 hosted zone ID: `Z014736319T5HMNYUSKNU`
- Terraform requires two vars: `domain_name=djordje.vucinac.com` and `zone_name=vucinac.com` (zone lookup uses parent domain, not subdomain)
- Git repo: **github.com/DjordjeVucinac82/djordje.vucinac** — default branch is `dev`
- Content: **real CV data populated** — experience, education, hobbies all updated
- Hobby photos: **pending** — drop images into `site/images/hobbies/` when ready
- AWS region: **eu-central-1** for S3/CloudFront; ACM always **us-east-1** (AWS requirement, handled by provider alias)
- S3 bucket is **private** — CloudFront accesses it via OAC (more secure than public bucket)
- Tab labels: plain names (`about`, `education`, `experience`, `hobbies`) — no `-zsh` suffix

---

## File Structure
```
vucinac/
├── CLAUDE.md               # This file
├── COMMANDS.md             # How to run everything
├── Dockerfile              # nginx:stable-alpine, serves site/ on port 80
├── package.json            # Playwright + http-server
├── playwright.config.js    # Playwright config (must be at project root)
├── site/                   # Frontend source
│   ├── index.html          # Redirect to about.html
│   ├── about.html          # Real CV: name, role, skills, LinkedIn, GitHub
│   ├── education.html      # MSc Economics, BSc Marketing, CCNA
│   ├── experience.html     # 5 real jobs (AxiomQ → Symlink)
│   ├── hobbies.html        # Scuba, Hiking (photo slots), Open Source, Reading, AI
│   ├── style.css
│   ├── main.js
│   └── images/
│       └── hobbies/        # Drop hobby photos here (scuba, hiking)
├── terraform/              # AWS infrastructure
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── scripts/
│   └── deploy.sh           # S3 sync + CloudFront invalidation
└── tests/                  # Playwright E2E tests
    ├── about.spec.js
    ├── education.spec.js
    ├── experience.spec.js
    └── hobbies.spec.js
```
