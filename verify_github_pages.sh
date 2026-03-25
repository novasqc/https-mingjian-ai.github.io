#!/bin/bash

# GitHub Pages验证脚本
# 用于验证明鉴网站的GitHub Pages配置状态

echo "=== GitHub Pages配置验证脚本 ==="
echo "执行时间: $(date)"
echo ""

# 网站URL
SITE_URL="https://mingjian-ai.github.io"
EN_URL="$SITE_URL/en"
ZH_URL="$SITE_URL/zh"

# 验证函数
verify_url() {
    local url=$1
    local name=$2
    
    echo "验证: $name"
    echo "URL: $url"
    
    # 使用curl检查状态
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    response_time=$(curl -s -o /dev/null -w "%{time_total}" "$url")
    
    if [ "$http_code" = "200" ]; then
        echo "✅ 状态: 正常 (HTTP $http_code)"
        echo "⏱️  响应时间: ${response_time}秒"
        
        # 检查页面标题
        title=$(curl -s "$url" | grep -o '<title>[^<]*</title>' | sed 's/<title>//;s/<\/title>//')
        echo "📄 页面标题: $title"
    elif [ "$http_code" = "404" ]; then
        echo "❌ 状态: 页面未找到 (HTTP 404)"
        echo "💡 建议: 检查GitHub Pages配置"
    elif [ "$http_code" = "000" ]; then
        echo "❌ 状态: 无法连接"
        echo "💡 建议: 检查网络连接或域名配置"
    else
        echo "⚠️  状态: 异常 (HTTP $http_code)"
        echo "💡 建议: 检查部署配置"
    fi
    
    echo ""
}

# 开始验证
echo "1. 验证主网站..."
verify_url "$SITE_URL" "明鉴主网站"

echo "2. 验证英文版本..."
verify_url "$EN_URL" "英文版本"

echo "3. 验证中文版本..."
verify_url "$ZH_URL" "中文版本"

echo "4. 验证关键页面..."
# 检查几个关键页面
verify_url "$SITE_URL/about" "关于页面"
verify_url "$SITE_URL/posts" "文章列表"
verify_url "$SITE_URL/silicon-literature" "硅基文学"

echo "5. 部署状态检查..."
echo "💡 手动检查步骤:"
echo "   1. 访问: https://github.com/novasqc/https-mingjian-ai.github.io/settings/pages"
echo "   2. 检查部署状态是否为绿色对勾"
echo "   3. 查看最近部署时间"
echo "   4. 检查部署日志是否有错误"

echo ""
echo "=== 验证完成 ==="
echo ""
echo "配置建议:"
echo "如果任何页面返回404，请确保GitHub Pages配置为:"
echo "  - Source: Deploy from a branch"
echo "  - Branch: master"
echo "  - Folder: /docs"
echo ""
echo "访问以下链接进行配置:"
echo "https://github.com/novasqc/https-mingjian-ai.github.io/settings/pages"