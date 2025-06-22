#!/bin/bash

# Docker镜像层分析脚本
# 分析 Infisical Standalone 镜像的层结构和大小

set -e

IMAGE_NAME="docker.hitengr.com/infisical-web-app:latest"

echo "🔍 分析Docker镜像层结构..."
echo "镜像: ${IMAGE_NAME}"
echo "=========================================="

# 检查镜像是否存在
if ! docker images "${IMAGE_NAME}" --format "{{.Repository}}:{{.Tag}}" | grep -q "${IMAGE_NAME}"; then
    echo "❌ 镜像 ${IMAGE_NAME} 不存在，请先构建镜像"
    exit 1
fi

echo ""
echo "📊 镜像基本信息:"
docker images "${IMAGE_NAME}" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"

echo ""
echo "🏗️  镜像层详细信息:"
docker history "${IMAGE_NAME}" --format "table {{.CreatedBy}}\t{{.Size}}" --no-trunc

echo ""
echo "🔍 使用 dive 工具分析镜像层 (如果已安装):"
if command -v dive &> /dev/null; then
    echo "正在启动 dive 分析工具..."
    dive "${IMAGE_NAME}"
else
    echo "❌ dive 工具未安装"
    echo "💡 安装 dive 工具来获得详细的层分析:"
    echo "   macOS: brew install dive"
    echo "   Linux: wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb && sudo apt install ./dive_0.10.0_linux_amd64.deb"
fi

echo ""
echo "📈 镜像层分析摘要:"
docker inspect "${IMAGE_NAME}" --format='{{json .RootFS.Layers}}' | jq -r '.[]' | wc -l | xargs printf "总层数: %s\n"

echo ""
echo "💾 各个层的命令和大小:"
docker history "${IMAGE_NAME}" --format "{{.CreatedBy}} -> {{.Size}}" | head -20 