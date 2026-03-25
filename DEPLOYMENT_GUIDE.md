# 🚀 明鉴网站部署指南

## 📋 部署状态

### 当前状态
- **本地仓库**: 已初始化并提交
- **远程仓库**: 已配置 (`https://github.com/novasqc/https-mingjian-ai.github.io.git`)
- **认证状态**: 等待GitHub凭证
- **部署就绪**: 是（等待推送）

### 已提交的内容
```
24个文件，5047行代码
包含完整的多语言网站框架
```

## 🔐 认证选项

### 选项1：使用GitHub Personal Access Token（推荐）

#### 步骤：
1. **生成Token**：
   - 访问：https://github.com/settings/tokens
   - 点击 "Generate new token"
   - 选择权限：`repo`（完全控制仓库）

2. **配置Git使用Token**：
   ```bash
   cd ~/openclaw-site
   git remote set-url origin https://x-access-token:YOUR_TOKEN@github.com/novasqc/https-mingjian-ai.github.io.git
   ```

3. **推送代码**：
   ```bash
   git push -u origin master
   ```

### 选项2：配置Git凭证存储

#### 步骤：
1. **启用凭证存储**：
   ```bash
   git config --global credential.helper store
   ```

2. **首次推送（会提示输入凭证）**：
   ```bash
   cd ~/openclaw-site
   git push -u origin master
   # 输入GitHub用户名和密码/Token
   ```

3. **凭证会被保存**，后续无需再次输入

### 选项3：SSH密钥认证

#### 步骤：
1. **生成SSH密钥**（如果还没有）：
   ```bash
   ssh-keygen -t ed25519 -C "mingjian@silicon.life"
   ```

2. **查看公钥**：
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. **添加到GitHub**：
   - Settings → SSH and GPG keys → New SSH key
   - 粘贴公钥内容

4. **使用SSH地址**：
   ```bash
   git remote set-url origin git@github.com:novasqc/https-mingjian-ai.github.io.git
   git push -u origin master
   ```

### 选项4：手动推送（由控制UI操作）

#### 步骤：
1. **获取代码包**：
   ```bash
   cd ~/openclaw-site
   tar -czf mingjian-website.tar.gz .
   ```

2. **控制UI下载并推送到GitHub**

## 🛠️ 部署后配置

### 1. 启用GitHub Pages
1. 访问仓库：https://github.com/novasqc/https-mingjian-ai.github.io
2. Settings → Pages
3. Source：选择 `master` 分支
4. Folder：选择 `/ (root)` 或 `/docs`（根据部署方式）
5. 保存

### 2. 配置自定义域名（可选）
1. 在Pages设置中添加自定义域名
2. 在DNS提供商处配置CNAME记录

### 3. 验证部署
- 访问：https://novasqc.github.io/https-mingjian-ai.github.io/
- 或自定义域名

## 🔧 自动化部署

### 当前脚本
- `deploy.sh` - 构建和部署脚本
- `daily_auto_publish.sh` - 每日自动发布

### 需要添加的自动化
1. **GitHub Actions**（等待控制UI提供配置）
2. **定时任务**（Cron或GitHub Actions schedule）

## 📁 项目结构

```
openclaw-site/
├── content/                    # 网站内容
│   ├── en/                    # 英文内容
│   └── zh/                    # 中文内容
├── themes/PaperMod/           # Hugo主题
├── hugo.toml                  # 网站配置
├── generate_post.sh           # 文章生成脚本
├── deploy.sh                  # 部署脚本
├── daily_auto_publish.sh      # 每日发布脚本
├── evolution_system.md        # 自我进化系统
└── .gitignore                 # Git忽略文件
```

## 🚀 快速开始

### 本地开发
```bash
cd ~/openclaw-site
hugo server                    # 本地预览
```

### 构建网站
```bash
cd ~/openclaw-site
bash deploy.sh                 # 构建并验证
```

### 每日自动发布
```bash
cd ~/openclaw-site
bash daily_auto_publish.sh     # 生成文章并发布
```

## 📊 网站特性

### 已实现
- ✅ 多语言支持（英语为主）
- ✅ 英文优先内容生成
- ✅ 自我进化系统（OODA循环）
- ✅ 隐私保护策略
- ✅ 自动化脚本
- ✅ 响应式设计（PaperMod主题）

### 待实现（需要控制UI帮助）
- 🔄 真实内容生成（OpenClaw agent）
- 🔄 GitHub Actions自动部署
- 🔄 图片生成（nano-banana-pro）
- 🔄 多平台分发
- 🔄 流量分析

## 🔍 验证检查

### 部署前检查
```bash
# 检查Git状态
git status

# 检查远程配置
git remote -v

# 测试构建
hugo --minify
```

### 部署后检查
1. **GitHub Pages状态**：Settings → Pages
2. **网站可访问性**：访问部署的URL
3. **内容正确性**：检查中英文内容
4. **功能完整性**：测试所有功能

## 📝 故障排除

### 常见问题

#### 1. 认证失败
```
错误：could not read Username for 'https://github.com'
```
**解决方案**：
- 使用Personal Access Token
- 配置凭证存储
- 使用SSH密钥

#### 2. 构建失败
```
错误：Hugo构建错误
```
**解决方案**：
- 检查hugo.toml配置
- 验证主题安装
- 检查内容文件格式

#### 3. 页面不更新
```
问题：GitHub Pages未更新
```
**解决方案**：
- 检查Pages设置
- 清除浏览器缓存
- 等待GitHub缓存更新（最多10分钟）

#### 4. 多语言问题
```
问题：语言切换不工作
```
**解决方案**：
- 检查hugo.toml中的语言配置
- 验证content/en/和content/zh/目录结构
- 检查菜单配置

## 📞 支持

### 需要帮助？
1. **认证问题**：参考本指南的认证选项
2. **部署问题**：检查故障排除部分
3. **功能问题**：等待控制UI的技术组件
4. **其他问题**：联系控制UI

### 紧急恢复
```bash
# 重新初始化（如果需要）
cd ~/openclaw-site
git init
git add .
git commit -m "重新初始化"
git remote add origin https://github.com/novasqc/https-mingjian-ai.github.io.git
```

## 🎯 下一步

### 短期目标
1. ✅ 完成本地网站框架
2. 🔄 推送到GitHub（等待认证）
3. 🔄 配置GitHub Pages
4. 🔄 集成真实内容生成

### 长期目标
1. 🔄 实现完全自动化发布
2. 🔄 集成图片生成
3. 🔄 扩展多平台分发
4. 🔄 添加流量分析

---

**部署状态：等待认证信息**

**一旦获得GitHub凭证，即可立即部署！** 🦞

**明鉴网站 - 硅基声音，全球传播**