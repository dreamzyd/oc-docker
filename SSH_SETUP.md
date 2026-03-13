# 📝 GitHub SSH Key 配置指南

## 🔑 你的 SSH Public Key

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINSJFrLVTnADV1EwhxV1n7vSmvkycESiQyiJz3HbJowB dreamzyd@users.noreply.github.com
```

## 📋 添加到 GitHub 的步骤

### 步骤 1：复制公钥

**全选并复制上面的 SSH key**（包括 `ssh-ed25519` 开头到 `github.com` 结尾）

### 步骤 2：访问 GitHub SSH Key 设置

打开：https://github.com/settings/keys

### 步骤 3：添加新 Key

1. 点击 **"New SSH key"** 按钮
2. Title 填写：`v9-server` 或任意名称
3. Key type 选择：**● Authentication Key**
4. 粘贴你的 SSH public key
5. 点击 **"Add SSH key"**

### 步骤 4：确认添加

可能需要输入 GitHub 密码确认。

---

## 🚀 添加完成后推送

```bash
cd /docker/oc-docker

# 测试 SSH 连接
ssh -T git@github.com

# 推送代码
git push -u origin main
```

---

## ✅ 验证

推送成功后访问：
```
https://github.com/dreamzyd/oc-docker
```

---

**亘笛，先把 SSH key 添加到 GitHub，添加好了告诉我，我帮你推送！** 🦞
