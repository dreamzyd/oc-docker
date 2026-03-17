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
    └── restore.sh          # 恢复脚本
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
```

---

## 📦 备份与迁移

### 备份

```bash
tar -czvf openclaw-backup-$(date +%Y%m%d).tar.gz \
  .openclaw/ \
  .env \
  docker-compose.yml
```

### 恢复

```bash
tar -xzvf openclaw-backup-20260313.tar.gz
docker compose up -d
```

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
