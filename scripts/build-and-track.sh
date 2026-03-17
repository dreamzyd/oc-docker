#!/bin/bash

# OpenClaw Docker 构建 + 版本追踪一站式脚本
# 用法：./scripts/build-and-track.sh [--auto]
#
# --auto: 自动模式，版本追踪时不询问用户

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  OpenClaw 构建 + 版本追踪${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_DIR"

# 1. 构建镜像
echo -e "${GREEN}[1/2] 构建镜像...${NC}"
docker compose build

echo ""

# 2. 版本追踪
echo -e "${GREEN}[2/2] 版本追踪...${NC}"
if [[ "$1" == "--auto" ]]; then
    "$SCRIPT_DIR/version-tracker.sh" --auto
else
    "$SCRIPT_DIR/version-tracker.sh"
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ 完成！${NC}"
echo ""
echo "💡 启动容器："
echo "   docker compose up -d"
echo ""
echo "📊 查看状态："
echo "   docker compose ps"
echo ""
echo "🔍 验证版本："
echo "   docker compose exec openclaw openclaw --version"
