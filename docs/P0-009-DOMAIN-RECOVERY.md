# Info P0-009 domain recovery

- Freeze tag: `p0-009a-pre-20260729`
- Scope: the parent repository and all four Info component repositories
- Purpose: recover or compare the complete pre-migration Admin/Web source.

The freeze tag is the only authoritative pre-migration archive. Do not copy old
source trees, `.env*` files, generated Prisma clients, binaries, build output, or
dependency directories into the post-migration repositories.

Inspect a historical file without restoring it:

```bash
git clone https://github.com/sunmoonlion/info-web-backend.git \
  /tmp/info-web-backend-archive
git -C /tmp/info-web-backend-archive \
  show p0-009a-pre-20260729:app/src/example.ts
```

Create an isolated recovery worktree:

```bash
git -C /tmp/info-web-backend-archive \
  worktree add /tmp/info-web-backend-pre-p0-009 \
  p0-009a-pre-20260729
```

The retained domain implementation lives in the normal post-migration source
tree and must be covered by its source, contract, image, and pair gates.
