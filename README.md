# genshin-novel-reader-scripts

统一维护 Genshin Novel Reader 后端开发环境、数据库和部署辅助脚本。三个 API 仓库仍独立开发；本项目集中提供共享服务配置、SQL 版本和初始化/更新流程。

## 目录结构

```text
genshin-novel-reader-scripts/
  docker-compose.yml       # 唯一的本地 MariaDB/Redis 编排入口
  .env.example             # 共享开发配置模板
  sql/                     # 数据库初始化及版本升级 SQL
  scripts/init.sh          # 克隆代码并安装依赖
  scripts/update.sh        # 快进更新各仓库并重新安装依赖
  scripts/configure.py     # 从 .env 生成后端所需配置
  scripts/db-upgrade.sh    # 执行数据库版本升级
```

## 初始化

需要 Git、Docker Compose v2、Node.js/npm、Go、Python 3 和 pip。将本项目克隆到工作区目录下，与三个后端仓库并列：

```text
workspace/
  genshin-novel-reader-scripts/
  genshin-novel-reader-api-node/
  genshin-novel-reader-api-go/
  genshin-novel-reader-api-python/
```

运行：

```bash
bash scripts/init.sh
```

脚本会创建 `.env`（若不存在）、克隆缺少的仓库、生成 Node/Go 配置并安装依赖。已有 Git 仓库会保留并复用；同名非 Git 目录会拒绝覆盖。Node 项目使用 `npm ci`，同时安装 `react/` 前端依赖；Go 使用 `go mod download`；Python API 项目有 `requirements.txt` 时安装该清单，有 `pyproject.toml` 时执行可编辑安装。如果 Python API 仓库尚无依赖清单，则跳过。Node 仓库内部的临时 Python 脚本不再安装依赖。

初始化后检查并修改 `.env`，再启动数据库：

```bash
docker compose up -d
```

默认后端从本机连接数据库，因此配置生成的地址是 `127.0.0.1`。如果后端也运行在 Compose 网络容器中，将 `.env` 中的 `BACKEND_MYSQL_HOST`/`BACKEND_REDIS_HOST` 设为对应服务名（`db`/`redis`）后重新生成配置。

## 数据库

MariaDB 数据存放在项目内的 `data/mysql/`，不再绑定任何开发者个人绝对路径。首次创建数据目录时，Compose 会自动执行 `sql/init.sql` 创建数据库；已有数据目录不会重复初始化。

按版本顺序执行升级（SQL 不具备重复执行保护，请只对尚未升级到相应版本的数据库运行）：

```bash
bash scripts/db-upgrade.sh all
# 或指定单个版本
bash scripts/db-upgrade.sh 1.0
```

新增/修改数据库升级语句只提交到本项目的 `sql/`，按版本号创建目录。执行升级前应先备份数据库。

## 更新

```bash
bash scripts/update.sh
```

更新脚本会先更新本项目（若它是 Git 仓库），再对各后端执行 `git pull --ff-only`，发现本地未提交改动时会停止，避免覆盖工作区；成功拉取后重新生成配置并安装依赖。该脚本不升级数据库，SQL 版本需由维护者确认后手动执行。

## 配置说明

`.env` 是本地共享配置的唯一输入，不要提交该文件。`scripts/configure.py` 按后端当前配置格式生成 Node 的 `src/config/config-local.json` 和 Go 的 `config/config.json`。Go 仓库目前没有本地配置覆盖文件，因此生成的 `config/config.json` 会显示为工作区修改；更新脚本会只允许这一项生成配置并在快进拉取时自动暂存/恢复它，其他本地修改仍会阻止更新。Python API 后端目前没有应用代码/配置格式，待仓库定义后再补充生成规则。

MariaDB/Redis 只由本项目的 Compose 管理。后端仓库中遗留的 Compose/SQL 文件仅作为历史内容；新的服务配置和升级语句应以本项目为准。
