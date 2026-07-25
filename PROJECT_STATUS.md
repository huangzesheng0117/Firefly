# Packet & Path Project Status

Last updated: 2026-07-25

## Purpose

Packet & Path is ZeSheng Huang's public network engineering portfolio. It is intended to support technical interviews by presenting selected project delivery experience, production incident investigations, architecture decisions, change controls, and network automation work.

## Current Status

| Area | Status | Notes |
|---|---|---|
| Case archive | Complete | Selected source material is stored under `../Case/`; source directories on `E:` were not modified. |
| Local environment | Complete | Node.js 24.18.0, Git 2.55.0, and repository-pinned pnpm 9.14.4. |
| Blog framework | Complete | Firefly 6.15.0 on Astro 7.0.7. |
| Site identity | Complete | `Packet & Path`, author `ZeSheng Huang`, Chinese UI, network engineering metadata. |
| Source control | Complete | GitHub repository: `huangzesheng0117/Firefly`; `master` deploys automatically. |
| Cloud deployment | Complete | Cloudflare Worker project `firefly` builds with `pnpm build` and deploys with `pnpm exec wrangler deploy`. |
| Production domain | Live | `https://www.next-hop.tech/` is publicly available over HTTPS. |
| Content migration | Not started | The default Firefly demonstration posts are still present. |
| Case sanitization | Not started | Selected cases still require customer, address, credential, topology, and configuration redaction before publication. |

## Repository Layout

| Path | Purpose |
|---|---|
| `src/content/posts/` | Published Markdown and MDX articles. |
| `src/content/spec/about.md` | Public About page. |
| `src/config/` | Site identity, navigation, profile, page switches, comments, and appearance. |
| `src/pages/`, `src/layouts/` | Page routing and overall structure. |
| `src/components/`, `src/styles/` | UI components and visual customization. |
| `docs/reference/` | Maintenance references that are not published as blog content. |
| `scripts/archive-fqzlr-posts.ps1` | Refreshes the local fqzlr.com article archive. |

## Deployment Flow

1. Edit and preview locally with `pnpm dev` at `http://localhost:5173`.
2. Validate with `pnpm check` and `pnpm build`.
3. Commit changes and push `master` to GitHub.
4. Cloudflare pulls the repository, builds the static site, and deploys Worker assets.
5. Cloudflare serves the production site through `www.next-hop.tech`.

## Validation Baseline

- `pnpm check`: 185 files, zero errors and zero warnings at initialization.
- `pnpm build`: successful static production build and Pagefind index generation.
- `pnpm type-check`: currently fails on pre-existing Firefly TypeScript 6 typing issues in upstream template files; no project customization introduced those errors.
- Desktop and mobile visual review is still required after replacing demonstration content.

## Known Follow-ups

1. Remove Firefly demonstration posts and dynamic content.
2. Replace the template avatar, wallpaper, announcement, and remaining demonstration visuals.
3. Select the first three portfolio cases and create sanitized article outlines.
4. Establish a repeatable redaction checklist before any case is committed.
5. Verify the apex domain `https://next-hop.tech/` redirects to the canonical `www` URL.
6. Align `wrangler.jsonc` with the Cloudflare Worker project name and committed custom-domain configuration.
7. Decide whether comments and analytics are needed; keep them disabled until privacy requirements are defined.

## Security Rules

- Never publish raw production configurations, credentials, hashes, tokens, customer contacts, serial numbers, licenses, or unredacted topology screenshots.
- Use documentation-safe IP ranges and anonymized organization/device names in public articles.
- Store Cloudflare and GitHub credentials outside the repository.
- Treat `../Case/` as private source material; only sanitized derivatives belong under `src/content/posts/`.
