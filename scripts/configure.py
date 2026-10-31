#!/usr/bin/env python3
"""Generate backend-specific config files from the shared .env file."""

import json
import os
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent
WORKSPACE_DIR = PROJECT_DIR.parent


def load_env(path):
    values = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        values[key.strip()] = value.strip().strip("\"'")
    return values


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {path}")


def main():
    env_path = PROJECT_DIR / ".env"
    if not env_path.exists():
        raise SystemExit("Missing .env. Run scripts/init.sh first or copy .env.example to .env.")

    values = {**load_env(env_path), **os.environ}
    mysql_host = values.get("BACKEND_MYSQL_HOST", "127.0.0.1")
    mysql_port = int(values.get("MYSQL_PORT", "3306"))
    mysql_user = values.get("MYSQL_USER", "root")
    mysql_password = values.get("MYSQL_ROOT_PASSWORD", "db_dev")
    database = values.get("MYSQL_DATABASE", "novel")
    redis_host = values.get("BACKEND_REDIS_HOST", "127.0.0.1")
    redis_port = int(values.get("REDIS_PORT", "6379"))
    redis_password = values.get("REDIS_PASSWORD", "")

    node_dir = WORKSPACE_DIR / "genshin-novel-reader-api-node"
    if node_dir.is_dir():
        write_json(
            node_dir / "src/config/config-local.json",
            {
                "user": mysql_user,
                "password": mysql_password,
                "database": database,
                "mysqlHost": mysql_host,
                "mysqlPort": str(mysql_port),
                "redisHost": redis_host,
                "redisPort": str(redis_port),
                "pythonApiUrl": values.get("PYTHON_API_URL", "http://127.0.0.1:5000"),
            },
        )

    go_dir = WORKSPACE_DIR / "genshin-novel-reader-api-go"
    if go_dir.is_dir():
        write_json(
            go_dir / "config/config.json",
            {
                "port": values.get("GO_PORT", "8081"),
                "mysql": {
                    "host": mysql_host,
                    "port": mysql_port,
                    "username": mysql_user,
                    "password": mysql_password,
                    "database": database,
                },
                "redis": {
                    "host": redis_host,
                    "port": redis_port,
                    "password": redis_password,
                },
            },
        )

    python_dir = WORKSPACE_DIR / "genshin-novel-reader-api-python"
    if python_dir.is_dir():
        print(f"Python config is not generated: no config format is defined in {python_dir.name} yet.")


if __name__ == "__main__":
    main()
