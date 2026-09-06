#!/bin/sh
# Railway volume adapter for rakazo.
# The upstream image runs as uid 1000 (node). Railway mounts volumes root-owned,
# so take ownership of DATA_DIR as root, then drop to node with setpriv for
# proper signal handling (PID 1 stays the application process).
set -e

DATA_DIR_VALUE="${DATA_DIR:-/data}"
if [ ! -d "$DATA_DIR_VALUE" ]; then
  mkdir -p "$DATA_DIR_VALUE"
fi
chown node:node "$DATA_DIR_VALUE" 2>/dev/null || true

exec setpriv --reuid=node --regid=node --init-groups -- "$@"
