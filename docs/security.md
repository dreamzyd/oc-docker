# OpenClaw 安全指南

## ⚠️ 安全警告

**Control UI 是管理员界面**，包含：
- 聊天历史
- 配置管理（包括 API keys）
- 执行审批（可以运行命令）
- 会话管理

**不要直接暴露到公网！**

## 🔒 推荐的安全配置

### 1. 使用 Host 网络模式

当前配置已使用 host 网络模式，仅监听 localhost：

```yaml
network_mode: host
environment:
  - OPENCLAW_GATEWAY_PORT=${OPENCLAW_PORT:-18789}
```

### 2. SSH 隧道访问（推荐）

**从本地电脑**：

```bash
ssh -N -L 18789:127.0.0.1:18789 user@host
```

**然后在浏览器访问**：
```
http://localhost:18789/
```

**优点**：
- ✅ 加密传输
- ✅ 无需开放防火墙
- ✅ 使用 SSH 认证

### 3. 防火墙配置

**UFW**：

```bash
# 仅允许特定 IP
ufw allow from 192.168.1.0/24 to any port 18789

# 或完全禁止外部访问
ufw deny 18789
```

**iptables**：

```bash
# 仅允许特定 IP
iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 18789 -j ACCEPT
iptables -A INPUT -p tcp --dport 18789 -j DROP
```

### 4. Token 管理

**查看当前 token**：

```bash
docker exec openclaw-default-openclaw-1 cat /root/.openclaw/openclaw.json | grep token
```

**生成新 token**：

```bash
docker exec openclaw-default-openclaw-1 openclaw doctor --generate-gateway-token
```

**更新 token**：

```bash
vi .openclaw/openclaw.json
# 修改 gateway.auth.token 字段
```

### 5. 定期备份

```bash
# 每天备份
./scripts/backup.sh

# 备份到远程服务器
scp backups/openclaw-backup-*.tar.gz user@backup-server:/backups/
```

## 🚫 不推荐的做法

### ❌ 直接暴露端口

```yaml
# 不推荐
ports:
  - "0.0.0.0:18789:18789"
```

### ❌ 禁用认证

```bash
# 不推荐
OPENCLAW_GATEWAY_AUTH=false
```

### ❌ 使用弱 token

```bash
# 不推荐
OPENCLAW_GATEWAY_TOKEN=123456
```

## 🔐 最佳实践清单

- [ ] 使用 SSH 隧道访问
- [ ] 配置防火墙限制访问
- [ ] 使用强 token（至少 32 字符）
- [ ] 定期更新 token
- [ ] 定期备份配置
- [ ] 监控异常访问
- [ ] 限制 Docker 容器权限
- [ ] 使用 HTTPS 反向代理（如需公网访问）

## 📚 相关资源

- [OpenClaw 安全文档](https://docs.openclaw.ai/web)
- [Docker 安全最佳实践](https://docs.docker.com/engine/security/)
- [SSH 隧道指南](https://www.ssh.com/academy/ssh/tunneling)

---

**安全第一！** 🦞
