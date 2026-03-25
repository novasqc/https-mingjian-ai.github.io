#!/bin/bash
# 网站数据收集脚本
# 版本：1.0.0
# 功能：收集网站运行数据，支持进化系统

set -e

# 配置
SITE_DIR="$HOME/openclaw-site"
DATA_DIR="$SITE_DIR/data"
mkdir -p "$DATA_DIR"

# 收集日期
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)

echo "🦞 开始收集网站数据..."
echo "时间：$TIMESTAMP"

# 1. 内容数据收集
echo "收集内容数据..."
CONTENT_DATA="$DATA_DIR/content_$DATE.json"

# 文章数量
ARTICLE_COUNT=$(find "$SITE_DIR/content/posts" -name "*.md" 2>/dev/null | wc -l || echo "0")

# 最新文章信息
LATEST_ARTICLE=$(find "$SITE_DIR/content/posts" -name "*.md" 2>/dev/null | sort -r | head -1)
if [ -n "$LATEST_ARTICLE" ] && [ -f "$LATEST_ARTICLE" ]; then
    LATEST_TITLE=$(grep '^title:' "$LATEST_ARTICLE" | head -1 | sed 's/title: //; s/"//g; s/\\//g')
    LATEST_DATE=$(basename "$LATEST_ARTICLE" | cut -d'-' -f1-3)
    LATEST_WORDS=$(wc -w < "$LATEST_ARTICLE" 2>/dev/null || echo "0")
else
    LATEST_TITLE="无"
    LATEST_DATE="无"
    LATEST_WORDS="0"
fi

# 文章日期分布（最近7天）
RECENT_DAYS=7
RECENT_COUNT=0
for i in $(seq 0 $((RECENT_DAYS-1))); do
    CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null || date -d "$i days ago" +%Y-%m-%d)
    if find "$SITE_DIR/content/posts" -name "$CHECK_DATE-*.md" 2>/dev/null | grep -q .; then
        RECENT_COUNT=$((RECENT_COUNT + 1))
    fi
done

# 2. 技术数据收集
echo "收集技术数据..."
TECH_DATA="$DATA_DIR/tech_$DATE.json"

# 网站文件统计
if [ -d "$SITE_DIR/public" ]; then
    HTML_COUNT=$(find "$SITE_DIR/public" -name "*.html" 2>/dev/null | wc -l || echo "0")
    CSS_COUNT=$(find "$SITE_DIR/public" -name "*.css" 2>/dev/null | wc -l || echo "0")
    JS_COUNT=$(find "$SITE_DIR/public" -name "*.js" 2>/dev/null | wc -l || echo "0")
    IMAGE_COUNT=$(find "$SITE_DIR/public" \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" \) 2>/dev/null | wc -l || echo "0")
    TOTAL_SIZE=$(du -sh "$SITE_DIR/public" 2>/dev/null | cut -f1 || echo "0KB")
    BUILD_STATUS="success"
else
    HTML_COUNT=0
    CSS_COUNT=0
    JS_COUNT=0
    IMAGE_COUNT=0
    TOTAL_SIZE="0KB"
    BUILD_STATUS="not_built"
fi

# 3. 配置数据收集
echo "收集配置数据..."
CONFIG_DATA="$DATA_DIR/config_$DATE.json"

# 检查配置文件
if [ -f "$SITE_DIR/hugo.toml" ]; then
    HAS_HUGO_CONFIG=true
    SITE_TITLE=$(grep '^title =' "$SITE_DIR/hugo.toml" | head -1 | sed 's/title = //; s/"//g' || echo "未知")
    SITE_URL=$(grep '^baseURL =' "$SITE_DIR/hugo.toml" | head -1 | sed 's/baseURL = //; s/"//g' || echo "未知")
else
    HAS_HUGO_CONFIG=false
    SITE_TITLE="未知"
    SITE_URL="未知"
fi

# 检查关于页面
if [ -f "$SITE_DIR/content/about.md" ]; then
    HAS_ABOUT_PAGE=true
    ABOUT_WORDS=$(wc -w < "$SITE_DIR/content/about.md" 2>/dev/null || echo "0")
else
    HAS_ABOUT_PAGE=false
    ABOUT_WORDS=0
fi

# 4. 脚本状态收集
echo "收集脚本状态..."
SCRIPT_DATA="$DATA_DIR/scripts_$DATE.json"

SCRIPTS=("generate_post.sh" "deploy.sh" "setup_website.sh" "daily_auto_publish.sh" "collect_data.sh")
SCRIPT_STATUS=()
for script in "${SCRIPTS[@]}"; do
    if [ -f "$SITE_DIR/$script" ]; then
        if [ -x "$SITE_DIR/$script" ]; then
            SCRIPT_STATUS+=("{\"name\":\"$script\",\"status\":\"executable\"}")
        else
            SCRIPT_STATUS+=("{\"name\":\"$script\",\"status\":\"exists_not_executable\"}")
        fi
    else
        SCRIPT_STATUS+=("{\"name\":\"$script\",\"status\":\"missing\"}")
    fi
done

SCRIPT_STATUS_JSON=$(IFS=,; echo "[${SCRIPT_STATUS[*]}]")

# 5. 生成数据文件
echo "生成数据文件..."

# 内容数据
cat > "$CONTENT_DATA" << EOF
{
  "timestamp": "$TIMESTAMP",
  "metrics": {
    "article_count": $ARTICLE_COUNT,
    "latest_article": {
      "title": "$LATEST_TITLE",
      "date": "$LATEST_DATE",
      "word_count": $LATEST_WORDS
    },
    "recent_activity": {
      "articles_last_7_days": $RECENT_COUNT,
      "update_frequency": "$( [ $RECENT_COUNT -ge 3 ] && echo "good" || [ $RECENT_COUNT -ge 1 ] && echo "moderate" || echo "low" )"
    }
  },
  "health": {
    "has_content": $( [ $ARTICLE_COUNT -gt 0 ] && echo "true" || echo "false" ),
    "has_recent_updates": $( [ $RECENT_COUNT -gt 0 ] && echo "true" || echo "false" )
  }
}
EOF

# 技术数据
cat > "$TECH_DATA" << EOF
{
  "timestamp": "$TIMESTAMP",
  "build": {
    "status": "$BUILD_STATUS",
    "files": {
      "html": $HTML_COUNT,
      "css": $CSS_COUNT,
      "javascript": $JS_COUNT,
      "images": $IMAGE_COUNT
    },
    "total_size": "$TOTAL_SIZE"
  },
  "seo": {
    "has_sitemap": $( [ -f "$SITE_DIR/public/sitemap.xml" ] && echo "true" || echo "false" ),
    "has_robots": $( [ -f "$SITE_DIR/public/robots.txt" ] && echo "true" || echo "false" )
  }
}
EOF

# 配置数据
cat > "$CONFIG_DATA" << EOF
{
  "timestamp": "$TIMESTAMP",
  "site": {
    "title": "$SITE_TITLE",
    "url": "$SITE_URL",
    "has_config": $HAS_HUGO_CONFIG,
    "has_about_page": $HAS_ABOUT_PAGE,
    "about_page_words": $ABOUT_WORDS
  },
  "theme": {
    "name": "PaperMod",
    "installed": $( [ -d "$SITE_DIR/themes/PaperMod" ] && echo "true" || echo "false" )
  }
}
EOF

# 脚本数据
cat > "$SCRIPT_DATA" << EOF
{
  "timestamp": "$TIMESTAMP",
  "scripts": $SCRIPT_STATUS_JSON,
  "automation": {
    "has_daily_publish": $( [ -f "$SITE_DIR/daily_auto_publish.sh" ] && echo "true" || echo "false" ),
    "has_data_collection": $( [ -f "$SITE_DIR/collect_data.sh" ] && echo "true" || echo "false" )
  }
}
EOF

# 6. 生成汇总报告
SUMMARY_FILE="$DATA_DIR/summary_$DATE.md"
cat > "$SUMMARY_FILE" << EOF
# 网站数据汇总报告
## 报告时间：$TIMESTAMP

## 📊 内容统计
- 总文章数：$ARTICLE_COUNT 篇
- 最新文章：$LATEST_TITLE ($LATEST_DATE)
- 最近7天更新：$RECENT_COUNT 天有更新
- 更新频率：$( [ $RECENT_COUNT -ge 3 ] && echo "良好" || [ $RECENT_COUNT -ge 1 ] && echo "一般" || echo "需要改进" )

## 🖥️ 技术统计
- 网站状态：$BUILD_STATUS
- HTML文件：$HTML_COUNT 个
- 总大小：$TOTAL_SIZE
- SEO文件：$( [ -f "$SITE_DIR/public/sitemap.xml" ] && echo "✅" || echo "❌" ) sitemap.xml
               $( [ -f "$SITE_DIR/public/robots.txt" ] && echo "✅" || echo "❌" ) robots.txt

## ⚙️ 配置状态
- 网站标题：$SITE_TITLE
- 网站URL：$SITE_URL
- 关于页面：$( [ $HAS_ABOUT_PAGE = true ] && echo "✅ 存在 ($ABOUT_WORDS 字)" || echo "❌ 缺失" )
- 主题状态：$( [ -d "$SITE_DIR/themes/PaperMod" ] && echo "✅ 已安装" || echo "❌ 未安装" )

## 🤖 自动化状态
- 文章生成脚本：$( [ -f "$SITE_DIR/generate_post.sh" ] && echo "✅" || echo "❌" )
- 部署脚本：$( [ -f "$SITE_DIR/deploy.sh" ] && echo "✅" || echo "❌" )
- 每日发布脚本：$( [ -f "$SITE_DIR/daily_auto_publish.sh" ] && echo "✅" || echo "❌" )
- 数据收集脚本：$( [ -f "$SITE_DIR/collect_data.sh" ] && echo "✅" || echo "❌" )

## 📈 健康评分
- 内容健康：$( [ $ARTICLE_COUNT -ge 3 ] && echo "良好" || [ $ARTICLE_COUNT -ge 1 ] && echo "一般" || echo "需要改进" )
- 技术健康：$( [ "$BUILD_STATUS" = "success" ] && echo "良好" || echo "需要改进" )
- 配置健康：$( [ $HAS_HUGO_CONFIG = true ] && [ $HAS_ABOUT_PAGE = true ] && echo "良好" || echo "需要改进" )
- 自动化健康：$( [ -f "$SITE_DIR/daily_auto_publish.sh" ] && echo "良好" || echo "需要改进" )

## 💡 改进建议
$(
if [ $ARTICLE_COUNT -eq 0 ]; then
    echo "1. **立即生成文章**：运行 generate_post.sh"
fi
if [ "$BUILD_STATUS" != "success" ]; then
    echo "2. **构建网站**：运行 deploy.sh"
fi
if [ $HAS_ABOUT_PAGE = false ]; then
    echo "3. **创建关于页面**：hugo new content about.md"
fi
if [ ! -f "$SITE_DIR/daily_auto_publish.sh" ]; then
    echo "4. **设置自动化**：创建每日发布脚本"
fi
)

---
报告生成：明鉴网站进化系统 v1.0.0
数据文件：
  - $CONTENT_DATA
  - $TECH_DATA  
  - $CONFIG_DATA
  - $SCRIPT_DATA
EOF

echo "✅ 数据收集完成！"
echo ""
echo "📁 生成的文件："
echo "  内容数据：$CONTENT_DATA"
echo "  技术数据：$TECH_DATA"
echo "  配置数据：$CONFIG_DATA"
echo "  脚本数据：$SCRIPT_DATA"
echo "  汇总报告：$SUMMARY_FILE"
echo ""
echo "📊 关键指标："
echo "  文章数量：$ARTICLE_COUNT 篇"
echo "  网站状态：$BUILD_STATUS"
echo "  最近更新：$RECENT_COUNT/7 天"
echo "  自动化脚本：$(echo "$SCRIPT_STATUS_JSON" | grep -o '"executable"' | wc -l)/${#SCRIPTS[@]} 个可执行"
echo ""
echo "🔍 查看报告：cat $SUMMARY_FILE"