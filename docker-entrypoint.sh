#!/bin/sh
# Zeabur / cloud-platform entrypoint for OpenClaw.
#
# Reads PORT from the environment (Zeabur injects this automatically)
# and binds to 0.0.0.0 so the platform reverse-proxy can reach the gateway.
#
# Injects HONGMACC_API_KEY into the config at runtime, then starts the gateway.
#
# Any extra CLI flags passed to the container are forwarded as-is.

set -e

PORT="${PORT:-8080}"

# ---------- Inject openclaw.json with real API key ----------
CONFIG_DIR="${HOME}/.openclaw"
mkdir -p "$CONFIG_DIR"

if [ -f /app/openclaw.json ]; then
  if [ -n "$HONGMACC_API_KEY" ]; then
    sed "s/__HONGMACC_API_KEY__/${HONGMACC_API_KEY}/g" \
      /app/openclaw.json > "$CONFIG_DIR/openclaw.json"
    echo "[entrypoint] openclaw.json written to $CONFIG_DIR with HONGMACC_API_KEY injected."
  else
    cp /app/openclaw.json "$CONFIG_DIR/openclaw.json"
    echo "[entrypoint] WARNING: HONGMACC_API_KEY not set – config copied with placeholder."
  fi

  # Inject gateway token (from Zeabur env var)
  if [ -n "$OPENCLAW_GATEWAY_TOKEN" ]; then
    sed -i "s/__GATEWAY_TOKEN__/${OPENCLAW_GATEWAY_TOKEN}/g" "$CONFIG_DIR/openclaw.json"
    echo "[entrypoint] Gateway token injected from OPENCLAW_GATEWAY_TOKEN."
  else
    echo "[entrypoint] WARNING: OPENCLAW_GATEWAY_TOKEN not set – gateway will auto-generate a token."
  fi
fi
# ---------------------------------------------------------------

exec node openclaw.mjs gateway \
  --allow-unconfigured \
  --bind lan \
  --port "$PORT" \
  "$@"
