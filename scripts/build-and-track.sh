#!/bin/bash

# OpenClaw Docker 构建 + 版本追踪一站式脚本
# 用法：./scripts/build-and-track.sh [--auto] [--name 锋哥] [--no-cache]
#
# 流程：
# 1. 临时构建镜像（不打标签）
# 2. 获取实际 openclaw 版本
# 3. 给镜像打正确的版本标签（根据 --name 参数决定前缀）
# 4. 更新本地 docker-compose.yml 和 .openclaw-version（不提交到 git）
# 5. 不删除旧标签（可能被其他容器使用）
#
# 标签规则：
# - --name 锋哥 → fengge:VERSION
# - --name 星冉 → xingran:VERSION
# - 不指定 → openclaw:VERSION

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
INSTANCE_NAME=""
if [[ "$*" == *"--auto"* ]]; then AUTO_MODE=true; fi
if [[ "$*" == *"--no-cache"* ]]; then NO_CACHE="--no-cache"; fi
if [[ "$*" == *"--name"* ]]; then
    INSTANCE_NAME=$(echo "$*" | sed -n 's/.*--name \([^ ]*\).*/\1/p')
fi

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
# 根据实例名称决定标签前缀
if [ -n "$INSTANCE_NAME" ]; then
    # 中文名转拼音/英文：锋哥→fengge, 星冉→xingran, 乘澜→chenglan
    case "$INSTANCE_NAME" in
        锋哥) PREFIX="fengge" ;;
        星冉) PREFIX="xingran" ;;
        乘澜) PREFIX="chenglan" ;;
        小宁) PREFIX="xiaoning" ;;
        钳哥) PREFIX="qian" ;;
        *) PREFIX=$(echo "$INSTANCE_NAME" | tr '[:upper:]' '[:lower:]') ;;
    esac
    echo -e "  📋 实例名称：${YELLOW}$INSTANCE_NAME${NC} → 标签前缀：$PREFIX"
else
    PREFIX="openclaw"
    echo -e "  📋 未指定实例名称，使用默认前缀：${YELLOW}$PREFIX${NC}"
fi

FINAL_TAG="$PREFIX:$NEW_VERSION"

echo -e "${GREEN}[3/5] 打标签 $FINAL_TAG ...${NC}"

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

# 更新 docker-compose.yml（本地修改，不提交到 git）
if grep -q "image: openclaw:" "$COMPOSE_FILE"; then
    sed -i "s|image: openclaw:.*|image: $FINAL_TAG|" "$COMPOSE_FILE"
    echo -e "  ✅ docker-compose.yml → $FINAL_TAG"
else
    echo -e "  ⏭️ docker-compose.yml 中没有 openclaw 镜像配置，跳过更新"
fi

# 更新 .openclaw-version（本地版本记录，不提交到 git）
echo "$NEW_VERSION" > "$VERSION_FILE"
echo -e "  ✅ .openclaw-version → $NEW_VERSION"

# 5. Git 提交（仅手动模式）
echo -e "${GREEN}[5/5] Git 提交...${NC}"
if $AUTO_MODE; then
    echo -e "  ⏭️ auto 模式，跳过 Git 提交"
elif command -v git &>/dev/null && [ -d .git ]; then
    read -p "  是否提交变更？[y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git status
        read -p "  输入要提交的文件（空格分隔，或回车跳过）: " -r FILES
        if [ -n "$FILES" ]; then
            git add $FILES
            git commit -m "chore: updates"
            read -p "  是否推送？[y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git push 2>/dev/null && echo -e "  ✅ 已推送" || echo -e "${YELLOW}  ⚠️ 推送失败，稍后手动推${NC}"
            else
                echo -e "  ⏭️ 跳过推送"
            fi
        else
            echo -e "  ⏭️ 跳过提交"
        fi
    else
        echo -e "  ⏭️ 跳过提交"
    fi
else
    echo -e "  ⏭️ 非 Git 仓库，跳过提交"
fi

# 显示最终状态
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ 完成！${NC}"
echo ""
echo "  新镜像：$FINAL_TAG"
if [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    echo -e "  记录版本：${YELLOW}$OLD_VERSION${NC} → ${GREEN}$NEW_VERSION${NC}"
fi
echo ""
echo "  💡 启动容器：docker compose up -d"
echo "  💡 验证版本：docker compose exec openclaw openclaw --version"
echo ""
echo -e "  ⚠️ 注意：旧标签不会被删除，防止影响其他容器"
echo -e "${BLUE}========================================${NC}"
