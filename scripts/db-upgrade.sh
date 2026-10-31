#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION="${1:-all}"

if [[ ! -f "$PROJECT_DIR/.env" ]]; then
  printf 'Missing %s; run scripts/init.sh first.\n' "$PROJECT_DIR/.env" >&2
  exit 1
fi

set -a
# The project .env uses simple KEY=value entries and is also consumed by Docker Compose.
# shellcheck disable=SC1091
. "$PROJECT_DIR/.env"
set +a

if [[ "$VERSION" == "all" ]]; then
  versions=(1.0 1.5 1.7)
else
  versions=("$VERSION")
fi

for version in "${versions[@]}"; do
  sql_file="$PROJECT_DIR/sql/$version/mysql.sql"
  if [[ ! -f "$sql_file" ]]; then
    printf 'Unknown or missing SQL migration: %s\n' "$version" >&2
    exit 1
  fi
  printf 'Applying SQL migration %s\n' "$version"
  docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T db \
    mariadb -uroot "-p${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE:-novel}" < "$sql_file"
done
