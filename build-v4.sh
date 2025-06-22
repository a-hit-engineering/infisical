#!/bin/bash

# Infisical Standalone V4 终极优化版打包脚本
# 使用pnpm包管理器和distroless镜像

set -e

echo "🚀 开始构建 Infisical Standalone V4 终极优化版镜像..."

# 设置镜像名称和标签
IMAGE_NAME="docker.hitengr.com/infisical-web-app"
TAG="v4"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

# 获取当前版本信息
if command -v git &> /dev/null; then
    INFISICAL_VERSION=$(git describe --tags --always --dirty 2>/dev/null || echo "unknown")
else
    INFISICAL_VERSION="unknown"
fi

echo "构建版本: ${INFISICAL_VERSION}"
echo "目标镜像: ${FULL_IMAGE_NAME}"

# 构建参数
BUILD_ARGS=(
    "--build-arg" "INFISICAL_PLATFORM_VERSION=${INFISICAL_VERSION}"
    "--build-arg" "POSTHOG_HOST=https://app.posthog.com"
    "--build-arg" "POSTHOG_API_KEY=posthog-api-key"
    "--build-arg" "INTERCOM_ID=intercom-id"
    "--build-arg" "CAPTCHA_SITE_KEY=captcha-site-key"
)

# 构建V4终极优化版Docker镜像
echo "🔧 正在构建V4终极优化版Docker镜像..."
docker build \
    "${BUILD_ARGS[@]}" \
    -f Dockerfile.standalone-v4 \
    -t "${FULL_IMAGE_NAME}" \
    .

echo "✅ V4终极优化版镜像构建完成: ${FULL_IMAGE_NAME}"

# 比较镜像大小
echo ""
echo "📊 镜像大小对比:"
if docker images "${IMAGE_NAME}:v3" &> /dev/null; then
    echo "V3版镜像 (Alpine):"
    docker images "${IMAGE_NAME}:v3" --format "  {{.Repository}}:{{.Tag}} -> {{.Size}}"
fi
echo "V4版镜像 (pnpm + distroless):"
docker images "${FULL_IMAGE_NAME}" --format "  {{.Repository}}:{{.Tag}} -> {{.Size}}"

echo ""
echo "🔍 V4版本革命性优化:"
echo "  ✅ pnpm包管理器 (更高效的依赖管理)"
echo "  ✅ distroless基础镜像 (极简运行时)"
echo "  ✅ 无shell、无包管理器 (最小攻击面)"
echo "  ✅ 更严格的依赖去重"
echo "  ✅ 直接node启动 (无中间层)"

echo ""
echo "🚀 推送命令:"
echo "docker push ${FULL_IMAGE_NAME}"

echo ""
echo "🏃 运行命令:"
echo "docker run -d -p 8080:8080 --name infisical-v4 ${FULL_IMAGE_NAME}"

echo ""
echo "🔧 调试命令 (distroless需要特殊调试镜像):"
echo "docker run -it --entrypoint='' gcr.io/distroless/nodejs20-debian12:debug sh" 