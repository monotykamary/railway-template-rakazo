# Railway adapter over the pinned upstream application image.
# Upstream image: ghcr.io/elie222/rakazo/app at the v0.1.1 release commit (01a2102),
# verified multi-arch (linux/amd64 + linux/arm64).
FROM ghcr.io/elie222/rakazo/app@sha256:f3c31787c2a5be058aef9842e35840d4b84c356dff3b02b436bd0b0d9df65b3c

USER root
COPY docker/entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod 755 /usr/local/bin/railway-entrypoint

ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
