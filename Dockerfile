# ── Build stage not needed — pure static site ──────────────────────────────
# nginx:stable-alpine is small (~8 MB) and well-suited for serving static files
FROM nginx:stable-alpine

# Remove the default nginx welcome page
RUN rm -rf /usr/share/nginx/html/*

# Copy all site files into the nginx web root
# The site/ directory contains index.html, about.html, style.css, main.js, etc.
COPY site/ /usr/share/nginx/html/

# nginx listens on port 80 by default
EXPOSE 80

# Default CMD from the base image starts nginx in the foreground — no override needed
