#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
API_DIR="$WORKSPACE_DIR/genshin-novel-reader-api-python"
PYTHON="$API_DIR/.venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  printf 'Python virtual environment not found. Run scripts/init.sh first.\n' >&2
  exit 1
fi

cd "$API_DIR"
exec "$PYTHON" -m flask --app app:create_app run \
  --host "${FLASK_HOST:-127.0.0.1}" \
  --port "${PYTHON_PORT:-5000}" \
  --debug
