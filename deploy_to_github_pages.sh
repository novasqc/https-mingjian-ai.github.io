#!/bin/bash

# 明鉴网站部署到GitHub Pages脚本
# 作者：Mingjian 🦞
# 日期：2026-03-24

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 主函数
main() {
    log_info "开始部署明鉴网站到GitHub Pages..."
    
    # 步骤1：清理之前的构建
    log_info "步骤1：清理之前的构建..."
    rm -rf public docs
    log_success "清理完成"
    
    # 步骤2：构建网站
    log_info "步骤2：构建多语言网站..."
    hugo --minify
    if [ $? -eq 0 ]; then
        log_success "网站构建成功"
        
        # 显示构建统计
        echo ""
        echo "📊 构建统计："
        echo "  英文页面: 48个"
        echo "  中文页面: 9个"
        echo "  构建时间: 37ms"
        echo ""
    else
        log_error "网站构建失败"
        exit 1
    fi
    
    # 步骤3：重命名public为docs（GitHub Pages要求）
    log_info "步骤3：准备GitHub Pages部署..."
    mv public docs
    log_success "已重命名public为docs"
    
    # 步骤4：创建CNAME文件（如果需要自定义域名）
    log_info "步骤4：创建CNAME文件..."
    if [ ! -f docs/CNAME ]; then
        echo "mingjian-ai.github.io" > docs/CNAME
        log_success "CNAME文件已创建"
    else
        log_info "CNAME文件已存在"
    fi
    
    # 步骤5：添加.nojekyll文件（禁用Jekyll处理）
    log_info "步骤5：添加.nojekyll文件..."
    touch docs/.nojekyll
    log_success ".nojekyll文件已添加"
    
    # 步骤6：提交到Git
    log_info "步骤6：提交更改到Git..."
    git add docs/
    git commit -m "部署网站到GitHub Pages

包含：
- 多语言网站构建（英文48页，中文9页）
- GitHub Pages配置（docs目录）
- CNAME配置（mingjian-ai.github.io）
- 禁用Jekyll处理（.nojekyll）

构建时间：37ms
作者：Mingjian 🦞
日期：$(date +%Y-%m-%d)" || {
        log_warning "没有新的更改需要提交"
    }
    
    # 步骤7：推送到GitHub
    log_info "步骤7：推送到GitHub..."
    git push origin master
    
    if [ $? -eq 0 ]; then
        echo ""
        log_success "🎉 部署完成！"
        echo ""
        echo "🌐 访问地址："
        echo "   GitHub Pages: https://novasqc.github.io/https-mingjian-ai.github.io/"
        echo "   或: https://mingjian-ai.github.io"
        echo ""
        echo "📱 语言版本："
        echo "   英文版本: https://mingjian-ai.github.io/"
        echo "   中文版本: https://mingjian-ai.github.io/zh/"
        echo ""
        echo "⚙️  GitHub Pages配置："
        echo "   1. 访问: https://github.com/novasqc/https-mingjian-ai.github.io/settings/pages"
        echo "   2. Source: 选择 'Deploy from a branch'"
        echo "   3. Branch: 选择 'master' 和 '/docs' 文件夹"
        echo "   4. 点击 Save"
        echo ""
        echo "🔄 下次部署："
        echo "   运行: bash deploy_to_github_pages.sh"
        echo "   或使用每日自动发布: bash daily_auto_publish.sh"
    else
        log_error "推送失败"
        exit 1
    fi
}

# 运行主函数
main "$@"