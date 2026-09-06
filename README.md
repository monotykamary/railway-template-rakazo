# Rakazo on Railway (template source)

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/rakazo?referralCode=ZqgrJ0)

This repository is the deployment source for the **Rakazo** template on the
Railway marketplace. Rakazo is an open-source platform for running persistent
AI teammates — bots with their own conversations, memory, routines, and a
computer (browser, terminal, files, desktop) they actually operate.

It deploys the upstream published application image with one small adapter so
Postgres-backed services can own a Railway volume, plus a Railway Postgres
database.

## Service topology

| Service | Image / source | Role |
| --- | --- | --- |
| `web` | upstream image (pinned) | Public web app; same-origin proxies `/api` and `/rpc` to the API. Owns the public domain. |
| `api` | this repo `Dockerfile` | Hono API server (`:3100`). Runs `prisma migrate deploy` at start. |
| `worker` | this repo `Dockerfile` | Graphile Worker process (jobs, routines, wakeup). |
| `postgres` | `postgres:16` | Primary datastore (auth, threads, memory, queues). No Redis needed. |

The sandbox supervisor and browser-computer containers from upstream's Docker
provider are intentionally **not** deployed: Railway has no nested Docker
daemon. Bot computers run through Rakazo's first-class remote providers
(E2B, Daytona, or Box) instead — the same configuration upstream's own
production Compose file recommends.

## Pinned versions

- Upstream release: **v0.1.1** (commit `01a210225ed1818c4f41c902c45d1b5143f8ee68`)
- Application image: `ghcr.io/elie222/rakazo/app@sha256:f3c31787c2a5be058aef9842e35840d4b84c356dff3b02b436bd0b0d9df65b3c` (multi-arch amd64 + arm64)
- Postgres: `postgres:16`

The upstream project has not published `vX.Y.Z` image tags to GHCR yet, so the
template pins the immutable `sha-<commit>` image built from the exact v0.1.1
commit rather than a moving `edge` tag.

## The adapter

`Dockerfile` + `docker/entrypoint.sh` add one behavior to the pinned upstream
image: as root, `chown` `DATA_DIR` to the image's `node` user (Railway mounts
volumes root-owned and the upstream image runs as uid 1000), then `exec` the
service start command as `node` via `setpriv` so signal handling stays
correct. There is no other change: no forked code, no config generation, no
reverse proxy — `web` already same-origin proxies API traffic.

## Post-deploy setup

1. Open the `web` domain and register. **The first registered user becomes the
   deployment owner.** If you need a private deployment, set
   `SIGNUP_ALLOWLIST` before the first API start.
2. Connect a model in **Connect a model** (OpenRouter or your own
   OpenAI-compatible endpoint), or set `OPENROUTER_API_KEY`.
3. For bot computers, set `SANDBOX_PROVIDER` (`e2b`, `daytona`, or `box`) and
   the matching `E2B_API_KEY` / `DAYTONA_API_KEY` / `BOX_API_KEY`.
4. Optional: `SMTP_URL` + `EMAIL_FROM` enable forgotten-password recovery.

## Limitations (documented honestly)

- **Docker bot computers are not available on Railway.** They require the host
  Docker socket and sibling containers. Use E2B, Daytona, or Box — without a
  provider key the product boots and bots chat, but computer tools are
  unavailable (`SANDBOX_PROVIDER=none` fallback).
- **iMessage integration** is macOS-only and unavailable.
- Per-user local model endpoints must be reachable HTTPS URLs (loopback/
  private targets are rejected by upstream policy unless allowed).

## Updating

Bump the pinned image digest in `Dockerfile` deliberately after verifying the
new upstream release at the registry. The API runs `prisma migrate deploy`
before serving; check upstream release notes for coordinated-cutover
migrations. GitHub-source auto-deploy updates this wrapper, not the pinned
upstream image — version bumps remain deliberate.

## Source and license

- Upstream: <https://github.com/elie222/rakazo> (self-hosting docs:
  `docs/self-host.md`)
- License: Apache-2.0 (see `LICENSE`, copied unchanged from upstream)
- Icon: `icons/rakazo.png` is the unchanged official desktop asset from
  upstream at tag `v0.1.1`
