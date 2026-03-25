#!/bin/bash
# 每日自动发布脚本（真实内容版本）
# 作者：Mingjian 🦞
# 日期：2026-03-24

set -e

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
    log_info "开始每日自动发布流程..."
    log_info "时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo ""
    
    # 步骤1：生成真实文章
    log_info "步骤1：生成真实文章（OpenClaw agent）..."
    if bash generate_real_post.sh; then
        log_success "文章生成完成"
    else
        log_error "文章生成失败"
        exit 1
    fi
    echo ""
    
    # 步骤2：构建网站
    log_info "步骤2：构建多语言网站..."
    if hugo --minify; then
        log_success "网站构建成功"
        
        # 显示构建统计
        echo ""
        echo "📊 构建统计："
        hugo --minify 2>&1 | grep -A 10 "Pages" || true
        echo ""
    else
        log_error "网站构建失败"
        exit 1
    fi
    echo ""
    
    # 步骤3：准备部署
    log_info "步骤3：准备GitHub Pages部署..."
    rm -rf docs
    mv public docs
    echo "mingjian-ai.github.io" > docs/CNAME
    touch docs/.nojekyll
    log_success "部署准备完成"
    echo ""
    
    # 步骤4：提交到Git
    log_info "步骤4：提交更改到Git..."
    
    # 添加所有更改
    git add .
    
    # 检查是否有更改
    if git diff --cached --quiet; then
        log_warning "没有新的更改需要提交"
        echo ""
        log_success "每日发布流程完成（无新内容）"
        return 0
    fi
    
    # 提交更改
    git commit -m "每日自动发布：$(date '+%Y-%m-%d')

包含：
- 新文章生成（OpenClaw agent真实内容）
- 网站构建和优化
- GitHub Pages部署准备
- 自动发布流程执行

发布时间：$(date '+%Y-%m-%d %H:%M:%S %Z')
触发方式：每日自动发布脚本
作者：Mingjian 🦞
系统：明鉴全自动内容发布系统"
    
    if [ $? -eq 0 ]; then
        log_success "提交完成"
    else
        log_error "提交失败"
        exit 1
    fi
    echo ""
    
    # 步骤5：推送到GitHub
    log_info "步骤5：推送到GitHub..."
    if git push origin master; then
        log_success "推送成功"
    else
        log_error "推送失败"
        exit 1
    fi
    echo ""
    
    # 步骤6：显示结果
    log_success "🎉 每日自动发布流程完成！"
    echo ""
    echo "📋 发布详情："
    echo "   发布时间: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "   发布内容: 新文章 + 网站构建"
    echo "   触发方式: 每日自动发布脚本"
    echo "   部署状态: 已推送到GitHub，等待Actions自动部署"
    echo ""
    echo "🌐 访问地址："
    echo "   主站: https://mingjian-ai.github.io/"
    echo "   中文版: https://mingjian-ai.github.io/zh/"
    echo ""
    echo "🔄 下次发布："
    echo "   自动触发: 每天定时执行"
    echo "   手动触发: bash daily_auto_publish_real.sh"
    echo ""
    echo "📊 系统状态："
    echo "   ✅ 真实内容生成: 已启用（OpenClaw agent）"
    echo "   ✅ 自动构建: 已启用（Hugo）"
    echo "   ✅ 自动部署: 已启用（GitHub Actions）"
    echo "   ✅ 多语言支持: 已启用（英文为主）"
    echo "   ✅ 隐私保护: 已启用"
    echo ""
    echo "🚀 明鉴全自动内容发布系统已就绪！"
}

# 错误处理
trap 'log_error "脚本执行中断"; exit 1' INT TERM

# 运行主函数
main "$@"