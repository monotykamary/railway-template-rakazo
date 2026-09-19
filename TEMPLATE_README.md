# Deploy and Host Rakazo on Railway

Rakazo is an open-source platform for running persistent AI teammates you
actually own: bots with their own conversations, memory, routines, and a real
computer (browser, terminal, files, graphical desktop) they operate themselves.
Bring your own model credentials and your own computer provider.

## About Hosting Rakazo

This template deploys four services:

- **web** — the public web app. It owns the Railway public domain and
  same-origin-proxies `/api` and `/rpc` to the API, so only one public
  endpoint is exposed.
- **api** — the Hono API server. Applies database migrations
  (`prisma migrate deploy`) before serving and reports readiness at
  `GET /health`.
- **worker** — the Graphile Worker process handling routines, wakeup jobs, and
  background work on top of Postgres (no Redis required).
- **postgres** — PostgreSQL 18 (`postgres-ssl:18`), the single durable datastore.

Bot computers run on Rakazo's remote providers (E2B, Daytona, or Box) instead
of local Docker containers, which matches upstream's own production
recommendation for hosts without a nested Docker daemon.

## Common Use Cases

- Always-on personal AI assistants with persistent memory and routines
- Team workspaces where several bots share a Team Computer and delegate to
  each other or to short-lived subagents
- Browser automation and research bots driven by vision models
- Voice-mode bots using your own ElevenLabs, OpenAI, or Cartesia key
- Bots reachable from Slack, WhatsApp, Telegram, Feishu/Lark webhooks

## Dependencies for Rakazo Hosting

### Deployment Dependencies

- **A model credential.** Set `OPENROUTER_API_KEY`, or connect a provider
  per-user in the UI after signup.
- **A computer provider (optional but recommended).** Set
  `SANDBOX_PROVIDER=e2b` (default) plus `E2B_API_KEY` — or `daytona`/`box`
  with the matching key. Without a key the product still boots and bots chat,
  but computer tools are unavailable.
- Nothing else: queues and state live in the bundled Postgres service.

### Implementation Details

- All application services come from the pinned upstream image
  (`ghcr.io/elie222/rakazo/app` at the v0.1.6 release commit, multi-arch).
- `api` and `worker` use a one-behavior adapter that takes ownership of the
  Railway volume at `DATA_DIR` on boot and then runs as the image's unprivileged
  `node` user.
- The `web` service publishes the upstream Vite preview server on `PORT=5173`. That server only
  answers allow-listed hostnames, so the template relies on Railway's port check for `web` and
  keeps the HTTP healthcheck on `api` (`GET /health`). If you attach a custom domain, set
  `RAKAZO_HOST` to that hostname so the preview server accepts it.
- Generated secrets (`BETTER_AUTH_SECRET`, `ENCRYPTION_KEY`,
  `SCREEN_PROXY_SECRET`) are created for you at deploy time. Do not regenerate
  `ENCRYPTION_KEY` after the first start: stored credentials would become
  undecryptable.
- Cross-service references (`DATABASE_URL`, `API_PROXY_TARGET`, the public
  origin variables `BETTER_AUTH_URL`, `WEB_ORIGIN`, `API_URL`, and
  `RAKAZO_HOST`) are wired between services. Do not edit them by hand.
- The **first registered user becomes the deployment owner**. Register
  immediately after deploy. To keep the deployment private, set
  `SIGNUP_ALLOWLIST` before the first API start.

### Why Deploy Rakazo on Railway?

- One-click full stack: web, API, worker, and Postgres with migrations,
  health checks, and private networking pre-wired.
- Persistent volumes for workspace state and a database that survives
  redeploys.
- Scale each service independently; the public web endpoint stays the same.
- BYO model and BYO sandbox keep your credentials and workspaces under your
  control.
