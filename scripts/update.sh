#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$PROJECT_DIR/.." && pwd)"

check_repo() {
  local name="$1"
  local dir
  if [[ "$name" == "genshin-novel-reader-scripts" ]]; then
    dir="$PROJECT_DIR"
  else
    dir="$WORKSPACE_DIR/$name"
  fi
  if [[ ! -d "$dir/.git" ]]; then
    if [[ "$name" == "genshin-novel-reader-scripts" ]]; then
      return 1
    fi
    printf 'Repository is missing; run scripts/init.sh first: %s\n' "$dir" >&2
    return 1
  fi
  local status
  status="$(git -C "$dir" status --porcelain --untracked-files=all)"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$name" == "genshin-novel-reader-api-go" && ( "$line" == " M config/config.json" || "$line" == " D config/config.json" ) ]]; then
      continue
    fi
    printf 'Skipping %s because it has local changes (%s). Commit or stash them, then rerun.\n' "$name" "$line" >&2
    return 1
  done <<< "$status"
}

update_repo() {
  local dir
  if [[ "$1" == "genshin-novel-reader-scripts" ]]; then
    dir="$PROJECT_DIR"
  else
    dir="$WORKSPACE_DIR/$1"
  fi
  git -C "$dir" pull --ff-only --autostash
}

if [[ -d "$PROJECT_DIR/.git" ]]; then
  check_repo genshin-novel-reader-scripts
fi
check_repo genshin-novel-reader-api-node
check_repo genshin-novel-reader-api-go
check_repo genshin-novel-reader-api-python

if [[ -d "$PROJECT_DIR/.git" ]]; then
  update_repo genshin-novel-reader-scripts
fi
update_repo genshin-novel-reader-api-node
update_repo genshin-novel-reader-api-go
update_repo genshin-novel-reader-api-python

python3 "$SCRIPT_DIR/configure.py"

if [[ -f "$WORKSPACE_DIR/genshin-novel-reader-api-node/package-lock.json" ]]; then
  (cd "$WORKSPACE_DIR/genshin-novel-reader-api-node" && npm ci)
elif [[ -f "$WORKSPACE_DIR/genshin-novel-reader-api-node/package.json" ]]; then
  (cd "$WORKSPACE_DIR/genshin-novel-reader-api-node" && npm install)
fi
if [[ -f "$WORKSPACE_DIR/genshin-novel-reader-api-node/react/package-lock.json" ]]; then
  (cd "$WORKSPACE_DIR/genshin-novel-reader-api-node/react" && npm ci)
elif [[ -f "$WORKSPACE_DIR/genshin-novel-reader-api-node/react/package.json" ]]; then
  (cd "$WORKSPACE_DIR/genshin-novel-reader-api-node/react" && npm install)
fi
if [[ -f "$WORKSPACE_DIR/genshin-novel-reader-api-go/go.mod" ]]; then
  (cd "$WORKSPACE_DIR/genshin-novel-reader-api-go" && go mod download)
fi

python_dir="$WORKSPACE_DIR/genshin-novel-reader-api-python"
if [[ -f "$python_dir/requirements.txt" ]]; then
  python3 -m venv "$python_dir/.venv"
  "$python_dir/.venv/bin/python" -m pip install --upgrade pip
  "$python_dir/.venv/bin/pip" install -r "$python_dir/requirements.txt"
elif [[ -f "$python_dir/pyproject.toml" ]]; then
  python3 -m venv "$python_dir/.venv"
  "$python_dir/.venv/bin/python" -m pip install --upgrade pip
  "$python_dir/.venv/bin/pip" install -e "$python_dir"
else
  printf 'No Python dependency manifest found; skipping Python dependencies.\n'
fi
