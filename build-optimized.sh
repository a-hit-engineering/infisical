#!/bin/bash

# Optimized Docker build script for Infisical standalone
set -e

# Variables
IMAGE_NAME="infisical-standalone"
TAG="${1:-latest}"
FULL_IMAGE_NAME="${IMAGE_NAME}:${TAG}"

echo "🚀 开始构建优化的 Infisical standalone 镜像..."

# Build with optimizations
docker build \
  --file Dockerfile.standalone-infisical \
  --tag "${FULL_IMAGE_NAME}" \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --progress=plain \
  .

# Show image size
echo "📊 镜像构建完成，检查镜像大小："
docker images "${FULL_IMAGE_NAME}" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}"

# Optional: analyze layers to identify further optimization opportunities
if command -v dive &> /dev/null; then
    echo "🔍 使用 dive 分析镜像层结构 (按 Ctrl+C 跳过):"
    dive "${FULL_IMAGE_NAME}" || true
fi

echo "✅ 构建完成！镜像名称: ${FULL_IMAGE_NAME}"
echo "💡 运行镜像使用: docker run -p 8080:8080 ${FULL_IMAGE_NAME}" 