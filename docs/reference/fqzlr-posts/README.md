# fqzlr.com Posts Reference

This directory holds a local maintenance reference for the public articles listed at <https://www.fqzlr.com/posts/>.

## Contents

- `INDEX.md`: generated source URL and local filename index.
- `index.html`: local snapshot of the article list.
- `rss.xml`: complete RSS snapshot containing article bodies.
- `*.html`: one original HTML snapshot per article.

Run the refresh script from the repository root:

```powershell
pnpm --version
powershell -ExecutionPolicy Bypass -File .\scripts\archive-fqzlr-posts.ps1
```

The HTML and RSS snapshots are intentionally ignored by Git. They are stored locally for private maintenance research and must not be republished as Packet & Path content. Copyright remains with the original author. Always use the source URL when referring to an article.
