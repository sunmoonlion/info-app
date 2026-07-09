# Info App Frontend Plan

## Decision

`info-app` keeps the normal platform pairing:

```text
info-admin-frontend (Vue 3 + Vite + Element Plus)
  -> info-admin-backend /api/admin/** and document/governance APIs

info-web-frontend (Next.js)
  -> public/user-facing information product pages
  -> info-web-backend BFF when SSR, aggregation, public auth, or SEO needs it
```

The v4 `research-app` Agent exception does not automatically apply here. `info-app`
is an information ingestion and governance product, not a LangGraph runtime. Its
management workflows belong in the admin pair.

## Admin Frontend Scope

Use `info-admin-frontend` for internal operations:

- source registration and governance fields;
- collector setup and discovery;
- URL crawl and upload workflows;
- document review and extraction status;
- entity links and summary profile edits;
- Knowledge distribution creation, dispatch, retry, and status inspection;
- admin-only diagnostics and operational recovery.

The current minimum governance workspace lives in:

```text
info-admin-frontend/src/pages/info/crawl.vue
```

Next admin productization steps:

1. Add filters for document status, source, extraction status, and distribution status.
2. Add batch review/distribution operations.
3. Add audit timeline display from document metadata/status history.
4. Split the current single page when the workflow becomes crowded.

## Web Frontend Scope

Use `info-web-frontend` for user-facing information experiences:

- search/browse published information;
- topic/source landing pages;
- SEO/SSR pages;
- user-facing reading and saved views;
- public or tenant-facing pages that should not expose admin operations.

`info-web-frontend` should not call admin governance endpoints directly. If it
needs aggregation, SSR, or public-user auth, use `info-web-backend` as the BFF.

## API Boundary Rules

- Admin UI may use `info-admin-backend` admin/governance APIs.
- Web UI may use `info-web-backend` or explicitly public read APIs only.
- Do not move internal governance operations into `info-web-frontend`.
- Do not bypass `info-web-backend` for public SSR/auth aggregation unless a
  documented read-only public API exists.

## Validation

- `info-admin-frontend`: run `pnpm type-check` and `pnpm build-only` after UI changes.
- `info-web-frontend`: run `pnpm typecheck` and `pnpm build` after UI changes.
- Deployment image changes should use a new semver tag rather than silently
  overwriting a validated tag when behavior changes.
