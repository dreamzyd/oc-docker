# OpenClaw Docker 快速部署指南

## 🚀 5 分钟快速部署

### 步骤 1：克隆仓库

```bash
git clone https://github.com/yourusername/openclaw-docker.git
cd openclaw-docker
```

### 步骤 2：配置

```bash
cp .env.example .env
vi .env
```

**修改配置**：

```bash
# 设置端口（默认 18789）
OPENCLAW_PORT=18789

# 注意：模型配置需要修改 .openclaw/openclaw.json 文件
# 见 README.md 中的"重要：模型配置"部分
```

### 步骤 3：启动

```bash
docker compose up -d
```

### 步骤 4：访问

```bash
# 本地访问
curl http://127.0.0.1:18789/

# 或 SSH 隧道
ssh -N -L 18789:127.0.0.1:18789 user@host
# 然后浏览器访问 http://localhost:18789/
```

## ✅ 完成！

现在你可以：
- 访问 Control UI 配置模型和渠道
- 开始使用 OpenClaw

## 📚 下一步

- [部署指南](docs/deployment.md) - 详细部署说明
- [安全指南](docs/security.md) - 安全配置建议
- [备份恢复](#备份与恢复) - 数据备份方法

## 🆘 需要帮助？

```bash
# 查看日志
docker compose logs -f

# 检查状态
docker compose ps

# 重启容器
docker compose restart
```

---

**快速简单！** 🦞
