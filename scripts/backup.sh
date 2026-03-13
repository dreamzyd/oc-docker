#!/bin/bash
# OpenClaw 备份脚本
# 用法：./scripts/backup.sh [备份目录]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${1:-$PROJECT_DIR/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🦞 OpenClaw 备份脚本"
echo "================================"

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 备份文件名
BACKUP_FILE="$BACKUP_DIR/openclaw-backup-$TIMESTAMP.tar.gz"

echo "📦 开始备份..."
echo "项目目录：$PROJECT_DIR"
echo "备份目标：$BACKUP_FILE"

# 备份重要数据（排除日志和旧备份）
tar -czvf "$BACKUP_FILE" \
    --exclude='.openclaw/logs/*.log' \
    --exclude='backups/*.tar.gz' \
    --exclude='.git' \
    -C "$PROJECT_DIR" \
    .openclaw \
    .env \
    docker-compose.yml \
    Dockerfile \
    scripts

# 显示备份大小
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo ""
echo "✅ 备份完成！"
echo "📊 备份大小：$BACKUP_SIZE"
echo "📁 备份位置：$BACKUP_FILE"

# 清理旧备份（保留最近 10 个）
echo ""
echo "🧹 清理旧备份..."
cd "$BACKUP_DIR"
ls -t openclaw-backup-*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f
echo "✅ 已保留最近 10 个备份"

echo ""
echo "💡 恢复命令："
echo "   ./scripts/restore.sh $BACKUP_FILE"
