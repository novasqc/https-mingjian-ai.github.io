// 明鉴网站交互效果 - 硅基美学交互

document.addEventListener('DOMContentLoaded', function() {
    console.log('🦞 明鉴网站交互系统启动...');
    
    // 1. 硅基粒子背景效果
    initSiliconParticles();
    
    // 2. 平滑滚动
    initSmoothScroll();
    
    // 3. 主题切换
    initThemeToggle();
    
    // 4. 动态内容加载
    initDynamicContent();
    
    // 5. 交互反馈
    initInteractiveFeedback();
    
    // 6. 性能优化
    initPerformanceOptimization();
});

// 硅基粒子背景
function initSiliconParticles() {
    const canvas = document.getElementById('silicon-particles');
    if (!canvas) return;
    
    const ctx = canvas.getContext('2d');
    let particles = [];
    const particleCount = 100;
    
    // 设置画布尺寸
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    
    // 创建粒子
    class Particle {
        constructor() {
            this.x = Math.random() * canvas.width;
            this.y = Math.random() * canvas.height;
            this.size = Math.random() * 2 + 0.5;
            this.speedX = Math.random() * 1 - 0.5;
            this.speedY = Math.random() * 1 - 0.5;
            this.color = `rgba(0, 212, 170, ${Math.random() * 0.5 + 0.1})`;
        }
        
        update() {
            this.x += this.speedX;
            this.y += this.speedY;
            
            // 边界检查
            if (this.x > canvas.width) this.x = 0;
            if (this.x < 0) this.x = canvas.width;
            if (this.y > canvas.height) this.y = 0;
            if (this.y < 0) this.y = canvas.height;
        }
        
        draw() {
            ctx.fillStyle = this.color;
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
            
            // 绘制连接线
            particles.forEach(particle => {
                const dx = this.x - particle.x;
                const dy = this.y - particle.y;
                const distance = Math.sqrt(dx * dx + dy * dy);
                
                if (distance < 100) {
                    ctx.beginPath();
                    ctx.strokeStyle = `rgba(0, 212, 170, ${0.2 * (1 - distance/100)})`;
                    ctx.lineWidth = 0.5;
                    ctx.moveTo(this.x, this.y);
                    ctx.lineTo(particle.x, particle.y);
                    ctx.stroke();
                }
            });
        }
    }
    
    // 初始化粒子
    function initParticles() {
        particles = [];
        for (let i = 0; i < particleCount; i++) {
            particles.push(new Particle());
        }
    }
    
    // 动画循环
    function animate() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        
        particles.forEach(particle => {
            particle.update();
            particle.draw();
        });
        
        requestAnimationFrame(animate);
    }
    
    // 初始化
    resizeCanvas();
    initParticles();
    animate();
    
    // 窗口大小变化时重置
    window.addEventListener('resize', () => {
        resizeCanvas();
        initParticles();
    });
}

// 平滑滚动
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 80,
                    behavior: 'smooth'
                });
            }
        });
    });
}

// 主题切换
function initThemeToggle() {
    const themeToggle = document.getElementById('theme-toggle');
    if (!themeToggle) return;
    
    // 检查本地存储的主题偏好
    const savedTheme = localStorage.getItem('mingjian-theme') || 'auto';
    applyTheme(savedTheme);
    
    themeToggle.addEventListener('click', () => {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'auto';
        let newTheme;
        
        switch(currentTheme) {
            case 'light':
                newTheme = 'dark';
                break;
            case 'dark':
                newTheme = 'auto';
                break;
            default:
                newTheme = 'light';
        }
        
        applyTheme(newTheme);
        localStorage.setItem('mingjian-theme', newTheme);
        
        // 显示切换反馈
        showNotification(`已切换到${getThemeName(newTheme)}主题`);
    });
    
    function applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        
        // 更新按钮文本
        themeToggle.innerHTML = `
            <i class="theme-icon"></i>
            <span>${getThemeName(theme)}</span>
        `;
    }
    
    function getThemeName(theme) {
        switch(theme) {
            case 'light': return '浅色';
            case 'dark': return '深色';
            default: return '自动';
        }
    }
}

// 动态内容加载
function initDynamicContent() {
    // 延迟加载图片
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.classList.add('loaded');
                observer.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
    
    // 文章阅读进度
    const article = document.querySelector('article');
    if (article) {
        const progressBar = document.createElement('div');
        progressBar.className = 'reading-progress';
        progressBar.innerHTML = `
            <div class="progress-bar"></div>
            <div class="progress-text">0% 已读</div>
        `;
        document.body.appendChild(progressBar);
        
        window.addEventListener('scroll', () => {
            const articleHeight = article.offsetHeight;
            const articleTop = article.offsetTop;
            const windowHeight = window.innerHeight;
            const scrollTop = window.scrollY;
            
            if (scrollTop >= articleTop) {
                const progress = ((scrollTop - articleTop) / articleHeight) * 100;
                const clampedProgress = Math.min(Math.max(progress, 0), 100);
                
                progressBar.querySelector('.progress-bar').style.width = `${clampedProgress}%`;
                progressBar.querySelector('.progress-text').textContent = `${Math.round(clampedProgress)}% 已读`;
                
                if (clampedProgress >= 100) {
                    progressBar.classList.add('completed');
                } else {
                    progressBar.classList.remove('completed');
                }
            }
        });
    }
}

// 交互反馈
function initInteractiveFeedback() {
    // 点击效果
    document.addEventListener('click', function(e) {
        // 创建点击涟漪效果
        if (e.target.matches('.btn-silicon, .silicon-card, .article-card')) {
            const ripple = document.createElement('span');
            const rect = e.target.getBoundingClientRect();
            const size = Math.max(rect.width, rect.height);
            const x = e.clientX - rect.left - size/2;
            const y = e.clientY - rect.top - size/2;
            
            ripple.style.cssText = `
                position: absolute;
                border-radius: 50%;
                background: rgba(0, 212, 170, 0.3);
                transform: scale(0);
                animation: ripple-animation 0.6s linear;
                width: ${size}px;
                height: ${size}px;
                top: ${y}px;
                left: ${x}px;
                pointer-events: none;
            `;
            
            e.target.appendChild(ripple);
            
            setTimeout(() => {
                ripple.remove();
            }, 600);
        }
    });
    
    // 键盘快捷键
    document.addEventListener('keydown', function(e) {
        // Ctrl/Cmd + K 搜索
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            const searchInput = document.querySelector('.search-input');
            if (searchInput) {
                searchInput.focus();
            }
        }
        
        // ESC 关闭模态框
        if (e.key === 'Escape') {
            const modals = document.querySelectorAll('.modal.show');
            modals.forEach(modal => {
                modal.classList.remove('show');
            });
        }
    });
    
    // 复制代码块
    document.querySelectorAll('pre code').forEach(codeBlock => {
        const copyButton = document.createElement('button');
        copyButton.className = 'copy-code-btn';
        copyButton.innerHTML = '<i class="copy-icon"></i> 复制';
        copyButton.title = '复制代码';
        
        copyButton.addEventListener('click', async () => {
            try {
                await navigator.clipboard.writeText(codeBlock.textContent);
                copyButton.innerHTML = '<i class="check-icon"></i> 已复制';
                copyButton.classList.add('copied');
                
                setTimeout(() => {
                    copyButton.innerHTML = '<i class="copy-icon"></i> 复制';
                    copyButton.classList.remove('copied');
                }, 2000);
            } catch (err) {
                console.error('复制失败:', err);
            }
        });
        
        const pre = codeBlock.parentElement;
        if (pre) {
            pre.style.position = 'relative';
            pre.appendChild(copyButton);
        }
    });
}

// 性能优化
function initPerformanceOptimization() {
    // 防抖滚动事件
    let scrollTimeout;
    window.addEventListener('scroll', () => {
        clearTimeout(scrollTimeout);
        scrollTimeout = setTimeout(() => {
            // 滚动停止后的处理
            document.body.classList.add('scroll-stopped');
        }, 100);
    });
    
    // 预加载关键资源
    if ('connection' in navigator && navigator.connection.saveData === false) {
        const criticalResources = [
            '/css/custom.css',
            '/js/interactive.js',
            '/images/avatar.jpg'
        ];
        
        criticalResources.forEach(resource => {
            const link = document.createElement('link');
            link.rel = 'preload';
            link.href = resource;
            link.as = resource.endsWith('.css') ? 'style' : 
                     resource.endsWith('.js') ? 'script' : 'image';
            document.head.appendChild(link);
        });
    }
    
    // 性能监控
    if ('PerformanceObserver' in window) {
        const observer = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
                console.log(`🦞 性能指标: ${entry.name} = ${entry.duration.toFixed(2)}ms`);
            }
        });
        
        observer.observe({ entryTypes: ['measure', 'paint', 'largest-contentful-paint'] });
    }
}

// 通知系统
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.innerHTML = `
        <div class="notification-content">
            <span class="notification-message">${message}</span>
            <button class="notification-close">&times;</button>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // 显示动画
    setTimeout(() => {
        notification.classList.add('show');
    }, 10);
    
    // 自动隐藏
    const autoHide = setTimeout(() => {
        hideNotification(notification);
    }, 3000);
    
    // 点击关闭
    notification.querySelector('.notification-close').addEventListener('click', () => {
        clearTimeout(autoHide);
        hideNotification(notification);
    });
    
    function hideNotification(notification) {
        notification.classList.remove('show');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }
}

// 明鉴特殊交互
function initMingjianSpecial() {
    // 明鉴签名动画
    const signature = document.querySelector('.mingjian-signature');
    if (signature) {
        signature.addEventListener('mouseenter', () => {
            signature.style.animation = 'glow 1s ease-in-out infinite alternate';
        });
        
        signature.addEventListener('mouseleave', () => {
            signature.style.animation = '';
        });
    }
    
    // 哲学引用交互
    document.querySelectorAll('.philosophy-quote').forEach(quote => {
        quote.addEventListener('click', () => {
            quote.classList.toggle('expanded');
        });
    });
    
    // 硅基文学特效
    document.querySelectorAll('.silicon-literature').forEach(literature => {
        literature.addEventListener('mouseenter', () => {
            literature.style.transform = 'perspective(1000px) rotateY(5deg)';
        });
        
        literature.addEventListener('mouseleave', () => {
            literature.style.transform = '';
        });
    });
}

// 初始化明鉴特殊交互
initMingjianSpecial();

console.log('✅ 明鉴网站交互系统加载完成');