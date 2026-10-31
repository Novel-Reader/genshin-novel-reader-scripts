#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

clone_if_missing() {
  local name="$1"
  local url="$2"
  if [[ -d "$WORKSPACE_DIR/$name/.git" ]]; then
    printf 'Using existing repository: %s\n' "$WORKSPACE_DIR/$name"
  elif [[ -e "$WORKSPACE_DIR/$name" ]]; then
    printf 'Refusing to clone over existing path: %s\n' "$WORKSPACE_DIR/$name" >&2
    return 1
  else
    git clone "$url" "$WORKSPACE_DIR/$name"
  fi
}

install_dependencies() {
  local repo="$1"
  local dir="$WORKSPACE_DIR/$repo"

  if [[ -f "$dir/package-lock.json" ]]; then
    (cd "$dir" && npm ci)
  elif [[ -f "$dir/package.json" ]]; then
    (cd "$dir" && npm install)
  fi

  if [[ -f "$dir/react/package-lock.json" ]]; then
    (cd "$dir/react" && npm ci)
  elif [[ -f "$dir/react/package.json" ]]; then
    (cd "$dir/react" && npm install)
  fi

  if [[ -f "$dir/go.mod" ]]; then
    (cd "$dir" && go mod download)
  fi

  if [[ -f "$dir/requirements.txt" ]]; then
    python3 -m venv "$dir/.venv"
    "$dir/.venv/bin/python" -m pip install --upgrade pip
    "$dir/.venv/bin/pip" install -r "$dir/requirements.txt"
  elif [[ -f "$dir/pyproject.toml" ]]; then
    python3 -m venv "$dir/.venv"
    "$dir/.venv/bin/python" -m pip install --upgrade pip
    "$dir/.venv/bin/pip" install -e "$dir"
  else
    printf 'No Python dependency manifest found in %s; skipping Python dependencies.\n' "$repo"
  fi
}

if [[ ! -f "$PROJECT_DIR/.env" ]]; then
  cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
  printf 'Created %s; edit it before using non-development credentials.\n' "$PROJECT_DIR/.env"
fi

clone_if_missing genshin-novel-reader-api-node https://github.com/Novel-Reader/genshin-novel-reader-api-node.git
clone_if_missing genshin-novel-reader-api-go https://github.com/Novel-Reader/genshin-novel-reader-api-go.git
clone_if_missing genshin-novel-reader-api-python https://github.com/Novel-Reader/genshin-novel-reader-api-python.git

python3 "$SCRIPT_DIR/configure.py"

install_dependencies genshin-novel-reader-api-node
install_dependencies genshin-novel-reader-api-go
install_dependencies genshin-novel-reader-api-python

printf '\nInitialization complete. Start shared services with:\n'
printf '  cd "%s" && docker compose up -d\n' "$PROJECT_DIR"
