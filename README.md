# FluxMintDigital — fluxmintdigital.com

Jekyll site for the FluxMintDigital Architecture Studio. Built to match the visual
theme of fluxmintdigital.github.io (Inter + Merriweather, blue/purple accent) but
as a separate site/repo for the new `.com` domain.

## What's included

Nine pages, all driven by editable data files where possible:

- `/` — Homepage
- `/books/` — Books Division
- `/apps/` — Apps Division
- `/tools/` — Tools Division
- `/science/` — Science Division
- `/services/` — Architecture Services
- `/blog/` — Blog Division (links out to `/studio-blog/` and the existing github.io blog)
- `/studio-blog/` — Studio Blog post archive (empty until you publish a post)
- `/store/` — Store
- `/about/` — About

## 1. Put this on GitHub

1. Create a **new, empty** GitHub repo named exactly `fluxmintdigital-com`
   (or any name — it doesn't need to match a `username.github.io` pattern
   because we're using a custom domain).
2. On your computer, in this folder, run:
   ```bash
   git init
   git add .
   git commit -m "Initial site build"
   git branch -M main
   git remote add origin https://github.com/fluxmintdigital/fluxmintdigital.com.git
   git config --global credential.helper store
   git push -u origin main
   ```

## 2. Turn on GitHub Pages

1. In the repo on GitHub: **Settings → Pages**.
2. Under "Build and deployment," set **Source** to "Deploy from a branch."
3. Set **Branch** to `main` and folder to `/ (root)`. Save.
4. Under "Custom domain," enter `fluxmintdigital.com` and save.
   (The `CNAME` file already in this repo also declares this, so GitHub should
   pick it up automatically — but set it in the UI too, that's what actually
   triggers the free HTTPS certificate.)

## 3. Point your domain at GitHub

At your domain registrar (wherever you bought fluxmintdigital.com), add these
DNS records:

**A records** (for the root domain `fluxmintdigital.com`) pointing to GitHub's
IPs — add all four:
```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

**CNAME record** (for `www.fluxmintdigital.com`) pointing to:
```
<your-username>.github.io
```

DNS changes can take anywhere from a few minutes to 24 hours to propagate.
Once it resolves, go back to Settings → Pages and check "Enforce HTTPS."

## 4. Everyday updates (from your terminal)

Same workflow as your existing blog:

```bash
cd fluxmintdigital-com
git pull
# ...edit files...
git add .
git commit -m "Describe what you changed"
git push
```

Check the **Actions** tab on GitHub to watch the build; it's usually live
within a couple of minutes.

## 5. How to add things without touching the templates

Most lists on this site are pulled from small YAML files in `_data/` —
editing these is the easiest way to add or update items without touching
any HTML:

- `_data/books.yml` — book series (name, tagline, description, status, link)
- `_data/apps.yml` — apps (name, tagline, description, status, link)
- `_data/tools.yml` — tool/framework categories and examples
- `_data/services.yml` — architecture services
- `_data/science.yml` — scientific models

Set `status: live` (instead of `coming_soon`) and fill in `link:` once a
book or app has a real purchase/download URL — the templates already check
for this, though right now the pages only render the "Coming Soon" badge.
If you want the link to actually render as a button once something goes
live, tell your AI assistant and it can wire that in quickly.

## 6. Publishing a Studio Blog post

Add a new file to `_posts/` named `YYYY-MM-DD-title.md`:

```markdown
---
layout: post
title: "Your Post Title"
description: "One or two sentence summary."
categories: [Architecture]
tags: ["frameworks", "systems"]
---

Post content in Markdown goes here.
```

It will automatically show up at `/studio-blog/` and get its own page at
`/YYYY/MM/DD/title/`.

## 7. Local preview before pushing (optional)

```bash
bundle install
bundle exec jekyll serve
```

Then open `http://localhost:4000`.
