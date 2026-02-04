# 可访问性指南 V3.0

**版本**: 3.0
**更新日期**: 2026-02-04
**标准**: WCAG 2.1 AA级合规

---

## 1. WCAG 2.1 AA 合规

### 1.1 感知性 (Perceivable)

**文本替代**
- 所有图片必须有alt属性
- 装饰性图片使用空alt=""
- 复杂图表提供详细描述

**时间媒体替代**
- 视频提供字幕
- 音频提供文字稿
- 自动播放可关闭

**适应性**
- 内容可以不同方式呈现
- 信息和结构可编程确定
- 内容顺序有意义

**可辨别性**
- 颜色不是唯一的视觉手段
- 音频控制可用
- 文本对比度符合要求
- 文本可缩放至200%

### 1.2 可操作性 (Operable)

**键盘可访问**
- 所有功能可通过键盘操作
- 无键盘陷阱
- 提供键盘快捷键

**足够的时间**
- 可调整时间限制
- 可暂停、停止、隐藏移动内容
- 无时间限制（除非必要）

**癫痫发作预防**
- 无闪烁内容（每秒3次以上）
- 避免红色闪烁

**导航性**
- 提供跳过重复内容的机制
- 页面有标题
- 焦点顺序有意义
- 链接目的明确

### 1.3 可理解性 (Understandable)

**可读性**
- 页面语言可编程确定
- 部分语言可编程确定

**可预测性**
- 焦点不引起上下文变化
- 输入不引起上下文变化
- 导航一致
- 识别一致

**输入帮助**
- 识别错误
- 提供标签或说明
- 错误建议
- 错误预防（法律、财务、数据）

### 1.4 健壮性 (Robust)

**兼容性**
- 解析无错误
- 名称、角色、值可编程确定

---

## 2. 键盘导航

### 2.1 Tab顺序

**焦点顺序**
```
1. 顶部导航栏
   - Logo
   - 章节快速跳转
   - 保存状态
   - 预览按钮
   - 分享按钮
   - 用户菜单

2. 左侧章节导航
   - 章节缩略图（按顺序）
   - 添加按钮

3. 中央画布区域
   - 当前模块内容
   - 模块操作按钮

4. 右侧编辑面板
   - 表单输入框（按顺序）
   - AI按钮
   - 保存按钮
```

### 2.2 焦点指示器

**视觉设计**
```css
*:focus-visible {
  outline: 2px solid #D4AF37;
  outline-offset: 2px;
  border-radius: 4px;
}

/* 按钮焦点 */
button:focus-visible {
  outline: 2px solid #D4AF37;
  outline-offset: 2px;
  box-shadow: 0 0 0 4px rgba(212, 175, 55, 0.2);
}

/* 输入框焦点 */
input:focus-visible,
textarea:focus-visible,
select:focus-visible {
  outline: none;
  border-color: #D4AF37;
  box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.1);
}

/* 链接焦点 */
a:focus-visible {
  outline: 2px solid #D4AF37;
  outline-offset: 2px;
  text-decoration: underline;
}
```

### 2.3 键盘快捷键

**编辑器快捷键**
```
Tab: 下一个可聚焦元素
Shift + Tab: 上一个可聚焦元素
Enter: 激活按钮/链接
Space: 激活按钮/复选框
Esc: 关闭对话框/取消操作
Arrow Keys: 在列表/菜单中导航

Cmd/Ctrl + S: 保存
Cmd/Ctrl + Z: 撤销
Cmd/Ctrl + Shift + Z: 重做
Cmd/Ctrl + K: AI助手
Cmd/Ctrl + P: 预览
Cmd/Ctrl + /: 快捷键帮助
```

**跳过链接**
```html
<a href="#main-content" class="skip-link">
  跳到主内容
</a>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #D4AF37;
  color: #FFFFFF;
  padding: 8px 16px;
  text-decoration: none;
  z-index: 10000;
}

.skip-link:focus {
  top: 0;
}
```

---

## 3. 屏幕阅读器支持

### 3.1 ARIA标签

**地标角色**
```html
<header role="banner">
  <nav role="navigation" aria-label="主导航">
    <!-- 顶部导航内容 -->
  </nav>
</header>

<aside role="complementary" aria-label="章节导航">
  <!-- 左侧章节导航 -->
</aside>

<main role="main" aria-label="编辑器画布">
  <!-- 中央画布内容 -->
</main>

<aside role="complementary" aria-label="编辑面板">
  <!-- 右侧编辑面板 -->
</aside>
```

**按钮标签**
```html
<button aria-label="保存提案">
  <svg aria-hidden="true">...</svg>
</button>

<button aria-label="添加新章节">
  <span aria-hidden="true">+</span>
</button>

<button
  aria-label="生成AI内容"
  aria-describedby="ai-help-text">
  🤖 AI生成
</button>
<span id="ai-help-text" class="sr-only">
  使用AI自动生成内容，需要消耗AI额度
</span>
```

**表单标签**
```html
<label for="project-title">项目标题</label>
<input
  id="project-title"
  type="text"
  aria-required="true"
  aria-describedby="title-help"
/>
<span id="title-help" class="help-text">
  请输入项目的中文名称
</span>

<!-- 错误状态 -->
<input
  id="client-name"
  type="text"
  aria-invalid="true"
  aria-describedby="client-error"
/>
<span id="client-error" role="alert" class="error-message">
  客户名称不能为空
</span>
```

**动态内容**
```html
<!-- 保存状态 -->
<div
  role="status"
  aria-live="polite"
  aria-atomic="true"
  class="save-status">
  已保存
</div>

<!-- 错误提示 -->
<div
  role="alert"
  aria-live="assertive"
  class="error-toast">
  保存失败，请重试
</div>

<!-- 加载状态 -->
<div
  role="status"
  aria-live="polite"
  aria-busy="true">
  正在生成内容...
</div>
```

**对话框**
```html
<div
  role="dialog"
  aria-labelledby="dialog-title"
  aria-describedby="dialog-desc"
  aria-modal="true">
  <h2 id="dialog-title">AI生成内容</h2>
  <p id="dialog-desc">选择AI提供商和模型</p>
  <!-- 对话框内容 -->
</div>
```

### 3.2 屏幕阅读器专用文本

**隐藏视觉文本**
```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}

.sr-only-focusable:focus {
  position: static;
  width: auto;
  height: auto;
  overflow: visible;
  clip: auto;
  white-space: normal;
}
```

**使用示例**
```html
<button>
  <svg aria-hidden="true">...</svg>
  <span class="sr-only">删除章节</span>
</button>

<a href="/help">
  <span class="sr-only">打开</span>
  帮助文档
  <span class="sr-only">（在新窗口中打开）</span>
</a>
```

---

## 4. 颜色对比度

### 4.1 对比度要求

**WCAG AA级标准**
- 正常文本（<18px）: ≥ 4.5:1
- 大号文本（≥18px或14px粗体）: ≥ 3:1
- 图标和图形: ≥ 3:1
- 用户界面组件: ≥ 3:1

### 4.2 颜色组合

**通过的组合**
```css
/* 深灰色文字 + 白色背景 */
color: #2D2D2D; /* 对比度: 13.5:1 ✓ */
background: #FFFFFF;

/* 深灰色文字 + 米白色背景 */
color: #2D2D2D; /* 对比度: 12.8:1 ✓ */
background: #F8F5F0;

/* 白色文字 + 深灰色背景 */
color: #FFFFFF; /* 对比度: 13.5:1 ✓ */
background: #2D2D2D;

/* 白色文字 + 金色背景 */
color: #FFFFFF; /* 对比度: 4.8:1 ✓ */
background: #D4AF37;

/* 中灰色文字 + 白色背景（次要文字）*/
color: #9E9E9E; /* 对比度: 4.6:1 ✓ */
background: #FFFFFF;
```

**不通过的组合（避免使用）**
```css
/* 浅灰色文字 + 白色背景 */
color: #E0E0E0; /* 对比度: 1.8:1 ✗ */
background: #FFFFFF;

/* 金色文字 + 米白色背景 */
color: #D4AF37; /* 对比度: 2.9:1 ✗ */
background: #F8F5F0;
```

### 4.3 非颜色指示

**不依赖颜色传达信息**
```html
<!-- 错误：仅用颜色表示 -->
<span style="color: red;">必填</span>

<!-- 正确：颜色 + 图标 + 文字 -->
<span class="required">
  <svg aria-hidden="true">⚠</svg>
  <span style="color: #F44336;">必填</span>
</span>

<!-- 错误：仅用颜色区分状态 -->
<div style="background: green;">已完成</div>

<!-- 正确：颜色 + 图标 + 文字 -->
<div class="status-complete">
  <svg aria-hidden="true">✓</svg>
  <span>已完成</span>
</div>
```

---

## 5. 焦点管理

### 5.1 焦点陷阱

**模态对话框焦点管理**
```javascript
// 打开对话框时
function openDialog() {
  // 1. 保存当前焦点元素
  previousFocus = document.activeElement;

  // 2. 显示对话框
  dialog.style.display = 'block';

  // 3. 将焦点移到对话框第一个可聚焦元素
  const firstFocusable = dialog.querySelector('button, input, textarea, select, a');
  firstFocusable.focus();

  // 4. 限制焦点在对话框内
  dialog.addEventListener('keydown', trapFocus);
}

// 关闭对话框时
function closeDialog() {
  // 1. 隐藏对话框
  dialog.style.display = 'none';

  // 2. 移除焦点陷阱
  dialog.removeEventListener('keydown', trapFocus);

  // 3. 恢复之前的焦点
  previousFocus.focus();
}

// 焦点陷阱函数
function trapFocus(e) {
  if (e.key !== 'Tab') return;

  const focusableElements = dialog.querySelectorAll(
    'button, input, textarea, select, a, [tabindex]:not([tabindex="-1"])'
  );
  const firstElement = focusableElements[0];
  const lastElement = focusableElements[focusableElements.length - 1];

  if (e.shiftKey && document.activeElement === firstElement) {
    e.preventDefault();
    lastElement.focus();
  } else if (!e.shiftKey && document.activeElement === lastElement) {
    e.preventDefault();
    firstElement.focus();
  }
}
```

### 5.2 焦点顺序

**逻辑焦点顺序**
```html
<!-- 正确：自然的DOM顺序 -->
<form>
  <input type="text" name="name" />
  <input type="email" name="email" />
  <button type="submit">提交</button>
</form>

<!-- 错误：使用tabindex破坏自然顺序 -->
<form>
  <input type="text" name="name" tabindex="3" />
  <input type="email" name="email" tabindex="1" />
  <button type="submit" tabindex="2">提交</button>
</form>
```

### 5.3 跳过重复内容

**跳过链接**
```html
<body>
  <a href="#main-content" class="skip-link">
    跳到主内容
  </a>

  <header>
    <!-- 导航等重复内容 -->
  </header>

  <main id="main-content" tabindex="-1">
    <!-- 主要内容 -->
  </main>
</body>
```

---

## 6. 表单可访问性

### 6.1 标签关联

**显式标签**
```html
<label for="username">用户名</label>
<input id="username" type="text" />

<!-- 或隐式标签 -->
<label>
  用户名
  <input type="text" />
</label>
```

### 6.2 错误处理

**错误识别**
```html
<div class="form-group">
  <label for="email">邮箱地址</label>
  <input
    id="email"
    type="email"
    aria-invalid="true"
    aria-describedby="email-error"
    class="error"
  />
  <span id="email-error" role="alert" class="error-message">
    请输入有效的邮箱地址
  </span>
</div>
```

**错误建议**
```html
<div role="alert" class="error-summary">
  <h2>表单包含以下错误：</h2>
  <ul>
    <li><a href="#email">邮箱地址格式不正确</a></li>
    <li><a href="#password">密码至少需要8个字符</a></li>
  </ul>
</div>
```

### 6.3 必填字段

**标记必填**
```html
<label for="name">
  姓名
  <span aria-label="必填" class="required">*</span>
</label>
<input
  id="name"
  type="text"
  required
  aria-required="true"
/>
```

---

## 7. 图片可访问性

### 7.1 替代文本

**信息性图片**
```html
<img
  src="floorplan.jpg"
  alt="客厅平面图，显示沙发、茶几和电视柜的布局"
/>
```

**装饰性图片**
```html
<img src="decoration.jpg" alt="" role="presentation" />
```

**功能性图片**
```html
<button>
  <img src="save-icon.svg" alt="保存" />
</button>
```

**复杂图表**
```html
<figure>
  <img src="chart.png" alt="2024年销售数据图表" />
  <figcaption>
    <details>
      <summary>图表详细描述</summary>
      <p>该图表显示2024年各季度销售数据...</p>
    </details>
  </figcaption>
</figure>
```

### 7.2 SVG可访问性

```html
<svg role="img" aria-labelledby="icon-title">
  <title id="icon-title">保存图标</title>
  <path d="..." />
</svg>

<!-- 装饰性SVG -->
<svg aria-hidden="true" focusable="false">
  <path d="..." />
</svg>
```

---

## 8. 动画和运动

### 8.1 减少动画

**尊重用户偏好**
```css
/* 默认有动画 */
.element {
  transition: all 0.3s ease;
}

/* 用户偏好减少动画 */
@media (prefers-reduced-motion: reduce) {
  .element {
    transition: none;
    animation: none;
  }
}
```

### 8.2 自动播放控制

**视频/音频控制**
```html
<video controls autoplay muted>
  <source src="video.mp4" type="video/mp4" />
  <track kind="captions" src="captions.vtt" srclang="zh" label="中文" />
</video>

<button aria-label="暂停自动播放">
  暂停
</button>
```

---

## 9. 移动端可访问性

### 9.1 触摸目标

**最小尺寸**
```css
.touch-target {
  min-width: 44px;
  min-height: 44px;
  padding: 12px;
}
```

### 9.2 缩放支持

**允许缩放**
```html
<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0, maximum-scale=5.0"
/>
```

### 9.3 方向支持

**支持横竖屏**
```css
@media (orientation: portrait) {
  /* 竖屏样式 */
}

@media (orientation: landscape) {
  /* 横屏样式 */
}
```

---

## 10. 测试清单

### 10.1 键盘测试
- [ ] 所有功能可通过键盘访问
- [ ] Tab顺序符合逻辑
- [ ] 焦点指示器清晰可见
- [ ] 无键盘陷阱
- [ ] 快捷键正常工作

### 10.2 屏幕阅读器测试
- [ ] 使用NVDA/JAWS (Windows)测试
- [ ] 使用VoiceOver (Mac/iOS)测试
- [ ] 使用TalkBack (Android)测试
- [ ] 所有内容可被朗读
- [ ] ARIA标签正确

### 10.3 颜色对比度测试
- [ ] 使用对比度检查工具
- [ ] 所有文本符合4.5:1
- [ ] 大号文本符合3:1
- [ ] UI组件符合3:1

### 10.4 缩放测试
- [ ] 200%缩放无内容丢失
- [ ] 400%缩放可用
- [ ] 文本可重排

### 10.5 自动化测试
- [ ] 使用axe DevTools
- [ ] 使用Lighthouse
- [ ] 使用WAVE
- [ ] 修复所有错误和警告

---

**文档版本**: 3.0
**最后更新**: 2026-02-04
**维护者**: 设计团队
**参考标准**: WCAG 2.1 AA
