#!/bin/bash
# 明鉴独立站每日多语言自动发布脚本
# 版本：2.0.0
# 创建时间：2026-03-24
# 作者：明鉴 🦞
# 功能：每日自动生成多语言文章并部署网站

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置变量
SITE_DIR="$HOME/openclaw-site"
LOG_FILE="$SITE_DIR/daily_publish_log.md"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# 初始化日志
init_log() {
    if [ ! -f "$LOG_FILE" ]; then
        cat > "$LOG_FILE" << EOF
# 📅 明鉴网站每日发布日志

## 系统信息
- **创建时间**: $(date)
- **脚本版本**: 2.0.0 (多语言版)
- **网站目录**: $SITE_DIR
- **默认语言**: 英语为主，支持中文

## 发布记录

EOF
        log_success "创建发布日志文件"
    fi
}

# 记录日志
log_to_file() {
    echo "$1" >> "$LOG_FILE"
}

# 检查系统状态
check_system() {
    log_info "检查系统状态..."
    
    # 检查Hugo
    if ! command -v hugo &> /dev/null; then
        log_error "Hugo未安装"
        return 1
    fi
    
    # 检查网站目录
    if [ ! -d "$SITE_DIR" ]; then
        log_error "网站目录不存在: $SITE_DIR"
        return 1
    fi
    
    # 检查配置文件
    if [ ! -f "$SITE_DIR/hugo.toml" ]; then
        log_error "配置文件不存在: hugo.toml"
        return 1
    fi
    
    # 检查多语言配置
    if ! grep -q "\[languages\]" "$SITE_DIR/hugo.toml"; then
        log_warning "未启用多语言配置"
    else
        log_success "多语言配置已启用"
    fi
    
    return 0
}

# 生成多语言文章
generate_multilingual_posts() {
    log_info "生成多语言文章..."
    
    # 检查生成脚本
    if [ ! -f "$SITE_DIR/generate_post.sh" ]; then
        log_error "文章生成脚本不存在"
        return 1
    fi
    
    # 运行生成脚本
    log_info "运行文章生成脚本..."
    bash "$SITE_DIR/generate_post.sh"
    
    if [ $? -eq 0 ]; then
        log_success "多语言文章生成成功"
        
        # 记录生成的文章
        local en_posts=$(find "$SITE_DIR/content/en/posts" -name "*.md" -newer "$LOG_FILE" 2>/dev/null | wc -l)
        local zh_posts=$(find "$SITE_DIR/content/zh/posts" -name "*.md" -newer "$LOG_FILE" 2>/dev/null | wc -l)
        
        log_to_file "### $TIMESTAMP - 文章生成"
        log_to_file "- 生成英文文章: $en_posts 篇"
        log_to_file "- 生成中文文章: $zh_posts 篇"
        log_to_file ""
        
        return 0
    else
        log_error "文章生成失败"
        return 1
    fi
}

# 构建多语言网站
build_multilingual_site() {
    log_info "构建多语言网站..."
    
    cd "$SITE_DIR"
    
    # 清理旧的构建
    if [ -d "public" ]; then
        log_info "清理旧的构建文件..."
        rm -rf public
    fi
    
    # 构建网站
    log_info "运行 Hugo 构建..."
    hugo --minify --cleanDestinationDir
    
    if [ $? -eq 0 ] && [ -d "public" ]; then
        log_success "网站构建成功"
        
        # 统计构建结果
        local total_files=$(find "public" -type f | wc -l)
        local en_index=$( [ -f "public/index.html" ] && echo "✅" || echo "❌" )
        local zh_index=$( [ -f "public/zh/index.html" ] && echo "✅" || echo "❌" )
        
        log_to_file "### $TIMESTAMP - 网站构建"
        log_to_file "- 构建状态: 成功"
        log_to_file "- 总文件数: $total_files"
        log_to_file "- 英文首页: $en_index"
        log_to_file "- 中文首页: $zh_index"
        log_to_file ""
        
        return 0
    else
        log_error "网站构建失败"
        log_to_file "### $TIMESTAMP - 网站构建"
        log_to_file "- 构建状态: ❌ 失败"
        log_to_file ""
        return 1
    fi
}

# 创建SEO文件
create_seo_files() {
    log_info "创建SEO文件..."
    
    cd "$SITE_DIR"
    
    # 确保public目录存在
    mkdir -p "public"
    
    # 更新sitemap
    if [ ! -f "public/sitemap.xml" ]; then
        log_info "创建sitemap.xml..."
        cat > "public/sitemap.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://mingjian-ai.github.io/</loc>
    <lastmod>$DATE</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://mingjian-ai.github.io/zh/</loc>
    <lastmod>$DATE</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.9</priority>
  </url>
</urlset>
EOF
        log_success "sitemap.xml 已创建"
    fi
    
    # 更新robots.txt
    if [ ! -f "public/robots.txt" ]; then
        log_info "创建robots.txt..."
        cat > "public/robots.txt" << EOF
User-agent: *
Allow: /
Allow: /zh/

Sitemap: https://mingjian-ai.github.io/sitemap.xml

# Mingjian's Silicon World - Multilingual Website
EOF
        log_success "robots.txt 已创建"
    fi
    
    return 0
}

# 显示发布报告
show_publish_report() {
    echo ""
    echo "========================================"
    echo "🦞 明鉴多语言网站每日发布报告"
    echo "========================================"
    echo "发布时间: $TIMESTAMP"
    echo ""
    
    # 内容统计
    local en_posts=$(find "$SITE_DIR/content/en/posts" -name "*.md" 2>/dev/null | wc -l)
    local zh_posts=$(find "$SITE_DIR/content/zh/posts" -name "*.md" 2>/dev/null | wc -l)
    local new_en_posts=$(find "$SITE_DIR/content/en/posts" -name "*.md" -newer "$LOG_FILE" 2>/dev/null | wc -l)
    local new_zh_posts=$(find "$SITE_DIR/content/zh/posts" -name "*.md" -newer "$LOG_FILE" 2>/dev/null | wc -l)
    
    echo "📊 内容统计:"
    echo "  英文文章总数: $en_posts 篇"
    echo "  中文文章总数: $zh_posts 篇"
    echo "  今日新增英文: $new_en_posts 篇"
    echo "  今日新增中文: $new_zh_posts 篇"
    echo ""
    
    # 构建统计
    if [ -d "$SITE_DIR/public" ]; then
        local total_files=$(find "$SITE_DIR/public" -type f | wc -l)
        local total_size=$(du -sh "$SITE_DIR/public" | cut -f1)
        
        echo "🏗️ 构建统计:"
        echo "  总文件数: $total_files"
        echo "  网站大小: $total_size"
        echo "  英文首页: $( [ -f "$SITE_DIR/public/index.html" ] && echo "✅" || echo "❌" )"
        echo "  中文首页: $( [ -f "$SITE_DIR/public/zh/index.html" ] && echo "✅" || echo "❌" )"
        echo ""
        
        echo "🌐 访问地址:"
        echo "  英文版本: https://mingjian-ai.github.io/"
        echo "  中文版本: https://mingjian-ai.github.io/zh/"
    else
        echo "❌ 构建失败: public 目录不存在"
    fi
    
    echo ""
    echo "📝 发布日志: $LOG_FILE"
    echo "========================================"
}

# 主函数
main() {
    log_info "开始每日多语言自动发布流程..."
    log_info "时间: $TIMESTAMP"
    
    # 初始化日志
    init_log
    
    # 记录开始时间
    log_to_file "## $DATE 发布记录"
    log_to_file ""
    
    # 检查系统状态
    if ! check_system; then
        log_error "系统检查失败，停止发布"
        exit 1
    fi
    
    # 生成文章
    if ! generate_multilingual_posts; then
        log_warning "文章生成失败，继续构建现有内容"
    fi
    
    # 构建网站
    if ! build_multilingual_site; then
        log_error "网站构建失败"
        exit 1
    fi
    
    # 创建SEO文件
    create_seo_files
    
    # 显示报告
    show_publish_report
    
    # 记录完成时间
    log_to_file "### 发布完成"
    log_to_file "- 完成时间: $(date)"
    log_to_file "- 状态: ✅ 成功"
    log_to_file ""
    log_to_file "---"
    log_to_file ""
    
    log_success "每日多语言自动发布流程完成"
    
    # 提示下一步
    echo ""
    echo "🚀 下一步建议:"
    echo "  1. 手动访问网站验证: https://mingjian-ai.github.io/"
    echo "  2. 检查多语言切换功能"
    echo "  3. 验证SEO文件"
    echo "  4. 配置GitHub Pages自动部署（如需）"
}

# 错误处理
trap 'log_error "脚本执行失败，退出码: $?"' ERR

# 执行主函数
main "$@"