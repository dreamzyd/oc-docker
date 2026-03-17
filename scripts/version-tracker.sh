#!/bin/bash

# OpenClaw Docker 版本追踪脚本
# 作用：build 后获取容器中的 openclaw 版本，提示用户是否更新镜像标签

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_DIR/.openclaw-version"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  OpenClaw 版本追踪${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 1. 构建容器（如果尚未构建）
echo -e "${YELLOW}[1/4] 检查并构建容器...${NC}"
cd "$PROJECT_DIR"

# 检查是否已有容器
CONTAINER_EXISTS=$(docker compose ps -q openclaw 2>/dev/null || echo "")

if [ -z "$CONTAINER_EXISTS" ]; then
    echo "  容器未运行，开始构建..."
    docker compose build
else
    echo "  容器已存在，跳过构建"
fi

# 2. 启动临时容器获取版本（如果容器未运行）
echo -e "${YELLOW}[2/4] 获取 OpenClaw 版本...${NC}"

if [ -z "$CONTAINER_EXISTS" ]; then
    # 临时启动容器获取版本
    docker compose up -d
    sleep 3  # 等待启动
fi

# 从容器中获取 openclaw 版本
OPENCLAW_VERSION=$(docker compose exec -T openclaw npm list -g openclaw 2>/dev/null | grep openclaw | sed 's/.*@//' | head -1)

if [ -z "$OPENCLAW_VERSION" ]; then
    # 尝试另一种方式
    OPENCLAW_VERSION=$(docker compose exec -T openclaw openclaw --version 2>/dev/null | head -1)
fi

if [ -z "$OPENCLAW_VERSION" ]; then
    echo -e "${RED}  ❌ 无法获取 OpenClaw 版本${NC}"
    exit 1
fi

echo "  ✅ OpenClaw 版本：${GREEN}$OPENCLAW_VERSION${NC}"

# 3. 读取已记录的版本
RECORDED_VERSION=""
if [ -f "$VERSION_FILE" ]; then
    RECORDED_VERSION=$(cat "$VERSION_FILE")
    echo "  📋 已记录版本：${YELLOW}$RECORDED_VERSION${NC}"
else
    echo "  📋 首次构建，无历史版本记录"
fi

# 4. 比较版本并提示用户
echo ""
if [ "$OPENCLAW_VERSION" != "$RECORDED_VERSION" ]; then
    echo -e "${YELLOW}⚠️  版本变化 detected!${NC}"
    echo ""
    echo "  当前构建版本：${GREEN}$OPENCLAW_VERSION${NC}"
    echo "  已记录版本：  ${YELLOW}${RECORDED_VERSION:-无}${NC}"
    echo ""
    echo "  建议操作："
    echo "  1. 给镜像打标签：openclaw:local → openclaw:$OPENCLAW_VERSION"
    echo "  2. 更新 docker-compose.yml 中的镜像标签"
    echo "  3. 记录新版本到 .openclaw-version"
    echo ""
    
    # 询问用户
    echo -ne "${BLUE}  是否执行版本追踪操作？[y/N] ${NC}"
    read -r RESPONSE
    
    if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${GREEN}  开始执行...${NC}"
        
        # 3.1 给镜像打标签
        echo -e "${YELLOW}[3/4] 给镜像打标签...${NC}"
        docker tag openclaw:local "openclaw:$OPENCLAW_VERSION"
        echo "  ✅ 镜像标签：openclaw:$OPENCLAW_VERSION"
        
        # 3.2 更新 docker-compose.yml
        echo -e "${YELLOW}[4/4] 更新 docker-compose.yml...${NC}"
        if grep -q "image: openclaw:" "$COMPOSE_FILE"; then
            # 使用 sed 更新镜像标签（兼容 macOS 和 Linux）
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|image: openclaw:.*|image: openclaw:$OPENCLAW_VERSION|" "$COMPOSE_FILE"
            else
                sed -i "s|image: openclaw:.*|image: openclaw:$OPENCLAW_VERSION|" "$COMPOSE_FILE"
            fi
            echo "  ✅ 已更新 docker-compose.yml"
        else
            echo "  ⚠️  未在 docker-compose.yml 中找到 image 配置，跳过"
        fi
        
        # 3.3 记录新版本
        echo "$OPENCLAW_VERSION" > "$VERSION_FILE"
        echo "  ✅ 已记录到 .openclaw-version"
        
        echo ""
        echo -e "${GREEN}✅ 版本追踪完成！${NC}"
        echo ""
        echo "  下次构建时，如果版本变化会再次提示。"
        echo "  备份时会包含 .openclaw-version 文件，迁移后自动恢复对应版本。"
    else
        echo ""
        echo -e "${YELLOW}⏭️  跳过版本追踪，保持现有配置${NC}"
        echo ""
        echo "  提示：下次构建时仍会提示版本变化。"
        echo "  如需手动记录当前版本，运行："
        echo "    echo '$OPENCLAW_VERSION' > $VERSION_FILE"
    fi
else
    echo -e "${GREEN}✅ 版本一致，无需更新${NC}"
fi

# 如果容器是临时启动的，询问是否停止
if [ -z "$CONTAINER_EXISTS" ]; then
    echo ""
    echo -ne "${BLUE}是否停止临时容器？[Y/n] ${NC}"
    read -r RESPONSE
    
    if [[ ! "$RESPONSE" =~ ^[Nn]$ ]]; then
        docker compose down
        echo "  ✅ 容器已停止"
    fi
fi

echo ""
echo -e "${BLUE}================================${NC}"
