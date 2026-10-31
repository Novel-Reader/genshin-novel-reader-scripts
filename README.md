# genshin-novel-reader-scripts

统一维护 Genshin Novel Reader 后端开发环境、数据库初始化结构和部署辅助脚本。三个 API 仓库仍独立开发；本项目集中提供共享服务配置与初始化/更新流程。

## 目录结构

```text
genshin-novel-reader-scripts/
  docker-compose.yml       # 唯一的本地 MariaDB/Redis 编排入口
  .env.example             # 共享开发配置模板
  sql/init.sql             # 新数据库完整结构
  scripts/init.sh          # 克隆代码并安装依赖
  scripts/update.sh        # 快进更新各仓库并重新安装依赖
  scripts/configure.py     # 从 .env 生成后端所需配置
  scripts/start-python-api.sh # 启动 Python Flask API
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

脚本会创建 `.env`（若不存在）、克隆缺少的仓库、生成 Node/Go 配置并安装依赖。已有 Git 仓库会保留并复用；同名非 Git 目录会拒绝覆盖。Node 项目使用 `npm ci`，同时安装 `react/` 前端依赖；Go 使用 `go mod download`；Python API 项目有 `requirements.txt` 时安装该清单，有 `pyproject.toml` 时执行可编辑安装。如果 Python API 仓库尚无依赖清单，则跳过。

初始化后检查并修改 `.env`，再启动数据库：

```bash
docker compose up -d
```

Python Flask API 初始化依赖后可通过以下脚本启动：

```bash
bash scripts/start-python-api.sh
```

默认监听 `127.0.0.1:5000`，可通过 `FLASK_HOST` 和 `PYTHON_PORT` 环境变量覆盖。
Node API 会调用 `.env` 中的 `PYTHON_API_URL`（默认 `http://127.0.0.1:5000`）访问 Python API；本地开发时需同时运行 Flask 服务和 Node API。

默认后端从本机连接数据库，因此配置生成的地址是 `127.0.0.1`。如果后端也运行在 Compose 网络容器中，将 `.env` 中的 `BACKEND_MYSQL_HOST`/`BACKEND_REDIS_HOST` 设为对应服务名（`db`/`redis`）后重新生成配置。

## 数据库

MariaDB 数据存放在项目内的 `data/mysql/`，不再绑定任何开发者个人绝对路径。首次创建数据目录时，Compose 会自动执行 `sql/init.sql`，建立当前版本的完整数据库结构；已有数据目录不会重复初始化。

当前项目采用全新初始化方式，不维护历史版本迁移脚本。需要重建数据库时，先备份要保留的数据，再停止服务并清空/替换 `data/mysql/` 后启动 MariaDB。不要在有重要数据的目录上直接执行重置操作。

### 创建管理员用户

用户表的 `role` 字段用于区分权限，管理员角色值为 `admin`。Node API 使用 scrypt 哈希存储密码，因此先进入 `genshin-novel-reader-api-node` 目录，用实际密码生成哈希：

```bash
cd ../genshin-novel-reader-api-node
node -e 'require("./src/utils/password").hashPassword("替换成你的强密码").then(console.log)'
```

复制命令输出的完整 `scrypt$...` 字符串，然后连接 MariaDB 执行以下 SQL，并替换邮箱和哈希值：

```sql
INSERT INTO `novel`.`user` (`name`, `email`, `password`, `role`)
VALUES ('admin', 'admin@example.com', '替换为生成的scrypt哈希', 'admin');
```

不要把明文密码写入数据库。密码哈希命令应从 Node API 仓库根目录运行。

## 更新

```bash
bash scripts/update.sh
```

更新脚本会先更新本项目（若它是 Git 仓库），再对各后端执行 `git pull --ff-only`，发现本地未提交改动时会停止，避免覆盖工作区；成功拉取后重新生成配置并安装依赖。数据库结构仅在 MariaDB 首次初始化空数据目录时创建。

## 配置说明

`.env` 是本地共享配置的唯一输入，不要提交该文件。`scripts/configure.py` 按后端当前配置格式生成 Node 的 `src/config/config-local.json` 和 Go 的 `config/config.json`；Go 仓库会忽略该生成文件。Python API 后端目前没有应用代码/配置格式，待仓库定义后再补充生成规则。

MariaDB/Redis 只由本项目的 Compose 管理。后端仓库中的数据库配置和 SQL 初始化结构不再单独维护。
