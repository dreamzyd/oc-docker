# OpenClaw Docker 部署

🦞 OpenClaw 的 Docker 容器化部署方案

---

## 🚀 快速开始

### 单节点部署

```bash
# 1. 克隆仓库
git clone git@github.com:dreamzyd/oc-docker.git
cd oc-docker

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

# 6. 查看 gateway token（首次登录需要）
docker compose exec openclaw cat /root/.openclaw/openclaw.json | grep token
```

### 多节点部署

```bash
# 复制配置
cp -r oc-docker oc-docker-node2
cd oc-docker-node2

# 修改端口
vi .env  # OPENCLAW_PORT=8083

# 启动
docker compose up -d
```

---

## 📖 项目简介

本项目提供 OpenClaw 的 Docker 部署方案，**主要用于测试和环境隔离**。

### Docker 部署 vs 传统部署（npm install）

| 优势 | 说明 |
|------|------|
| 🔒 环境隔离 | 容器内运行，不影响宿主机 |
| 📦 环境一致 | 避免 Node.js 版本、依赖冲突问题 |
| 💾 方便备份 | 数据集中在 `.openclaw/`，打包即可迁移 |
| 🚀 快速部署 | 无需安装 Node.js，`docker compose up -d` 一键启动 |
| 🧹 干净卸载 | `docker compose down` 删除容器，不残留文件 |

### 适用场景

- ✅ 测试 OpenClaw 功能
- ✅ 多实例部署（不同配置运行多个 OpenClaw）
- ✅ 需要环境隔离的场景

> 💡 **提示**：生产环境建议直接安装（`npm install -g openclaw`），更简单高效。

---

## 📁 目录结构

```
oc-docker/
├── docker-compose.yml      # Docker Compose 配置
├── Dockerfile              # Docker 镜像定义
├── .env.example            # 环境变量示例
├── .gitignore              # Git 忽略文件
├── README.md               # 本文件
├── examples/               # 示例配置
│   ├── single-node/        # 单节点示例
│   └── multi-node/         # 多节点示例
└── scripts/                # 工具脚本
    ├── backup.sh           # 备份脚本
    ├── restore.sh          # 恢复脚本
    └── version-tracker.sh  # 版本追踪脚本
```

---

## 🔧 配置说明

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `OPENCLAW_VERSION` | OpenClaw 版本 | `latest` |
| `OPENCLAW_PORT` | Gateway 端口 | `18789` |
| `TZ` | 时区 | `Asia/Shanghai` |

### 模型配置

**首次启动后，需要在 Control UI 中配置模型：**

1. 访问 Control UI（`http://127.0.0.1:18789/`）
2. 使用 gateway token 登录（见快速开始第 6 步）
3. 在设置页面配置模型提供商和 API Key

**获取百炼 API Key：** 访问 [阿里云百炼控制台](https://bailian.console.aliyun.com/)

---

## 🛠️ 常用命令

```bash
# 启动/停止
docker compose up -d
docker compose down

# 重启/查看状态
docker compose restart
docker compose ps

# 查看日志
docker compose logs -f

# 进入容器
docker compose exec openclaw bash

# 构建镜像（重新安装 OpenClaw）
docker compose build

# 版本追踪（build 后运行，将版本与目录绑定）
./scripts/version-tracker.sh

# 备份/恢复
./scripts/backup.sh
./scripts/restore.sh <备份文件>
```

---

## 📦 备份与迁移

### 备份

```bash
# 使用备份脚本（推荐）
./scripts/backup.sh

# 或手动备份
tar -czvf openclaw-backup-$(date +%Y%m%d).tar.gz \
  .openclaw/ \
  .env \
  docker-compose.yml \
  .openclaw-version 2>/dev/null || true
```

### 恢复

```bash
# 使用恢复脚本（推荐）
./scripts/restore.sh <备份文件>

# 或手动恢复
tar -xzvf openclaw-backup-20260313.tar.gz
docker compose up -d
```

### 版本追踪 ⭐

**问题**：
- 服务器其他进程更新了 OpenClaw 镜像，导致版本不一致？
- 迁移到新服务器后，镜像版本不同导致行为差异？

**解决**：使用版本追踪脚本，将构建时的 OpenClaw 版本与目录绑定。

```bash
# 首次构建后运行（交互式）
./scripts/version-tracker.sh

# 输出示例：
# ✅ OpenClaw 版本：2026.3.13
# ⚠️  版本变化 detected!
# 是否执行版本追踪操作？[y/N] y
# ✅ 版本追踪完成！
```

**脚本会做什么**：
1. 获取容器中 OpenClaw 版本
2. 提示用户是否更新（**用户确认后才执行**）
3. 如果同意：
   - 给镜像打标签：`openclaw:local` → `openclaw:2026.3.13`
   - 更新 `docker-compose.yml` 中的镜像标签
   - 记录版本到 `.openclaw-version`

**用户选择权**：
- **同意（y）**：绑定当前版本，后续备份/恢复都使用此版本
- **拒绝（N）**：保持现状，继续使用 `openclaw:local` 标签

**备份与恢复**：
```bash
# 备份时自动包含 .openclaw-version
./scripts/backup.sh

# 恢复后会提示版本信息
./scripts/restore.sh backup-20260317.tar.gz

# 如需重建相同版本：
docker compose build --build-arg OPENCLAW_VERSION=2026.3.13
```

**工作流程**：
```
构建镜像 → version-tracker.sh → 用户确认 → 打标签 + 更新 compose
                                    ↓
                            备份时包含版本文件
                                    ↓
                            恢复时提示重建相同版本
```

**典型场景**：

| 场景 | 操作 |
|------|------|
| 首次部署 | `docker compose up -d` → `./scripts/version-tracker.sh` → 确认绑定 |
| 镜像被意外更新 | 重新 build → 运行脚本 → 确认是否绑定新版本 |
| 迁移到新服务器 | 恢复备份 → 按提示重建相同版本镜像 |
| 主动升级 | 修改 Dockerfile 版本 → rebuild → 运行脚本 → 确认绑定 |

---

## 🔒 安全建议

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
```

---

## 🐛 故障排查

### 容器无法启动

```bash
# 查看详细日志
docker compose logs

# 检查端口占用
ss -tlnp | grep 18789
```

### 内存不足

```bash
# 查看系统内存
free -h

# 查看容器内存使用
docker stats --no-stream
```

**1.6GB 服务器推荐配置：**
```bash
CONTAINER_MEMORY_LIMIT=600   # 容器硬限制 600MB
NODE_MEMORY_LIMIT=384        # Node.js 堆内存 384MB
```

---

## 📚 官方文档

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Control UI](https://docs.openclaw.ai/web/control-ui)

---

**部署愉快！** 🦞
