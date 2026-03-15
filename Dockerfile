# OpenClaw 官方 Docker 镜像
# 基于官方 npm 包构建
# 文档：https://docs.openclaw.ai

FROM node:22-alpine

# 维护者信息
LABEL maintainer="OpenClaw Community"
LABEL description="Official OpenClaw Gateway Docker Image"
LABEL version="1.0.0"

# 设置时区（Alpine 使用 apk 安装 tzdata）
ENV TZ=Asia/Shanghai
RUN apk add --no-cache tzdata

# 安装必要的系统工具
RUN apk add --no-cache \
    curl \
    git \
    bash \
    ca-certificates

# 配置 npm 使用国内镜像（加速安装）
RUN npm config set registry https://registry.npmmirror.com

# 安装 OpenClaw（官方 npm 包）
RUN npm install -g openclaw@latest

# 创建 OpenClaw 数据目录
RUN mkdir -p /root/.openclaw

# 暴露端口
EXPOSE 18789

# 工作目录
WORKDIR /root/.openclaw

# 健康检查
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://127.0.0.1:18789/ || exit 1

# 启动命令（前台运行 Gateway，允许未配置启动）
# 生产环境建议先运行 openclaw setup 完成配置
CMD ["openclaw", "gateway", "--allow-unconfigured"]
