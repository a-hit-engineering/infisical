#!/bin/bash

# Infisical Standalone 打包脚本
# 构建镜像: docker.hitengr.com/infisical-web-app:latest

set -e

echo "开始构建 Infisical Standalone Docker 镜像..."

# 设置镜像名称和标签
IMAGE_NAME="docker.hitengr.com/infisical-web-app"
TAG="latest"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

# 获取当前版本信息 (如果有git)
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

# 构建Docker镜像
echo "正在构建Docker镜像..."
docker build \
    "${BUILD_ARGS[@]}" \
    -f Dockerfile.standalone-infisical \
    -t "${FULL_IMAGE_NAME}" \
    .

echo "✅ 镜像构建完成: ${FULL_IMAGE_NAME}"

# 显示镜像信息
echo ""
echo "镜像信息:"
docker images "${IMAGE_NAME}" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo "🚀 您可以使用以下命令推送镜像到仓库:"
echo "docker push ${FULL_IMAGE_NAME}"

echo ""
echo "或者使用以下命令运行镜像:"
echo "docker run -d -p 8080:8080 --name infisical-standalone ${FULL_IMAGE_NAME}" 