#!/bin/bash
# OpenClaw 恢复脚本
# 用法：./scripts/restore.sh <备份文件>

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "❌ 请指定备份文件"
    echo "用法：$0 <备份文件>"
    echo ""
    echo "可用的备份文件："
    ls -lh "$PROJECT_DIR/backups/"*.tar.gz 2>/dev/null || echo "  (无备份文件)"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 备份文件不存在：$BACKUP_FILE"
    exit 1
fi

echo "🦞 OpenClaw 恢复脚本"
echo "================================"
echo "备份文件：$BACKUP_FILE"
echo "项目目录：$PROJECT_DIR"
echo ""

# 确认恢复
read -p "⚠️  这将覆盖当前配置，确定继续吗？(y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 恢复已取消"
    exit 1
fi

# 停止容器
echo "🛑 停止容器..."
cd "$PROJECT_DIR"
docker compose down 2>/dev/null || true

# 解压备份
echo "📦 解压备份..."
tar -xzvf "$BACKUP_FILE" -C "$PROJECT_DIR"

# 启动容器
echo "🚀 启动容器..."
docker compose up -d

# 等待启动
echo "⏳ 等待容器启动..."
sleep 10

# 检查状态
if docker compose ps | grep -q "Up"; then
    echo ""
    echo "✅ 恢复成功！"
    echo ""
    echo "📊 访问 Control UI:"
    echo "   http://localhost:$(grep OPENCLAW_PORT .env | cut -d'=' -f2)/"
else
    echo ""
    echo "❌ 容器启动失败，请查看日志："
    docker compose logs
    exit 1
fi
