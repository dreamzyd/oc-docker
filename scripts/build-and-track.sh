#!/bin/bash

# OpenClaw Docker 构建 + 版本追踪一站式脚本
# 用法：./scripts/build-and-track.sh [--auto]
#
# 流程：
# 1. 临时构建镜像（不打标签）
# 2. 获取实际 openclaw 版本
# 3. 给镜像打正确的版本标签
# 4. 更新 docker-compose.yml 和 .openclaw-version
# 5. 不删除旧标签（可能被其他容器使用）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PROJECT_DIR/.openclaw-version"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

AUTO_MODE=false
NO_CACHE=""
if [[ "$*" == *"--auto"* ]]; then AUTO_MODE=true; fi
if [[ "$*" == *"--no-cache"* ]]; then NO_CACHE="--no-cache"; fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  OpenClaw 构建 + 版本追踪${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

cd "$PROJECT_DIR"

# 读取旧版本
OLD_VERSION=""
if [ -f "$VERSION_FILE" ]; then
    OLD_VERSION=$(cat "$VERSION_FILE")
    echo -e "  📋 当前记录版本：${YELLOW}$OLD_VERSION${NC}"
fi

# 1. 构建镜像（用临时标签，不覆盖任何现有标签）
echo -e "${GREEN}[1/5] 构建镜像（临时标签）...${NC}"
TEMP_TAG="openclaw:build-temp-$$"

docker build $NO_CACHE -t "$TEMP_TAG" -f Dockerfile . 2>&1 | tail -5

echo -e "  ✅ 构建完成：$TEMP_TAG"

# 2. 获取实际 openclaw 版本
echo -e "${GREEN}[2/5] 获取 OpenClaw 版本...${NC}"
NEW_VERSION=$(docker run --rm "$TEMP_TAG" openclaw --version 2>/dev/null | head -1 | sed 's/OpenClaw //' | sed 's/ .*//')

if [ -z "$NEW_VERSION" ]; then
    echo -e "${RED}  ❌ 无法获取版本，中止${NC}"
    docker rmi "$TEMP_TAG" 2>/dev/null
    exit 1
fi

echo -e "  ✅ OpenClaw 版本：${GREEN}$NEW_VERSION${NC}"

# 3. 打正确的版本标签
echo -e "${GREEN}[3/5] 打标签 openclaw:$NEW_VERSION ...${NC}"
FINAL_TAG="openclaw:$NEW_VERSION"

# 检查是否已存在同名标签（不同镜像）
EXISTING_ID=$(docker images -q "$FINAL_TAG" 2>/dev/null)
TEMP_ID=$(docker images -q "$TEMP_TAG" 2>/dev/null)

if [ -n "$EXISTING_ID" ] && [ "$EXISTING_ID" != "$TEMP_ID" ]; then
    echo -e "${YELLOW}  ⚠️ 已存在 $FINAL_TAG（不同镜像），将覆盖标签${NC}"
    echo -e "${YELLOW}  旧镜像 ID: $EXISTING_ID（如果有其他容器在用，不受影响）${NC}"
fi

docker tag "$TEMP_TAG" "$FINAL_TAG"
echo -e "  ✅ 标签已打：$FINAL_TAG"

# 清理临时标签
docker rmi "$TEMP_TAG" 2>/dev/null || true

# 4. 更新 docker-compose.yml 和 .openclaw-version
echo -e "${GREEN}[4/5] 更新配置文件...${NC}"

if grep -q "image: openclaw:" "$COMPOSE_FILE"; then
    sed -i "s|image: openclaw:.*|image: openclaw:$NEW_VERSION|" "$COMPOSE_FILE"
    echo -e "  ✅ docker-compose.yml → openclaw:$NEW_VERSION"
fi

echo "$NEW_VERSION" > "$VERSION_FILE"
echo -e "  ✅ .openclaw-version → $NEW_VERSION"

# 5. Git 提交（auto 模式）
echo -e "${GREEN}[5/5] Git 提交...${NC}"
if $AUTO_MODE && command -v git &>/dev/null && [ -d .git ]; then
    git add docker-compose.yml .openclaw-version 2>/dev/null
    if ! git diff --cached --quiet 2>/dev/null; then
        git commit -m "chore: update openclaw to $NEW_VERSION" 2>/dev/null
        git push 2>/dev/null && echo -e "  ✅ 已推送到 GitHub" || echo -e "${YELLOW}  ⚠️ 推送失败，稍后手动推${NC}"
    else
        echo -e "  ✅ 无变更，跳过提交"
    fi
else
    echo -e "  ⏭️ 非 auto 模式，跳过提交"
fi

# 显示最终状态
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ 完成！${NC}"
echo ""
echo "  新版本：openclaw:$NEW_VERSION"
if [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    echo -e "  旧版本：openclaw:$OLD_VERSION ${YELLOW}(标签保留，不删除)${NC}"
fi
echo ""
echo "  💡 启动容器：docker compose up -d"
echo "  💡 验证版本：docker compose exec openclaw openclaw --version"
echo ""
echo -e "  ⚠️ 注意：旧标签不会被删除，防止影响其他容器（如星冉）"
echo -e "${BLUE}========================================${NC}"
