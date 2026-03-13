# 上传到 GitHub 指南

## 📝 准备工作

### 1. 创建 GitHub 仓库

```bash
# 在 GitHub 上创建新仓库
# 名称：openclaw-docker
# 描述：OpenClaw Docker Deployment
# 可见性：Public 或 Private
```

### 2. 初始化本地仓库

```bash
cd /docker/openclaw-github

# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit: OpenClaw Docker deployment"

# 添加远程仓库
git remote add origin https://github.com/yourusername/openclaw-docker.git

# 推送
git branch -M main
git push -u origin main
```

## 🔐 使用 SSH（推荐）

```bash
# 生成 SSH key（如果没有）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 添加 SSH key 到 GitHub
cat ~/.ssh/id_ed25519.pub
# 复制输出内容，添加到 GitHub Settings > SSH and GPG keys

# 使用 SSH 远程
git remote set-url origin git@github.com:yourusername/openclaw-docker.git

# 推送
git push -u origin main
```

## 📦 更新仓库

```bash
# 修改文件后
git add .
git commit -m "Update: 描述你的修改"
git push
```

## 🏷️ 发布版本

```bash
# 创建标签
git tag v1.0.0
git push origin v1.0.0

# 或在 GitHub 上创建 Release
# https://github.com/yourusername/openclaw-docker/releases
```

## 📄 完善 README

**上传前检查 README 包含**：

- [ ] 项目名称和描述
- [ ] 快速开始指南
- [ ] 配置说明
- [ ] 使用示例
- [ ] 贡献指南
- [ ] 许可证

## 🔍 检查清单

上传前检查：

- [ ] `.env` 已添加到 `.gitignore`
- [ ] `.openclaw/` 目录已忽略
- [ ] 敏感信息已移除
- [ ] README 完整
- [ ] LICENSE 文件存在
- [ ] 文档齐全

## 📊 GitHub Actions（可选）

创建 `.github/workflows/docker-build.yml`：

```yaml
name: Docker Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: docker build -t openclaw:latest .
    
    - name: Test
      run: docker compose up -d
```

## 🎉 完成！

现在你的仓库已经上传到 GitHub，其他人可以：

```bash
# 克隆
git clone https://github.com/yourusername/openclaw-docker.git

# 部署
cd openclaw-docker
cp .env.example .env
docker compose up -d
```

---

**上传成功！** 🦞
