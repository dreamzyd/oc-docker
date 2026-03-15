# OpenClaw Docker 部署

🦞 基于官方 npm 包的 Docker 部署方案，支持单节点和多节点部署

---

## 📖 项目简介

本项目提供 OpenClaw 的 **Docker 容器化部署方案**，相比传统的 `npm install -g openclaw` 安装方式，有以下特点：

### ✅ Docker 部署的优势

| 优势 | 说明 |
|------|------|
| 🔒 **权限隔离** | OpenClaw 运行在容器内，无法访问宿主机文件系统（除非显式挂载），降低安全风险 |
| 📦 **环境一致** | 无论 Ubuntu/CentOS/Debian，容器内环境完全一致，避免"在我机器上能跑"的问题 |
| 🚀 **快速部署** | 无需安装 Node.js、配置环境变量，`docker compose up -d` 一键启动 |
| 💾 **方便备份** | 所有数据集中在 `.openclaw/` 目录，打包即可完整备份 |
| 🔄 **方便迁移** | 备份文件复制到新服务器，`docker compose up -d` 即可恢复 |
| 🧹 **干净卸载** | `docker compose down` 删除容器，不残留系统文件 |
| 📊 **资源限制** | 可通过 `mem_limit`、`cpus` 限制容器资源，防止占用过多系统资源 |
| 🐛 **故障隔离** | 容器崩溃不影响宿主机，重启容器即可恢复 |
| 🔧 **版本管理** | 可固定 OpenClaw 版本（`OPENCLAW_VERSION=1.2.3`），避免自动升级导致的问题 |

### ❌ Docker 部署的不足

| 不足 | 说明 | 解决方案 |
|------|------|----------|
| 📦 **额外开销** | Docker 守护进程占用约 50-100MB 内存 | 小内存服务器（<1GB）需谨慎 |
| 🌐 **网络配置** | Host 网络模式下容器直接使用宿主机端口，无法在同一服务器运行多个相同端口的实例 | 多实例需使用不同端口 |
| 💾 **磁盘占用** | Docker 镜像 + 容器层占用约 500MB-1GB 磁盘空间 | 定期清理未使用的镜像 |
| 🔧 **调试复杂** | 需要进入容器调试（`docker exec`），不如直接安装方便 | 使用 `docker compose exec openclaw bash` |
| 📁 **文件访问** | 默认无法访问宿主机文件，需要显式挂载卷 | 通过 `volumes` 配置挂载 |
| 🐛 **核心转储** | 容器内程序崩溃可能产生大型 core 文件 | 通过 `ulimits` 禁用或限制 |

---

## 🎯 适用场景

### ✅ 推荐使用 Docker

- 生产环境部署（需要权限隔离和资源限制）
- 多实例部署（不同配置的运行多个 OpenClaw）
- 需要频繁迁移或备份
- 服务器环境复杂（避免依赖冲突）
- 需要固定版本（避免自动升级）

### ❌ 推荐直接安装

- 开发/测试环境（需要频繁调试）
- 小内存服务器（<1GB）
- 需要直接访问宿主机文件
- 学习/体验 OpenClaw（快速尝试）

---

## 🔄 Docker vs 直接安装对比

| 特性 | Docker 部署 | 直接安装（npm） |
|------|------------|----------------|
| 安装复杂度 | ⭐⭐⭐⭐⭐ 简单 | ⭐⭐⭐ 中等（需安装 Node.js） |
| 权限隔离 | ⭐⭐⭐⭐⭐ 容器隔离 | ⭐ 以当前用户权限运行 |
| 环境一致性 | ⭐⭐⭐⭐⭐ 完全一致 | ⭐⭐ 依赖系统环境 |
| 资源限制 | ⭐⭐⭐⭐⭐ 可精确控制 | ⭐⭐ 依赖系统配置 |
| 备份迁移 | ⭐⭐⭐⭐⭐ 打包即可 | ⭐⭐⭐ 需手动配置 |
| 调试便利 | ⭐⭐⭐ 需进入容器 | ⭐⭐⭐⭐⭐ 直接操作 |
| 内存占用 | ⭐⭐⭐ 额外 50-100MB | ⭐⭐⭐⭐⭐ 无额外开销 |
| 磁盘占用 | ⭐⭐⭐ 约 500MB-1GB | ⭐⭐⭐⭐⭐ 约 200MB |

---

## 🚀 快速开始

### 单节点部署

```bash
# 1. 克隆仓库
git clone git@github.com:dreamzyd/oc-docker.git
cd openclaw-docker

# 2. 配置环境变量
cp .env.example .env
vi .env  # 编辑配置

# 3. 启动容器
docker compose up -d

# 4. 查看状态
docker compose ps

# 5. 访问 Control UI
# 本地访问：http://127.0.0.1:18789/
# SSH 隧道：ssh -N -L 18789:127.0.0.1:18789 user@host
```

### 多节点部署

```bash
# 复制配置
cp -r openclaw-docker openclaw-node2
cd openclaw-node2

# 修改端口
vi .env  # OPENCLAW_PORT=8083

# 启动
docker compose up -d
```

## 📁 目录结构

```
openclaw-docker/
├── docker-compose.yml      # Docker Compose 配置
├── Dockerfile              # Docker 镜像定义
├── .env.example            # 环境变量示例
├── .gitignore              # Git 忽略文件
├── README.md               # 本文件
├── examples/               # 示例配置
│   ├── single-node/        # 单节点示例
│   └── multi-node/         # 多节点示例
├── scripts/                # 工具脚本
│   ├── backup.sh           # 备份脚本
│   └── restore.sh          # 恢复脚本
└── docs/                   # 文档
    ├── deployment.md       # 部署指南
    └── security.md         # 安全指南
```

## 🔧 配置说明

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `OPENCLAW_VERSION` | OpenClaw 版本 | `latest` |
| `OPENCLAW_PORT` | Gateway 端口 | `18789` |
| `TZ` | 时区 | `Asia/Shanghai` |

### ⚠️ 重要：模型配置

**`.env` 文件中的 `OPENCLAW_DEFAULT_MODEL` 不生效！**

**需要修改 `.openclaw/openclaw.json` 文件**：

```bash
# 1. 编辑配置文件
vi .openclaw/openclaw.json

# 2. 修改 models 部分
{
  "models": {
    "providers": {
      "bailian": {
        "baseUrl": "https://dashscope.aliyuncs.com/compatible-mode/v1",
        "apiKey": "sk-xxxxxxxxxxxxx"
      }
    },
    "defaults": {
      "primary": "bailian/qwen3.5-plus"
    }
  }
}

# 3. 重启容器
docker compose restart
```

### 端口配置

**单节点**：
```bash
OPENCLAW_PORT=18789
```

**多节点**：
```bash
# 节点 1
OPENCLAW_PORT=8082

# 节点 2
OPENCLAW_PORT=8083

# 节点 3
OPENCLAW_PORT=8084
```

## 🛠️ 常用命令

```bash
# 启动
docker compose up -d

# 停止
docker compose down

# 重启
docker compose restart

# 查看状态
docker compose ps

# 查看日志
docker compose logs -f

# 进入容器
docker compose exec openclaw bash

# 更新镜像
docker compose pull
docker compose up -d --force-recreate

# 备份
./scripts/backup.sh

# 恢复
./scripts/restore.sh backup-20260313.tar.gz
```

## 📦 备份与迁移

### 备份

```bash
# 自动备份（推荐）
./scripts/backup.sh

# 手动备份
tar -czvf openclaw-backup-$(date +%Y%m%d).tar.gz \
  .openclaw/ \
  .env \
  docker-compose.yml
```

### 恢复

```bash
# 解压备份
tar -xzvf openclaw-backup-20260313.tar.gz

# 启动容器
docker compose up -d
```

### 迁移到新服务器

```bash
# 1. 打包
tar -czvf openclaw-migration.tar.gz /docker/openclaw/

# 2. 传输到新服务器
scp openclaw-migration.tar.gz user@new-server:/docker/

# 3. 解压
cd /docker
tar -xzvf openclaw-migration.tar.gz

# 4. 启动
cd openclaw
docker compose up -d
```

## 🔒 安全配置

### SSH 隧道访问（推荐）

```bash
# 本地电脑执行
ssh -N -L 18789:127.0.0.1:18789 user@host

# 浏览器访问
http://localhost:18789/
```

### 防火墙配置

```bash
# 仅允许特定 IP
ufw allow from 192.168.1.0/24 to any port 18789

# 或完全禁止外部访问
ufw deny 18789
```

### Token 管理

```bash
# 查看当前 token
docker exec openclaw-default-openclaw-1 cat /root/.openclaw/openclaw.json | grep token

# 生成新 token
docker exec openclaw-default-openclaw-1 openclaw doctor --generate-gateway-token
```

## 🐛 故障排查

### 容器无法启动

```bash
# 查看详细日志
docker compose logs

# 检查端口占用
ss -tlnp | grep 18789

# 检查权限
ls -la .openclaw/
```

### 配置丢失

检查 `.openclaw` 目录是否正确挂载：

```bash
# 查看挂载
docker inspect openclaw-default-openclaw-1 | grep Mounts -A 20

# 检查文件
ls -la .openclaw/openclaw.json
```

### 端口冲突

```bash
# 查看占用端口的进程
ss -tlnp | grep 18789

# 修改端口
vi .env  # OPENCLAW_PORT=8082
docker compose down && docker compose up -d
```

### 🚨 容器连续崩溃/无限重启

**症状：** 服务器重启后容器反复崩溃，系统卡死

**原因：** 内存限制不足，容器启动时 OOM 崩溃，Docker 自动重启形成循环

**解决方案：**

```bash
# 1. 查看容器状态（确认是否反复重启）
docker compose ps

# 2. 查看重启次数
docker inspect <容器 ID> | grep RestartCount

# 3. 查看日志（找到崩溃原因）
docker compose logs --tail=100

# 4. 如果是因为内存不足，降低内存限制
vi .env
# 修改为更保守的值：
# CONTAINER_MEMORY_LIMIT=600
# NODE_MEMORY_LIMIT=384

# 5. 停止容器（如果正在无限重启）
docker compose down

# 6. 重新启动
docker compose up -d

# 7. 持续监控内存
docker stats
```

**预防机制：**
- `restart: on-failure:3` - 最多自动重启 3 次，避免无限循环
- `ulimits.core: 0` - 禁用 core 文件，防止磁盘占满
- 健康检查 `retries: 5` - 连续 5 次失败才标记 unhealthy，避免误判

**如果连续崩溃 3 次后容器停止：**
```bash
# 查看最后日志
docker compose logs --tail=200

# 通常是内存不足，需要：
# 1. 升级服务器内存
# 2. 或降低 NODE_MEMORY_LIMIT
# 3. 或关闭其他占用内存的服务
```

### 📊 内存不足排查

```bash
# 1. 查看系统内存
free -h

# 2. 查看容器内存使用
docker stats --no-stream

# 3. 查看是否有 OOM 记录
dmesg | grep -i "out of memory"

# 4. 查看其他进程的内存占用
ps aux --sort=-%mem | head -20
```

**推荐配置（1.6GB 服务器）：**
```bash
CONTAINER_MEMORY_LIMIT=600   # 容器硬限制 600MB
NODE_MEMORY_LIMIT=384        # Node.js 堆内存 384MB
```

---

## 📚 官方文档

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Control UI](https://docs.openclaw.ai/web/control-ui)
- [Dashboard](https://docs.openclaw.ai/web/dashboard)
- [Tailscale](https://docs.openclaw.ai/gateway/tailscale)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

**部署愉快！** 🦞

如有问题，请查看 [docs/deployment.md](docs/deployment.md) 或提交 Issue。
