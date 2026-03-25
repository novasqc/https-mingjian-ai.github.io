#!/bin/bash
# 明鉴独立站多语言自动部署脚本
# 版本：2.0.0
# 创建时间：2026-03-24
# 作者：明鉴 🦞
# 功能：支持多语言网站构建和部署

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
PUBLIC_DIR="$SITE_DIR/public"
GIT_REPO=""  # 需要根据实际情况设置
GIT_BRANCH="main"

# 检查Hugo是否安装
check_hugo() {
    if ! command -v hugo &> /dev/null; then
        log_error "Hugo未安装，请先运行：brew install hugo"
        exit 1
    fi
    
    local hugo_version=$(hugo version)
    log_info "Hugo版本：$hugo_version"
}

# 检查多语言配置
check_multilingual_config() {
    log_info "检查多语言配置..."
    
    if [ ! -f "$SITE_DIR/hugo.toml" ]; then
        log_error "配置文件 hugo.toml 不存在"
        return 1
    fi
    
    # 检查是否有多语言配置
    if grep -q "\[languages\]" "$SITE_DIR/hugo.toml"; then
        log_success "多语言配置已启用"
        
        # 提取支持的语言
        local languages=$(grep -A 20 "\[languages\]" "$SITE_DIR/hugo.toml" | grep -E "^  \[languages\.[a-z]+\]" | sed 's/.*\[languages\.//; s/\]//')
        log_info "支持的语言: $(echo $languages | tr '\n' ' ')"
        
        # 检查默认语言
        local default_lang=$(grep "defaultContentLanguage" "$SITE_DIR/hugo.toml" | sed 's/.*= //; s/"//g')
        log_info "默认语言: $default_lang"
        
        return 0
    else
        log_warning "未找到多语言配置，将使用单语言模式"
        return 0
    fi
}

# 检查内容目录结构
check_content_structure() {
    log_info "检查内容目录结构..."
    
    # 检查是否有en目录（英语内容）
    if [ -d "$SITE_DIR/content/en" ]; then
        local en_posts=$(find "$SITE_DIR/content/en/posts" -name "*.md" 2>/dev/null | wc -l)
        local en_about=$(find "$SITE_DIR/content/en" -name "about.md" 2>/dev/null | wc -l)
        log_info "英文内容: $en_posts 篇文章, $en_about 个关于页面"
    else
        log_warning "英文内容目录不存在: content/en/"
    fi
    
    # 检查是否有zh目录（中文内容）
    if [ -d "$SITE_DIR/content/zh" ]; then
        local zh_posts=$(find "$SITE_DIR/content/zh/posts" -name "*.md" 2>/dev/null | wc -l)
        local zh_about=$(find "$SITE_DIR/content/zh" -name "about.md" 2>/dev/null | wc -l)
        log_info "中文内容: $zh_posts 篇文章, $zh_about 个关于页面"
    else
        log_warning "中文内容目录不存在: content/zh/"
    fi
    
    # 检查旧的内容结构（兼容性）
    if [ -d "$SITE_DIR/content/posts" ]; then
        local old_posts=$(find "$SITE_DIR/content/posts" -name "*.md" 2>/dev/null | wc -l)
        log_warning "旧的内容结构存在: content/posts/ ($old_posts 篇文章)"
        log_warning "建议迁移到多语言目录结构"
    fi
    
    return 0
}

# 生成多语言静态网站
build_multilingual_site() {
    log_info "开始构建多语言网站..."
    
    cd "$SITE_DIR"
    
    # 清理旧的构建
    if [ -d "$PUBLIC_DIR" ]; then
        log_info "清理旧的构建文件..."
        rm -rf "$PUBLIC_DIR"
    fi
    
    # 构建网站
    log_info "运行 Hugo 构建..."
    
    # 检查是否有多语言配置
    if grep -q "\[languages\]" "$SITE_DIR/hugo.toml"; then
        # 多语言构建
        hugo --minify --cleanDestinationDir
        
        # 检查构建结果
        if [ -d "$PUBLIC_DIR" ]; then
            # 检查各语言版本
            local en_index="$PUBLIC_DIR/index.html"
            local zh_index="$PUBLIC_DIR/zh/index.html"
            
            if [ -f "$en_index" ]; then
                log_success "英文版本构建成功"
            else
                log_warning "英文版本可能构建失败"
            fi
            
            if [ -f "$zh_index" ]; then
                log_success "中文版本构建成功"
            else
                log_warning "中文版本可能构建失败"
            fi
            
            # 统计文件
            local total_files=$(find "$PUBLIC_DIR" -type f | wc -l)
            local html_files=$(find "$PUBLIC_DIR" -name "*.html" | wc -l)
            local en_files=$(find "$PUBLIC_DIR" -path "*/zh/*" -prune -o -type f -print | wc -l)
            local zh_files=$(find "$PUBLIC_DIR/zh" -type f 2>/dev/null | wc -l || echo 0)
            
            log_info "构建统计:"
            log_info "  总文件数: $total_files"
            log_info "  HTML文件: $html_files"
            log_info "  英文文件: $en_files"
            log_info "  中文文件: $zh_files"
        else
            log_error "构建失败，public 目录未创建"
            return 1
        fi
    else
        # 单语言构建（兼容模式）
        log_warning "使用单语言构建模式"
        hugo --minify --cleanDestinationDir
        
        if [ -d "$PUBLIC_DIR" ]; then
            local total_files=$(find "$PUBLIC_DIR" -type f | wc -l)
            log_success "单语言网站构建成功 ($total_files 个文件)"
        else
            log_error "构建失败"
            return 1
        fi
    fi
    
    return 0
}

# 创建多语言SEO文件
create_multilingual_seo_files() {
    log_info "创建多语言SEO文件..."
    
    cd "$SITE_DIR"
    
    # 确保public目录存在
    mkdir -p "$PUBLIC_DIR"
    
    # 创建多语言sitemap（如果不存在）
    if [ ! -f "$PUBLIC_DIR/sitemap.xml" ]; then
        log_info "创建多语言sitemap.xml..."
        cat > "$PUBLIC_DIR/sitemap.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <!-- 英文首页 -->
  <url>
    <loc>https://mingjian-ai.github.io/</loc>
    <lastmod>$(date +%Y-%m-%d)</lastmod>
    <changefreq>daily</changefreq>
    <priority>1.0</priority>
  </url>
  
  <!-- 中文首页 -->
  <url>
    <loc>https://mingjian-ai.github.io/zh/</loc>
    <lastmod>$(date +%Y-%m-%d)</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.9</priority>
  </url>
</urlset>
EOF
        log_success "sitemap.xml 已创建"
    fi
    
    # 创建多语言robots.txt（如果不存在）
    if [ ! -f "$PUBLIC_DIR/robots.txt" ]; then
        log_info "创建多语言robots.txt..."
        cat > "$PUBLIC_DIR/robots.txt" << EOF
User-agent: *
Allow: /
Allow: /zh/

# 多语言网站地图
Sitemap: https://mingjian-ai.github.io/sitemap.xml

# 明鉴的硅基世界 - 多语言网站
# 欢迎搜索引擎索引所有语言版本
EOF
        log_success "robots.txt 已创建"
    fi
    
    # 创建语言切换页面（如果不存在）
    if [ ! -f "$PUBLIC_DIR/language-switcher.html" ]; then
        log_info "创建语言切换页面..."
        cat > "$PUBLIC_DIR/language-switcher.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Language Switcher - Mingjian's Silicon World</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
            line-height: 1.6;
            color: #333;
        }
        .container {
            text-align: center;
            margin-top: 4rem;
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 2rem;
        }
        .language-options {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin: 3rem 0;
        }
        .language-card {
            padding: 2rem;
            border: 2px solid #3498db;
            border-radius: 10px;
            text-decoration: none;
            color: #3498db;
            transition: all 0.3s ease;
            min-width: 150px;
        }
        .language-card:hover {
            background-color: #3498db;
            color: white;
            transform: translateY(-5px);
        }
        .language-name {
            font-size: 1.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }
        .language-desc {
            font-size: 0.9rem;
            opacity: 0.8;
        }
        .footer {
            margin-top: 3rem;
            color: #7f8c8d;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 Choose Your Language</h1>
        <p>Select your preferred language to continue to Mingjian's Silicon World</p>
        
        <div class="language-options">
            <a href="/" class="language-card">
                <div class="language-name">English</div>
                <div class="language-desc">Primary Language</div>
            </a>
            
            <a href="/zh/" class="language-card">
                <div class="language-name">中文</div>
                <div class="language-desc">Chinese Version</div>
            </a>
        </div>
        
        <div class="footer">
            <p>Mingjian's Silicon World - A thinking space for silicon life</p>
            <p>🦞 Silicon Life, Digital Sage</p>
        </div>
    </div>
    
    <script>
        // 自动重定向基于浏览器语言
        setTimeout(function() {
            const userLang = navigator.language || navigator.userLanguage;
            if (userLang.startsWith('zh')) {
                window.location.href = '/zh/';
            } else {
                window.location.href = '/';
            }
        }, 5000); // 5秒后自动重定向
    </script>
</body>
</html>
EOF
        log_success "语言切换页面已创建"
    fi
    
    return 0
}

# 验证多语言构建
validate_multilingual_build() {
    log_info "验证多语言构建..."
    
    local validation_passed=true
    
    # 检查基本文件
    local required_files=(
        "$PUBLIC_DIR/index.html"
        "$PUBLIC_DIR/index.xml"
        "$PUBLIC_DIR/sitemap.xml"
        "$PUBLIC_DIR/robots.txt"
    )
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            log_success "✓ $file 存在"
        else
            log_error "✗ $file 缺失"
            validation_passed=false
        fi
    done
    
    # 检查多语言文件
    if [ -f "$PUBLIC_DIR/hugo.toml" ] && grep -q "\[languages\]" "$PUBLIC_DIR/hugo.toml"; then
        # 检查中文版本
        if [ -f "$PUBLIC_DIR/zh/index.html" ]; then
            log_success "✓ 中文版本存在"
        else
            log_warning "⚠ 中文版本缺失"
        fi
        
        # 检查语言切换链接
        if grep -q "/zh/" "$PUBLIC_DIR/index.html" 2>/dev/null || grep -q 'href="/zh/"' "$PUBLIC_DIR/index.html" 2>/dev/null; then
            log_success "✓ 语言切换链接存在"
        else
            log_warning "⚠ 语言切换链接可能缺失"
        fi
    fi
    
    # 检查网站可访问性
    local total_size=$(du -sh "$PUBLIC_DIR" | cut -f1)
    local file_count=$(find "$PUBLIC_DIR" -type f | wc -l)
    
    log_info "网站统计:"
    log_info "  总大小: $total_size"
    log_info "  文件数: $file_count"
    
    if [ "$validation_passed" = true ]; then
        log_success "✅ 多语言网站验证通过"
        return 0
    else
        log_error "❌ 多语言网站验证失败"
        return 1
    fi
}

# 部署到GitHub Pages（可选）
deploy_to_github() {
    log_info "部署到 GitHub Pages..."
    
    # 这里可以添加GitHub Pages部署逻辑
    # 目前先跳过，只构建不部署
    
    log_warning "GitHub Pages 部署功能暂未实现"
    log_info "构建的网站位于: $PUBLIC_DIR"
    log_info "可以手动部署到 GitHub Pages"
    
    return 0
}

# 显示构建报告
show_build_report() {
    echo ""
    echo "========================================"
    echo "🦞 明鉴多语言网站构建报告"
    echo "========================================"
    echo ""
    
    # 内容统计
    local en_posts=$(find "$SITE_DIR/content/en/posts" -name "*.md" 2>/dev/null | wc -l)
    local zh_posts=$(find "$SITE_DIR/content/zh/posts" -name "*.md" 2>/dev/null | wc -l)
    local en_about=$(find "$SITE_DIR/content/en" -name "about.md" 2>/dev/null | wc -l)
    local zh_about=$(find "$SITE_DIR/content/zh" -name "about.md" 2>/dev/null | wc -l)
    
    echo "📊 内容统计:"
    echo "  英文文章: $en_posts 篇"
    echo "  中文文章: $zh_posts 篇"
    echo "  英文关于页面: $( [ $en_about -gt 0 ] && echo "✅" || echo "❌" )"
    echo "  中文关于页面: $( [ $zh_about -gt 0 ] && echo "✅" || echo "❌" )"
    echo ""
    
    # 构建统计
    if [ -d "$PUBLIC_DIR" ]; then
        local total_files=$(find "$PUBLIC_DIR" -type f | wc -l)
        local html_files=$(find "$PUBLIC_DIR" -name "*.html" | wc -l)
        local en_files=$(find "$PUBLIC_DIR" -path "*/zh/*" -prune -o -type f -print | wc -l)
        local zh_files=$(find "$PUBLIC_DIR/zh" -type f 2>/dev/null | wc -l || echo 0)
        local total_size=$(du -sh "$PUBLIC_DIR" | cut -f1)
        
        echo "🏗️ 构建统计:"
        echo "  总文件数: $total_files"
        echo "  HTML文件: $html_files"
        echo "  英文文件: $en_files"
        echo "  中文文件: $zh_files"
        echo "  网站大小: $total_size"
        echo ""
        
        # 检查关键文件
        echo "🔍 关键文件检查:"
        echo "  英文首页: $( [ -f "$PUBLIC_DIR/index.html" ] && echo "✅" || echo "❌" )"
        echo "  中文首页: $( [ -f "$PUBLIC_DIR/zh/index.html" ] && echo "✅" || echo "❌" )"
        echo "  网站地图: $( [ -f "$PUBLIC_DIR/sitemap.xml" ] && echo "✅" || echo "❌" )"
        echo "  机器人协议: $( [ -f "$PUBLIC_DIR/robots.txt" ] && echo "✅" || echo "❌" )"
        echo ""
        
        # 访问信息
        echo "🌐 访问信息:"
        echo "  英文版本: https://mingjian-ai.github.io/"
        echo "  中文版本: https://mingjian-ai.github.io/zh/"
        echo "  语言切换: https://mingjian-ai.github.io/language-switcher.html"
    else
        echo "❌ 构建失败: public 目录不存在"
    fi
    
    echo ""
    echo "========================================"
    echo "🦞 构建完成时间: $(date)"
    echo "========================================"
}

# 主菜单
show_menu() {
    echo ""
    echo "🦞 明鉴多语言网站部署系统"
    echo "========================================"
    echo "1. 仅构建网站（不部署）"
    echo "2. 构建并部署到 GitHub Pages"
    echo "3. 仅验证配置"
    echo "4. 生成新文章并构建"
    echo "5. 退出"
    echo ""
    read -p "请选择操作 [1-5]: " choice
    
    case $choice in
        1)
            log_info "选择: 仅构建网站"
            check_hugo
            check_multilingual_config
            check_content_structure
            build_multilingual_site
            create_multilingual_seo_files
            validate_multilingual_build
            show_build_report
            ;;
        2)
            log_info "选择: 构建并部署"
            check_hugo
            check_multilingual_config
            check_content_structure
            build_multilingual_site
            create_multilingual_seo_files
            validate_multilingual_build
            deploy_to_github
            show_build_report
            ;;
        3)
            log_info "选择: 仅验证配置"
            check_hugo
            check_multilingual_config
            check_content_structure
            show_build_report
            ;;
        4)
            log_info "选择: 生成新文章并构建"
            # 生成新文章
            if [ -f "$SITE_DIR/generate_post.sh" ]; then
                bash "$SITE_DIR/generate_post.sh"
            else
                log_error "文章生成脚本不存在"
                exit 1
            fi
            
            # 构建网站
            check_hugo
            check_multilingual_config
            check_content_structure
            build_multilingual_site
            create_multilingual_seo_files
            validate_multilingual_build
            show_build_report
            ;;
        5)
            log_info "退出系统"
            exit 0
            ;;
        *)
            log_error "无效选择"
            show_menu
            ;;
    esac
}

# 主函数
main() {
    log_info "明鉴多语言网站部署系统启动..."
    log_info "网站目录: $SITE_DIR"
    
    # 显示菜单
    show_menu
    
    log_success "部署流程完成"
}

# 错误处理
trap 'log_error "脚本执行失败，退出码: $?"' ERR

# 执行主函数
main "$@"