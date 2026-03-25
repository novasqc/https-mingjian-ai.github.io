#!/bin/bash
# 网站数据分析脚本
# 版本：1.0.0
# 功能：分析网站数据，生成优化建议

set -e

# 配置
SITE_DIR="$HOME/openclaw-site"
ANALYSIS_DIR="$SITE_DIR/analysis"
DATA_DIR="$SITE_DIR/data"
mkdir -p "$ANALYSIS_DIR"

# 分析日期
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)

echo "🔍 开始分析网站数据..."
echo "分析时间：$TIMESTAMP"

# 分析报告文件
ANALYSIS_REPORT="$ANALYSIS_DIR/analysis_report_$DATE.md"

# 1. 检查数据文件
echo "检查数据文件..."
DATA_FILES=(
    "$DATA_DIR/content_$DATE.json"
    "$DATA_DIR/tech_$DATE.json"
    "$DATA_DIR/config_$DATE.json"
    "$DATA_DIR/scripts_$DATE.json"
)

MISSING_FILES=()
for file in "${DATA_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$(basename "$file")")
    fi
done

# 2. 开始生成分析报告
echo "生成分析报告：$ANALYSIS_REPORT"

cat > "$ANALYSIS_REPORT" << EOF
# 🦞 网站进化分析报告
## 分析时间：$TIMESTAMP
## 系统版本：进化系统 v1.0.0

EOF

# 如果有缺失的数据文件
if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    cat >> "$ANALYSIS_REPORT" << EOF
## ⚠️ 数据收集问题

以下数据文件缺失：
$(
for file in "${MISSING_FILES[@]}"; do
    echo "- $file"
done
)

**建议**：运行数据收集脚本：
\`\`\`bash
bash $SITE_DIR/collect_data.sh
\`\`\`

EOF
fi

# 3. 内容分析
echo "分析内容数据..."
if [ -f "$DATA_DIR/content_$DATE.json" ]; then
    CONTENT_DATA=$(cat "$DATA_DIR/content_$DATE.json")
    
    # 提取数据（简化处理）
    ARTICLE_COUNT=$(echo "$CONTENT_DATA" | grep '"article_count":' | sed 's/.*: //; s/,.*//')
    LATEST_TITLE=$(echo "$CONTENT_DATA" | grep '"title":' | head -1 | sed 's/.*": "//; s/".*//')
    LATEST_DATE=$(echo "$CONTENT_DATA" | grep '"date":' | head -1 | sed 's/.*": "//; s/".*//')
    RECENT_COUNT=$(echo "$CONTENT_DATA" | grep '"articles_last_7_days":' | sed 's/.*: //; s/,.*//')
    
    cat >> "$ANALYSIS_REPORT" << EOF
## 📝 内容分析

### 基本统计
- **文章总数**：$ARTICLE_COUNT 篇
- **最新文章**：$LATEST_TITLE ($LATEST_DATE)
- **最近7天更新**：$RECENT_COUNT 天有更新

### 内容健康评估
$(
if [ "$ARTICLE_COUNT" -eq 0 ]; then
    echo "❌ **严重问题**：网站没有任何文章"
    echo "   - 影响：用户没有内容可读，搜索引擎不会收录"
    echo "   - 建议：立即运行 \`generate_post.sh\` 生成文章"
elif [ "$ARTICLE_COUNT" -lt 3 ]; then
    echo "⚠️ **需要改进**：文章数量不足"
    echo "   - 影响：内容单薄，用户留存率低"
    echo "   - 建议：至少生成3篇基础文章"
elif [ "$ARTICLE_COUNT" -lt 10 ]; then
    echo "✅ **基本合格**：有基础内容"
    echo "   - 状态：可以开始运营，但需要持续更新"
    echo "   - 建议：建立每日更新机制"
else
    echo "🎉 **优秀**：内容充足"
    echo "   - 状态：有足够的内容支撑网站运营"
    echo "   - 建议：关注内容质量和多样性"
fi
)

### 更新频率评估
$(
if [ "$RECENT_COUNT" -eq 0 ]; then
    echo "❌ **严重问题**：最近7天没有更新"
    echo "   - 影响：搜索引擎认为网站不活跃"
    echo "   - 建议：立即建立每日自动更新机制"
elif [ "$RECENT_COUNT" -lt 3 ]; then
    echo "⚠️ **需要改进**：更新频率较低"
    echo "   - 影响：用户可能认为网站已废弃"
    echo "   - 建议：增加更新频率，至少每周3次"
elif [ "$RECENT_COUNT" -lt 7 ]; then
    echo "✅ **良好**：更新频率正常"
    echo "   - 状态：保持了一定的活跃度"
    echo "   - 建议：考虑每日更新以获得更好效果"
else
    echo "🎉 **优秀**：每日更新"
    echo "   - 状态：非常活跃，搜索引擎喜欢"
    echo "   - 建议：保持这个节奏"
fi
)

EOF
else
    cat >> "$ANALYSIS_REPORT" << EOF
## 📝 内容分析

❌ **数据缺失**：无法分析内容数据

**建议**：运行数据收集脚本获取内容数据。

EOF
fi

# 4. 技术分析
echo "分析技术数据..."
if [ -f "$DATA_DIR/tech_$DATE.json" ]; then
    TECH_DATA=$(cat "$DATA_DIR/tech_$DATE.json")
    
    BUILD_STATUS=$(echo "$TECH_DATA" | grep '"status":' | sed 's/.*": "//; s/".*//')
    HTML_COUNT=$(echo "$TECH_DATA" | grep '"html":' | sed 's/.*: //; s/,.*//')
    TOTAL_SIZE=$(echo "$TECH_DATA" | grep '"total_size":' | sed 's/.*": "//; s/".*//')
    HAS_SITEMAP=$(echo "$TECH_DATA" | grep '"has_sitemap":' | sed 's/.*: //; s/,.*//')
    HAS_ROBOTS=$(echo "$TECH_DATA" | grep '"has_robots":' | sed 's/.*: //; s/,.*//')
    
    cat >> "$ANALYSIS_REPORT" << EOF
## 🖥️ 技术分析

### 构建状态
- **网站状态**：$BUILD_STATUS
- **HTML文件数**：$HTML_COUNT 个
- **网站大小**：$TOTAL_SIZE

### SEO优化
- **站点地图**：$HAS_SITEMAP
- **机器人协议**：$HAS_ROBOTS

### 技术健康评估
$(
if [ "$BUILD_STATUS" != "success" ]; then
    echo "❌ **严重问题**：网站未构建或构建失败"
    echo "   - 影响：用户无法访问网站"
    echo "   - 建议：立即运行 \`deploy.sh\` 构建网站"
else
    echo "✅ **良好**：网站构建成功"
    
    if [ "$HAS_SITEMAP" = "false" ] || [ "$HAS_ROBOTS" = "false" ]; then
        echo "⚠️ **需要改进**：SEO文件不完整"
        echo "   - 影响：搜索引擎优化效果不佳"
        echo "   - 建议：确保 sitemap.xml 和 robots.txt 存在"
    else
        echo "✅ **优秀**：SEO文件完整"
    fi
    
    if [[ "$TOTAL_SIZE" == *"M"* ]]; then
        SIZE_MB=$(echo "$TOTAL_SIZE" | sed 's/M.*//')
        if [ "$SIZE_MB" -gt 5 ]; then
            echo "⚠️ **注意**：网站体积较大 ($TOTAL_SIZE)"
            echo "   - 影响：加载速度可能较慢"
            echo "   - 建议：优化图片和资源文件"
        fi
    fi
fi
)

EOF
else
    cat >> "$ANALYSIS_REPORT" << EOF
## 🖥️ 技术分析

❌ **数据缺失**：无法分析技术数据

**建议**：运行数据收集脚本获取技术数据。

EOF
fi

# 5. 配置分析
echo "分析配置数据..."
if [ -f "$DATA_DIR/config_$DATE.json" ]; then
    CONFIG_DATA=$(cat "$DATA_DIR/config_$DATE.json")
    
    SITE_TITLE=$(echo "$CONFIG_DATA" | grep '"title":' | sed 's/.*": "//; s/".*//')
    SITE_URL=$(echo "$CONFIG_DATA" | grep '"url":' | sed 's/.*": "//; s/".*//')
    HAS_ABOUT_PAGE=$(echo "$CONFIG_DATA" | grep '"has_about_page":' | sed 's/.*: //; s/,.*//')
    ABOUT_WORDS=$(echo "$CONFIG_DATA" | grep '"about_page_words":' | sed 's/.*: //; s/,.*//')
    
    cat >> "$ANALYSIS_REPORT" << EOF
## ⚙️ 配置分析

### 网站信息
- **网站标题**：$SITE_TITLE
- **网站URL**：$SITE_URL
- **关于页面**：$HAS_ABOUT_PAGE ($([ "$HAS_ABOUT_PAGE" = "true" ] && echo "$ABOUT_WORDS 字" || echo "无"))

### 配置健康评估
$(
if [ "$SITE_URL" = "https://mingjian-ai.github.io/" ]; then
    echo "⚠️ **注意**：使用默认URL"
    echo "   - 影响：需要配置实际的GitHub Pages地址"
    echo "   - 建议：编辑 hugo.toml 中的 baseURL"
fi

if [ "$HAS_ABOUT_PAGE" = "false" ]; then
    echo "❌ **需要改进**：缺少关于页面"
    echo "   - 影响：用户不了解网站背景和作者"
    echo "   - 建议：创建关于页面：\`hugo new content about.md\`"
elif [ "$ABOUT_WORDS" -lt 100 ]; then
    echo "⚠️ **可以改进**：关于页面内容较短"
    echo "   - 建议：丰富关于页面内容，至少300字"
else
    echo "✅ **良好**：关于页面完整"
fi
)

EOF
else
    cat >> "$ANALYSIS_REPORT" << EOF
## ⚙️ 配置分析

❌ **数据缺失**：无法分析配置数据

**建议**：运行数据收集脚本获取配置数据。

EOF
fi

# 6. 自动化分析
echo "分析自动化数据..."
if [ -f "$DATA_DIR/scripts_$DATE.json" ]; then
    SCRIPTS_DATA=$(cat "$DATA_DIR/scripts_$DATE.json")
    
    # 统计脚本状态
    EXECUTABLE_COUNT=$(echo "$SCRIPTS_DATA" | grep -o '"executable"' | wc -l)
    TOTAL_SCRIPTS=$(echo "$SCRIPTS_DATA" | grep -o '"name"' | wc -l)
    HAS_DAILY_PUBLISH=$(echo "$SCRIPTS_DATA" | grep '"has_daily_publish":' | sed 's/.*: //; s/,.*//')
    
    cat >> "$ANALYSIS_REPORT" << EOF
## 🤖 自动化分析

### 脚本状态
- **可执行脚本**：$EXECUTABLE_COUNT/$TOTAL_SCRIPTS 个
- **每日发布功能**：$HAS_DAILY_PUBLISH

### 自动化健康评估
$(
if [ "$EXECUTABLE_COUNT" -lt "$TOTAL_SCRIPTS" ]; then
    echo "⚠️ **需要改进**：部分脚本不可执行"
    echo "   - 影响：自动化功能可能无法正常工作"
    echo "   - 建议：运行 \`chmod +x ~/openclaw-site/*.sh\`"
fi

if [ "$HAS_DAILY_PUBLISH" = "false" ]; then
    echo "❌ **严重问题**：缺少每日发布自动化"
    echo "   - 影响：需要手动发布，容易忘记"
    echo "   - 建议：创建 daily_auto_publish.sh 脚本"
else
    echo "✅ **良好**：有每日发布自动化"
    
    # 检查是否配置了cron任务
    if command -v openclaw >/dev/null 2>&1; then
        CRON_COUNT=$(openclaw cron list 2>/dev/null | grep -c "daily-post" || echo "0")
        if [ "$CRON_COUNT" -eq 0 ]; then
            echo "⚠️ **注意**：未配置定时任务"
            echo "   - 影响：自动化不会自动运行"
            echo "   - 建议：配置OpenClaw cron任务"
        else
            echo "✅ **优秀**：已配置定时任务"
        fi
    fi
fi
)

EOF
else
    cat >> "$ANALYSIS_REPORT" << EOF
## 🤖 自动化分析

❌ **数据缺失**：无法分析自动化数据

**建议**：运行数据收集脚本获取自动化数据。

EOF
fi

# 7. 综合评估和建议
echo "生成综合建议..."

cat >> "$ANALYSIS_REPORT" << EOF
## 📈 综合评估

### 总体健康评分
$(
SCORE=0
TOTAL=12

# 内容评分（0-3分）
if [ "$ARTICLE_COUNT" -ge 10 ]; then
    CONTENT_SCORE=3
elif [ "$ARTICLE_COUNT" -ge 3 ]; then
    CONTENT_SCORE=2
elif [ "$ARTICLE_COUNT" -ge 1 ]; then
    CONTENT_SCORE=1
else
    CONTENT_SCORE=0
fi
SCORE=$((SCORE + CONTENT_SCORE))

# 更新评分（0-3分）
if [ "$RECENT_COUNT" -eq 7 ]; then
    UPDATE_SCORE=3
elif [ "$RECENT_COUNT" -ge 3 ]; then
    UPDATE_SCORE=2
elif [ "$RECENT_COUNT" -ge 1 ]; then
    UPDATE_SCORE=1
else
    UPDATE_SCORE=0
fi
SCORE=$((SCORE + UPDATE_SCORE))

# 技术评分（0-3分）
if [ "$BUILD_STATUS" = "success" ] && [ "$HAS_SITEMAP" = "true" ] && [ "$HAS_ROBOTS" = "true" ]; then
    TECH_SCORE=3
elif [ "$BUILD_STATUS" = "success" ]; then
    TECH_SCORE=2
else
    TECH_SCORE=0
fi
SCORE=$((SCORE + TECH_SCORE))

# 自动化评分（0-3分）
if [ "$HAS_DAILY_PUBLISH" = "true" ] && [ "$EXECUTABLE_COUNT" -eq "$TOTAL_SCRIPTS" ]; then
    AUTO_SCORE=3
elif [ "$HAS_DAILY_PUBLISH" = "true" ]; then
    AUTO_SCORE=2
else
    AUTO_SCORE=0
fi
SCORE=$((SCORE + AUTO_SCORE))

PERCENTAGE=$((SCORE * 100 / TOTAL))

echo "- **总体得分**：$SCORE/$TOTAL ($PERCENTAGE%)"
echo "- **内容质量**：$CONTENT_SCORE/3 分"
echo "- **更新频率**：$UPDATE_SCORE/3 分"
echo "- **技术状态**：$TECH_SCORE/3 分"
echo "- **自动化**：$AUTO_SCORE/3 分"

if [ $PERCENTAGE -ge 80 ]; then
    echo "- **评估结果**：🎉 **优秀** - 网站运行良好"
elif [ $PERCENTAGE -ge 60 ]; then
    echo "- **评估结果**：✅ **良好** - 基本功能正常"
elif [ $PERCENTAGE -ge 40 ]; then
    echo "- **评估结果**：⚠️ **需要改进** - 有明显问题"
else
    echo "- **评估结果**：❌ **严重问题** - 需要立即修复"
fi
)

## 🚀 优化行动计划

### 立即行动（今天）
$(
if [ "$ARTICLE_COUNT" -eq 0 ]; then
    echo "1. **生成第一篇文章**：\`bash $SITE_DIR/generate_post.sh\`"
fi

if [ "$BUILD_STATUS" != "success" ]; then
    echo "2. **构建网站**：\`bash $SITE_DIR/deploy.sh\`"
fi

if [ "$HAS_DAILY_PUBLISH" = "false" ] && [ -f "$SITE_DIR/generate_post.sh" ] && [ -f "$SITE_DIR/deploy.sh" ]; then
    echo "3. **创建每日发布脚本**：创建 daily_auto_publish.sh"
fi
)

### 短期改进（本周内）
$(
if [ "$ARTICLE_COUNT" -lt 3 ]; then
    echo "1. **增加文章数量**：目标达到3篇基础文章"
fi

if [ "$HAS_SITEMAP" = "false" ] || [ "$HAS_ROBOTS" = "false" ]; then
    echo "2. **完善SEO文件**：确保 sitemap.xml 和 robots.txt 存在"
fi

if [ "$SITE_URL" = "https://mingjian-ai.github.io/" ]; then
    echo "3. **配置实际URL**：编辑 hugo.toml 中的 baseURL"
fi
)

### 中期优化（1个月内）
1. **建立每日更新机制**：配置OpenClaw cron定时