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

  # Install JS dependencies
  if [[ -f "$dir/package.json" ]]; then
    (cd "$dir" && npm install --force)
  fi
  if [[ -f "$dir/react/package.json" ]]; then
    (cd "$dir/react" && npm install --force)
  fi

  # Install Golang dependencies
  if [[ -f "$dir/go.mod" ]]; then
    (cd "$dir" && go mod download)
  fi

  # Install Python dependencies
  if [[ -f "$dir/requirements.txt" ]]; then
    python3 -m venv "$dir/.venv"
    "$dir/.venv/bin/python" -m pip install --upgrade pip
    "$dir/.venv/bin/pip" install -r "$dir/requirements.txt"
  fi
}

if [[ ! -f "$PROJECT_DIR/.env" ]]; then
  if [[ ! -f "$PROJECT_DIR/.env.example" ]]; then
    printf 'Missing environment template: %s/.env.example\n' "$PROJECT_DIR" >&2
    exit 1
  fi
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
