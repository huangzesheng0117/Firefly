# Packet & Path Project Status

Last updated: 2026-07-25

## Purpose

Packet & Path is ZeSheng Huang's public network engineering portfolio. It is intended to support technical interviews by presenting selected project delivery experience, production incident investigations, architecture decisions, change controls, and network automation work.

## Current Status

| Area | Status | Notes |
|---|---|---|
| Case archive | Complete | 29 selected candidates, 1,704 files and about 5.46 GiB are stored under `../Case/`; source directories on `E:` were not modified. |
| Local environment | Complete | Node.js 24.18.0, Git 2.55.0, and repository-pinned pnpm 9.14.4. |
| Blog framework | Complete | Firefly 6.15.0 on Astro 7.0.7. |
| Site identity | Complete | `Packet & Path`, author `ZeSheng Huang`, Chinese UI, network engineering metadata. |
| Source control | Complete | GitHub repository: `huangzesheng0117/Firefly`; `master` deploys automatically. |
| Cloud deployment | Complete | Cloudflare Worker project `firefly` builds with `pnpm build` and deploys with `pnpm exec wrangler deploy`. |
| Production domain | Live | Both `https://next-hop.tech/` and `https://www.next-hop.tech/` are bound to the `firefly` Worker as Custom Domains. |
| Performance baseline | Accepted | Mainland China and global test nodes currently load in about 1.5-3 seconds; IP optimization is deferred and documented only as a contingency. |
| Maintenance guide | Complete | The local edit, validation, GitHub, Cloudflare, rollback, and upstream sync workflow is documented in `docs/MAINTENANCE.md`. |
| Writing standard | Complete | Frontmatter, naming, media, Markdown extensions, SEO, link stability, quality, and security rules are documented in `docs/MAINTENANCE.md`. |
| Reference archive | Complete | 18 fqzlr.com posts are archived locally; full HTML and RSS content is excluded from the public repository. |
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
| `docs/MAINTENANCE.md` | Detailed editing, validation, deployment, rollback, and upstream synchronization procedures. |

## Deployment Flow

1. Edit and preview locally with `pnpm dev` at `http://localhost:5173`.
2. Validate with `pnpm check` and `pnpm build`.
3. Commit changes and push `master` to GitHub.
4. Cloudflare pulls the repository, builds the static site, and deploys Worker assets.
5. Cloudflare serves the production site through `www.next-hop.tech`.

Detailed commands and troubleshooting are maintained in [`docs/MAINTENANCE.md`](docs/MAINTENANCE.md).

## Local Workspace Layout

```text
D:\Projects\Personal Blog\
├── Case\       Private source cases and screening records
└── website\    Firefly source repository and project documentation
```

`Case` is not part of the public Git repository. Only sanitized derivatives may be moved into `website/src/content/posts/`.

## Git Remote Model

| Remote | URL | Purpose |
|---|---|---|
| `origin` | `https://github.com/huangzesheng0117/Firefly.git` | Personal source repository and Cloudflare deployment source. |
| `upstream` | `https://github.com/CuteLeaf/Firefly.git` | Read-only source for reviewing and manually merging Firefly updates. |

Pushing to `origin` does not change the upstream Firefly project. Fork updates are not automatic and must be reviewed, merged, validated, and pushed manually.

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
5. Decide whether comments and analytics are needed; keep them disabled until privacy requirements are defined.
6. Keep `docs/MAINTENANCE.md` current when the build, deployment, domain, or editing workflow changes.

## Security Rules

- Never publish raw production configurations, credentials, hashes, tokens, customer contacts, serial numbers, licenses, or unredacted topology screenshots.
- Use documentation-safe IP ranges and anonymized organization/device names in public articles.
- Store Cloudflare and GitHub credentials outside the repository.
- Treat `../Case/` as private source material; only sanitized derivatives belong under `src/content/posts/`.
