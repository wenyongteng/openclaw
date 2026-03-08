#!/bin/sh
# Zeabur / cloud-platform entrypoint for OpenClaw.
#
# Reads PORT from the environment (Zeabur injects this automatically)
# and binds to 0.0.0.0 so the platform reverse-proxy can reach the gateway.
#
# Any extra CLI flags passed to the container are forwarded as-is.

set -e

PORT="${PORT:-8080}"

exec node openclaw.mjs gateway \
  --allow-unconfigured \
  --bind lan \
  --port "$PORT" \
  "$@"
