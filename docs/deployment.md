# OpenClaw 部署指南

## 📋 部署前准备

### 系统要求

- **操作系统**: Linux (Ubuntu 20.04+, CentOS 7+)
- **Docker**: 20.10+
- **Docker Compose**: v2.0+
- **内存**: 至少 2GB
- **磁盘**: 至少 10GB

### 安装 Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh

# CentOS/RHEL
curl -fsSL https://get.docker.com | sh -s -- --mirror Aliyun
```

### 安装 Docker Compose

```bash
# Docker Compose v2
docker compose version  # 检查是否已安装
```

## 🚀 部署步骤

### 1. 克隆仓库

```bash
git clone https://github.com/yourusername/openclaw-docker.git
cd openclaw-docker
```

### 2. 配置环境变量

```bash
cp .env.example .env
vi .env
```

**必要配置**：

```bash
# 选择模型
OPENCLAW_DEFAULT_MODEL=bailian/qwen3.5-plus

# 设置端口（单节点用 18789，多节点用不同端口）
OPENCLAW_PORT=18789
```

### 3. 启动容器

```bash
docker compose up -d
```

### 4. 验证部署

```bash
# 检查容器状态
docker compose ps

# 查看日志
docker compose logs -f

# 测试访问
curl http://127.0.0.1:18789/
```

## 🔧 配置说明

### 模型配置

**阿里云百炼**：

```bash
OPENCLAW_DEFAULT_MODEL=bailian/qwen3.5-plus
```

**Anthropic**：

```bash
OPENCLAW_DEFAULT_MODEL=anthropic/claude-opus-4-6
```

**OpenAI**：

```bash
OPENCLAW_DEFAULT_MODEL=openai/gpt-4o
```

### 渠道配置

**飞书**：

```bash
# .env
FEISHU_APP_ID=cli_xxxxxxxxxxxxx
FEISHU_APP_SECRET=xxxxxxxxxxxxxxxxx
```

**Telegram**：

```bash
# .env
TELEGRAM_BOT_TOKEN=xxxxxxxxx:xxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## 🌐 访问方式

### 本地访问

```bash
curl http://127.0.0.1:18789/
```

### SSH 隧道（推荐）

```bash
# 本地电脑执行
ssh -N -L 18789:127.0.0.1:18789 user@host

# 浏览器访问
http://localhost:18789/
```

### 反向代理（Nginx）

```nginx
server {
    listen 80;
    server_name openclaw.example.com;
    
    location / {
        proxy_pass http://127.0.0.1:18789;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_http_version 1.1;
    }
}
```

## 📦 多节点部署

### 节点 1（主节点）

```bash
cd /docker
git clone https://github.com/yourusername/openclaw-docker.git openclaw-node1
cd openclaw-node1
vi .env  # OPENCLAW_PORT=8082
docker compose up -d
```

### 节点 2

```bash
cd /docker
git clone https://github.com/yourusername/openclaw-docker.git openclaw-node2
cd openclaw-node2
vi .env  # OPENCLAW_PORT=8083
docker compose up -d
```

### 节点 3

```bash
cd /docker
git clone https://github.com/yourusername/openclaw-docker.git openclaw-node3
cd openclaw-node3
vi .env  # OPENCLAW_PORT=8084
docker compose up -d
```

## 🔒 安全建议

### 1. 使用 SSH 隧道

不要直接暴露端口到公网，使用 SSH 隧道访问。

### 2. 配置防火墙

```bash
# 仅允许特定 IP
ufw allow from 192.168.1.0/24 to any port 18789

# 或完全禁止外部访问
ufw deny 18789
```

### 3. 定期备份

```bash
# 添加定时任务
crontab -e

# 每天凌晨 3 点备份
0 3 * * * /docker/openclaw-docker/scripts/backup.sh
```

### 4. 更新 Token

```bash
# 生成新 token
docker compose exec openclaw openclaw doctor --generate-gateway-token

# 更新配置
vi .openclaw/openclaw.json
```

## 🐛 常见问题

### Q: 容器无法启动

**A**: 检查日志：

```bash
docker compose logs
```

### Q: 端口冲突

**A**: 修改 `.env` 中的 `OPENCLAW_PORT`。

### Q: 配置丢失

**A**: 检查 `.openclaw` 目录是否正确挂载：

```bash
docker inspect openclaw-default-openclaw-1 | grep Mounts -A 20
```

### Q: 无法访问 Control UI

**A**: 使用 SSH 隧道：

```bash
ssh -N -L 18789:127.0.0.1:18789 user@host
```

## 📚 相关资源

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [Docker 文档](https://docs.docker.com)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

**部署成功！** 🦞
