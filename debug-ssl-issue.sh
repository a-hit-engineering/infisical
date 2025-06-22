#!/bin/bash

echo "🔍 开始排查 SSL 证书问题..."

# 1. 检查容器日志
echo "📋 查看详细错误日志:"
docker logs infisical-backend --tail=100

echo ""
echo "🌐 测试外部服务连接:"

# 2. 测试 PostHog 连接
echo "测试 PostHog (遥测服务):"
curl -v -k https://app.posthog.com 2>&1 | grep -E "(certificate|SSL|TLS)" || echo "PostHog 连接正常"

echo ""
# 3. 测试许可证服务器连接  
echo "测试许可证服务器:"
curl -v -k https://portal.infisical.com 2>&1 | grep -E "(certificate|SSL|TLS)" || echo "许可证服务器连接正常"

echo ""
# 4. 检查 Redis 配置
echo "🔑 检查 Redis 配置:"
if docker exec infisical-backend env | grep -i redis; then
    echo "发现 Redis 配置"
    docker exec infisical-backend env | grep -E "REDIS.*TLS|REDIS.*SSL|REDIS_URL"
else
    echo "未发现 Redis TLS 配置"
fi

echo ""
# 5. 检查数据库连接
echo "🗄️ 检查数据库连接:"
if docker exec infisical-backend env | grep -E "DB.*SSL|DB.*TLS"; then
    echo "发现数据库 TLS 配置"
    docker exec infisical-backend env | grep -E "DB.*SSL|DB.*TLS"
else
    echo "未发现数据库 TLS 配置"
fi

echo ""
echo "💡 建议排查步骤:"
echo "1. 如果日志中显示 PostHog 相关错误，请设置 TELEMETRY_ENABLED=false"
echo "2. 如果是许可证服务器错误，请检查网络连接或联系支持"
echo "3. 如果是 Redis 错误，请检查 REDIS_URL 是否以 rediss:// 开头"
echo "4. 如果是数据库错误，请检查数据库 SSL 配置"

echo ""
echo "🔧 重启服务来应用修复:"
echo "docker-compose -f docker-compose.prod.yml restart backend" 