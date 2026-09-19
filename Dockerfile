# Railway adapter over the pinned upstream application image.
# Upstream image: ghcr.io/elie222/rakazo/app at the v0.1.6 release commit (84c8689),
# verified multi-arch (linux/amd64 + linux/arm64).
FROM ghcr.io/elie222/rakazo/app@sha256:fb60c6eeed892395f586794928ac8625f1a9553768095f30116d3eb9bd2b5e9a

USER root
COPY docker/entrypoint.sh /usr/local/bin/railway-entrypoint
RUN chmod 755 /usr/local/bin/railway-entrypoint

ENTRYPOINT ["/usr/local/bin/railway-entrypoint"]
