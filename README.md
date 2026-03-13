# OpenClaw Docker 部署

🦞 基于官方 npm 包的 Docker 部署方案，支持单节点和多节点部署

## 🚀 快速开始

### 单节点部署

```bash
# 1. 克隆仓库
git clone https://github.com/yourusername/openclaw-docker.git
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
| `OPENCLAW_DEFAULT_MODEL` | 默认模型 | `bailian/qwen3.5-plus` |
| `OPENCLAW_PORT` | Gateway 端口 | `18789` |
| `TZ` | 时区 | `Asia/Shanghai` |

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
