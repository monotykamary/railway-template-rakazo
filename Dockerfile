# Railway adapter over the pinned upstream application image.
# Upstream image: ghcr.io/elie222/rakazo/app at the v0.2.0 release commit (f10b4ff),
# verified multi-arch (linux/amd64 + linux/arm64).
FROM ghcr.io/elie222/rakazo/app:v0.2.0@sha256:2cb2749a580ab228816b0d75af413b0ee43d250b7a7beb36ba8926e92e746037

USER root
COPY docker/entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod 755 /usr/local/bin/railway-entrypoint

ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
