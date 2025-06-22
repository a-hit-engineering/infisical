#!/bin/bash

echo "🔧 Redis TLS 配置助手"
echo "=============================="

echo ""
echo "当前的配置方式："
echo "✅ REDIS_TLS_REJECT_UNAUTHORIZED=false (已禁用证书验证)"
echo "✅ REDIS_TLS_ENABLED=true (已启用TLS)"

echo ""
echo "💡 如果仍然有SSL错误，您可能需要："

echo ""
echo "1. 🔐 提供CA证书 (如果您有Redis服务器的CA证书):"
echo "   # 将证书转换为base64"
echo "   cat your-redis-ca.pem | base64 -w 0"
echo "   # 然后在docker-compose.prod.yml中取消注释并设置："
echo "   # - REDIS_TLS_CA_CERT=<上面命令的输出>"

echo ""
echo "2. 🌐 设置SNI服务器名 (如果Redis服务器需要特定hostname):"
echo "   # 在docker-compose.prod.yml中取消注释并设置："
echo "   # - REDIS_TLS_SNI_SERVERNAME=your-redis-hostname.com"

echo ""
echo "3. 📝 检查您的Redis连接字符串格式："
echo "   确保格式类似："
echo "   - rediss://username:password@hostname:port"
echo "   - 或者 redis://hostname:port (如果通过REDIS_TLS_ENABLED启用TLS)"

echo ""
echo "🚀 应用配置并重启服务："
echo "docker-compose -f docker-compose.prod.yml restart backend"

echo ""
echo "📋 查看日志以确认问题解决："
echo "docker logs infisical-backend --tail=50" 