#!/bin/bash

echo "🚀 开始部署Infisical到生产环境..."

# 检查是否在生产服务器上
if [ "$NODE_ENV" != "production" ]; then
    echo "⚠️  警告：当前环境不是production，请确认是否继续部署？"
    read -p "继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 创建必要的目录
mkdir -p traefik
mkdir -p traefik/certificates

# 创建Traefik网络（如果不存在）
if ! docker network ls | grep -q "traefik"; then
    echo "📡 创建Traefik网络..."
    docker network create traefik
fi

# 设置证书文件权限
touch traefik/certificates/acme.json
chmod 600 traefik/certificates/acme.json

# 验证配置文件
echo "🔍 验证配置文件..."
if [ ! -f ".env" ]; then
    echo "❌ 缺少.env文件"
    exit 1
fi

if [ ! -f "traefik/traefik.yml" ]; then
    echo "❌ 缺少traefik/traefik.yml文件"
    exit 1
fi

# 检查敏感配置
if grep -q "NODE_TLS_REJECT_UNAUTHORIZED=0" .env; then
    echo "⚠️  警告：检测到TLS验证被禁用，这在生产环境中是不安全的！"
    echo "请从.env文件中移除或注释掉 NODE_TLS_REJECT_UNAUTHORIZED=0"
    exit 1
fi

# 启动服务
echo "🐳 启动Docker服务..."

# 如果需要，先启动Traefik
if [ "$1" = "--with-traefik" ]; then
    echo "🔧 启动Traefik..."
    docker-compose -f traefik-compose.yml up -d
    echo "⏳ 等待Traefik启动..."
    sleep 10
fi

# 启动Infisical
echo "🔧 启动Infisical..."
docker-compose -f docker-compose.prod.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 20

# 健康检查
echo "🏥 执行健康检查..."
if curl -f -s https://your-domain.com/api/status > /dev/null; then
    echo "✅ Infisical已成功部署并正在运行！"
    echo "🌐 访问地址: https://your-domain.com"
else
    echo "❌ 健康检查失败，请检查日志："
    docker-compose -f docker-compose.prod.yml logs --tail=50
    exit 1
fi

echo "🎉 部署完成！" 