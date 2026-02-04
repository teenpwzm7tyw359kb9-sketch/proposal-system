# 提案展示系统设计系统 V3.0

**版本**: 3.0
**更新日期**: 2026-02-04
**设计风格**: 杂志风格 + 奢侈品美学 (Magazine Style + Luxury Aesthetics)
**适用范围**: 提案编辑器、作品集展示、所有系统界面

---

## 目录

1. [设计理念](#1-设计理念)
2. [色彩系统](#2-色彩系统)
3. [字体系统](#3-字体系统)
4. [间距系统](#4-间距系统)
5. [组件状态](#5-组件状态)
6. [动画规范](#6-动画规范)
7. [响应式断点](#7-响应式断点)
8. [网格系统](#8-网格系统)
9. [阴影与深度](#9-阴影与深度)
10. [图标系统](#10-图标系统)

---

## 1. 设计理念

### 1.1 核心原则

**杂志风格 (Magazine Style)**
- 大胆的排版和留白
- 高质量的图片展示
- 清晰的视觉层次
- 优雅的文字编排

**奢侈品美学 (Luxury Aesthetics)**
- 精致的细节处理
- 高端的色彩搭配
- 克制的装饰元素
- 专业的品质感

### 1.2 设计价值观

- **简洁至上**: 去除不必要的装饰，专注内容本身
- **品质优先**: 每个细节都体现专业和精致
- **用户中心**: 界面服务于用户目标，不喧宾夺主
- **一致性**: 整个系统保持统一的视觉语言

---

## 2. 色彩系统

### 2.1 主色调 (Primary Colors)

```
深灰色 (Deep Gray)
- HEX: #2D2D2D
- RGB: 45, 45, 45
- 用途: 主要文字、深色背景、重要元素
- 心理: 专业、稳重、高端

金色 (Gold)
- HEX: #D4AF37
- RGB: 212, 175, 55
- 用途: 强调元素、按钮、图标高亮
- 心理: 奢华、品质、价值
```

### 2.2 辅助色 (Secondary Colors)

```
米白色 (Off-White)
- HEX: #F8F5F0
- RGB: 248, 245, 240
- 用途: 页面背景、卡片背景、浅色区域

浅灰色 (Light Gray)
- HEX: #E0E0E0
- RGB: 224, 224, 224
- 用途: 分割线、边框、禁用状态

中灰色 (Medium Gray)
- HEX: #9E9E9E
- RGB: 158, 158, 158
- 用途: 次要文字、图标、辅助信息

纯白色 (Pure White)
- HEX: #FFFFFF
- RGB: 255, 255, 255
- 用途: 卡片、弹窗、输入框背景
```

### 2.3 功能色 (Functional Colors)

```
成功色 (Success)
- HEX: #4CAF50
- RGB: 76, 175, 80
- 用途: 成功提示、完成状态、正向反馈

警告色 (Warning)
- HEX: #FF9800
- RGB: 255, 152, 0
- 用途: 警告提示、需要注意的信息

错误色 (Error)
- HEX: #F44336
- RGB: 244, 67, 54
- 用途: 错误提示、删除操作、危险操作

信息色 (Info)
- HEX: #2196F3
- RGB: 33, 150, 243
- 用途: 信息提示、链接、可点击元素
```

### 2.4 语义色 (Semantic Colors)

```
链接色 (Link)
- Default: #2196F3
- Hover: #1976D2
- Visited: #7B1FA2

背景色层级 (Background Hierarchy)
- Level 1 (页面背景): #F8F5F0
- Level 2 (卡片背景): #FFFFFF
- Level 3 (悬浮元素): #FFFFFF + Shadow

文字色层级 (Text Hierarchy)
- Primary (主要文字): #2D2D2D (100% opacity)
- Secondary (次要文字): #2D2D2D (70% opacity)
- Tertiary (辅助文字): #9E9E9E
- Disabled (禁用文字): #E0E0E0
```

### 2.5 色彩使用规范

**对比度要求**
- 正文文字与背景: ≥ 4.5:1 (WCAG AA)
- 大号文字与背景: ≥ 3:1 (WCAG AA)
- 交互元素与背景: ≥ 3:1

**色彩搭配原则**
- 主色调占60%（背景和大面积区域）
- 辅助色占30%（次要元素和分区）
- 强调色占10%（按钮、链接、重要提示）

---

## 3. 字体系统

### 3.1 字体家族

```css
/* 中文字体 */
font-family: 'Source Han Sans CN', 'Noto Sans SC', 'PingFang SC',
             'Microsoft YaHei', sans-serif;

/* 英文字体 */
font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI',
             'Roboto', 'Helvetica Neue', Arial, sans-serif;

/* 等宽字体（代码、数字） */
font-family: 'JetBrains Mono', 'Fira Code', 'Consolas',
             'Monaco', monospace;
```

### 3.2 字体层级

```css
/* H1 - 主标题 */
font-size: 48px;
line-height: 1.2;
font-weight: 700;
letter-spacing: -0.02em;

/* H2 - 次级标题 */
font-size: 36px;
line-height: 1.3;
font-weight: 600;
letter-spacing: -0.01em;

/* H3 - 三级标题 */
font-size: 28px;
line-height: 1.4;
font-weight: 600;
letter-spacing: 0;

/* H4 - 四级标题 */
font-size: 24px;
line-height: 1.4;
font-weight: 600;
letter-spacing: 0;

/* H5 - 五级标题 */
font-size: 20px;
line-height: 1.5;
font-weight: 600;
letter-spacing: 0;

/* H6 - 六级标题 */
font-size: 18px;
line-height: 1.5;
font-weight: 600;
letter-spacing: 0;

/* Body Large - 大号正文 */
font-size: 18px;
line-height: 1.6;
font-weight: 400;
letter-spacing: 0;

/* Body - 标准正文 */
font-size: 16px;
line-height: 1.6;
font-weight: 400;
letter-spacing: 0;

/* Body Small - 小号正文 */
font-size: 14px;
line-height: 1.6;
font-weight: 400;
letter-spacing: 0;

/* Caption - 说明文字 */
font-size: 12px;
line-height: 1.5;
font-weight: 400;
letter-spacing: 0.01em;

/* Overline - 上标文字 */
font-size: 11px;
line-height: 1.5;
font-weight: 600;
letter-spacing: 0.08em;
text-transform: uppercase;
```

### 3.3 字体权重

```
Light: 300 - 用于大标题的轻盈感
Regular: 400 - 正文默认权重
Medium: 500 - 次要强调
Semibold: 600 - 标题和重要信息
Bold: 700 - 主标题和强调
```

### 3.4 行高规范

```
标题行高: 1.2 - 1.4 (紧凑，突出视觉冲击)
正文行高: 1.6 - 1.8 (舒适阅读)
说明文字: 1.5 (紧凑但清晰)
```

---

## 4. 间距系统

### 4.1 基础单位

**Base Unit: 4px**

所有间距都是4px的倍数，确保视觉一致性和像素完美对齐。

### 4.2 间距刻度

```
4px   (xs)   - 最小间距，紧密相关元素
8px   (sm)   - 小间距，相关元素组
12px  (md)   - 中等间距，段落内部
16px  (base) - 基础间距，标准元素间距
20px  (lg)   - 大间距，组件间距
24px  (xl)   - 超大间距，区块间距
32px  (2xl)  - 区域间距
40px  (3xl)  - 大区域间距
48px  (4xl)  - 页面级间距
64px  (5xl)  - 超大页面级间距
80px  (6xl)  - 特大间距
96px  (7xl)  - 极大间距
```

### 4.3 组件内边距 (Padding)

```css
/* 按钮 */
padding: 12px 24px; /* 中等按钮 */
padding: 8px 16px;  /* 小按钮 */
padding: 16px 32px; /* 大按钮 */

/* 输入框 */
padding: 12px 16px; /* 标准输入框 */

/* 卡片 */
padding: 24px; /* 标准卡片 */
padding: 32px; /* 大卡片 */

/* 弹窗 */
padding: 32px; /* 弹窗内容区 */
padding: 24px; /* 弹窗头部/底部 */
```

### 4.4 组件外边距 (Margin)

```css
/* 段落间距 */
margin-bottom: 16px;

/* 标题间距 */
margin-bottom: 24px; /* H1, H2 */
margin-bottom: 20px; /* H3, H4 */
margin-bottom: 16px; /* H5, H6 */

/* 组件间距 */
margin-bottom: 24px; /* 标准组件 */
margin-bottom: 32px; /* 大组件 */

/* 区块间距 */
margin-bottom: 48px; /* 页面区块 */
```

---

## 5. 组件状态

### 5.1 交互状态

**Default (默认状态)**
```css
background: #FFFFFF;
border: 1px solid #E0E0E0;
color: #2D2D2D;
cursor: default;
```

**Hover (悬停状态)**
```css
background: #F8F5F0;
border: 1px solid #D4AF37;
color: #2D2D2D;
cursor: pointer;
transition: all 0.2s ease;
```

**Active (激活状态)**
```css
background: #D4AF37;
border: 1px solid #D4AF37;
color: #FFFFFF;
transform: scale(0.98);
```

**Focus (聚焦状态)**
```css
outline: 2px solid #D4AF37;
outline-offset: 2px;
box-shadow: 0 0 0 4px rgba(212, 175, 55, 0.1);
```

**Disabled (禁用状态)**
```css
background: #F8F5F0;
border: 1px solid #E0E0E0;
color: #9E9E9E;
cursor: not-allowed;
opacity: 0.6;
```

**Loading (加载状态)**
```css
background: #F8F5F0;
color: #9E9E9E;
cursor: wait;
/* 显示加载动画 */
```

### 5.2 按钮状态

**Primary Button (主要按钮)**
```css
/* Default */
background: #D4AF37;
color: #FFFFFF;
border: none;

/* Hover */
background: #C19F2F;
box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);

/* Active */
background: #B08F27;
transform: translateY(1px);
```

**Secondary Button (次要按钮)**
```css
/* Default */
background: #FFFFFF;
color: #2D2D2D;
border: 1px solid #E0E0E0;

/* Hover */
background: #F8F5F0;
border-color: #D4AF37;

/* Active */
background: #E0E0E0;
```

**Ghost Button (幽灵按钮)**
```css
/* Default */
background: transparent;
color: #2D2D2D;
border: 1px solid #2D2D2D;

/* Hover */
background: #2D2D2D;
color: #FFFFFF;
```

### 5.3 输入框状态

```css
/* Default */
border: 1px solid #E0E0E0;
background: #FFFFFF;

/* Focus */
border: 1px solid #D4AF37;
box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.1);

/* Error */
border: 1px solid #F44336;
box-shadow: 0 0 0 3px rgba(244, 67, 54, 0.1);

/* Success */
border: 1px solid #4CAF50;
box-shadow: 0 0 0 3px rgba(76, 175, 80, 0.1);

/* Disabled */
background: #F8F5F0;
color: #9E9E9E;
cursor: not-allowed;
```

---

## 6. 动画规范

### 6.1 过渡时长 (Duration)

```css
/* 快速 - 微交互 */
transition-duration: 150ms;
/* 用于: 按钮悬停、图标变化 */

/* 标准 - 常规交互 */
transition-duration: 200ms;
/* 用于: 卡片悬停、下拉菜单 */

/* 中等 - 复杂交互 */
transition-duration: 300ms;
/* 用于: 模态框、侧边栏 */

/* 慢速 - 页面级动画 */
transition-duration: 400ms;
/* 用于: 页面切换、大型元素 */
```

### 6.2 缓动函数 (Easing)

```css
/* 标准缓动 - 最常用 */
transition-timing-function: cubic-bezier(0.4, 0.0, 0.2, 1);
/* ease-in-out 的优化版本 */

/* 进入 - 元素出现 */
transition-timing-function: cubic-bezier(0.0, 0.0, 0.2, 1);
/* 快速开始，平滑结束 */

/* 退出 - 元素消失 */
transition-timing-function: cubic-bezier(0.4, 0.0, 1, 1);
/* 平滑开始，快速结束 */

/* 弹性 - 特殊效果 */
transition-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55);
/* 轻微回弹效果 */
```

### 6.3 微交互动画

**按钮点击**
```css
@keyframes button-press {
  0% { transform: scale(1); }
  50% { transform: scale(0.98); }
  100% { transform: scale(1); }
}
```

**加载旋转**
```css
@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
animation: spin 1s linear infinite;
```

**淡入**
```css
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}
animation: fade-in 0.3s ease;
```

**滑入（从下）**
```css
@keyframes slide-up {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
animation: slide-up 0.3s ease;
```

**脉冲（保存指示器）**
```css
@keyframes pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}
animation: pulse 1.5s ease-in-out infinite;
```

### 6.4 页面过渡

```css
/* 页面淡入淡出 */
.page-transition-enter {
  opacity: 0;
}
.page-transition-enter-active {
  opacity: 1;
  transition: opacity 300ms ease;
}
.page-transition-exit {
  opacity: 1;
}
.page-transition-exit-active {
  opacity: 0;
  transition: opacity 300ms ease;
}
```

---

## 7. 响应式断点

### 7.1 断点定义

```css
/* Mobile (手机) */
@media (max-width: 767px) {
  /* 小屏幕手机: 320px - 767px */
}

/* Tablet (平板) */
@media (min-width: 768px) and (max-width: 1023px) {
  /* 平板设备: 768px - 1023px */
}

/* Desktop (桌面) */
@media (min-width: 1024px) {
  /* 桌面设备: 1024px+ */
}

/* Large Desktop (大屏桌面) */
@media (min-width: 1440px) {
  /* 大屏幕: 1440px+ */
}

/* Extra Large Desktop (超大屏) */
@media (min-width: 1920px) {
  /* 超大屏幕: 1920px+ */
}
```

### 7.2 容器宽度

```css
/* Mobile */
max-width: 100%;
padding: 0 16px;

/* Tablet */
max-width: 768px;
padding: 0 24px;

/* Desktop */
max-width: 1200px;
padding: 0 32px;

/* Large Desktop */
max-width: 1440px;
padding: 0 48px;
```

### 7.3 字体响应式

```css
/* H1 */
font-size: 32px; /* Mobile */
font-size: 40px; /* Tablet */
font-size: 48px; /* Desktop */

/* H2 */
font-size: 28px; /* Mobile */
font-size: 32px; /* Tablet */
font-size: 36px; /* Desktop */

/* Body */
font-size: 14px; /* Mobile */
font-size: 16px; /* Tablet+ */
```

---

## 8. 网格系统

### 8.1 12列网格

```css
.container {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  gap: 24px;
}

/* 列跨度示例 */
.col-1 { grid-column: span 1; }
.col-2 { grid-column: span 2; }
.col-3 { grid-column: span 3; }
.col-4 { grid-column: span 4; }
.col-6 { grid-column: span 6; }
.col-8 { grid-column: span 8; }
.col-12 { grid-column: span 12; }
```

### 8.2 间隙 (Gap)

```css
/* 小间隙 */
gap: 16px;

/* 标准间隙 */
gap: 24px;

/* 大间隙 */
gap: 32px;
```

---

## 9. 阴影与深度

### 9.1 阴影层级

```css
/* Level 0 - 无阴影 */
box-shadow: none;

/* Level 1 - 轻微悬浮 */
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08);

/* Level 2 - 卡片 */
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);

/* Level 3 - 悬停卡片 */
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);

/* Level 4 - 弹窗 */
box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);

/* Level 5 - 模态框 */
box-shadow: 0 16px 48px rgba(0, 0, 0, 0.2);
```

### 9.2 内阴影

```css
/* 输入框内阴影 */
box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.05);

/* 按下效果 */
box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
```

---

## 10. 图标系统

### 10.1 图标尺寸

```css
/* 小图标 */
width: 16px;
height: 16px;

/* 标准图标 */
width: 20px;
height: 20px;

/* 中等图标 */
width: 24px;
height: 24px;

/* 大图标 */
width: 32px;
height: 32px;

/* 超大图标 */
width: 48px;
height: 48px;
```

### 10.2 图标库

推荐使用: **Lucide Icons** 或 **Heroicons**

特点:
- 简洁现代
- 线条一致
- 易于定制
- 支持多种尺寸

### 10.3 图标颜色

```css
/* 默认 */
color: #2D2D2D;

/* 次要 */
color: #9E9E9E;

/* 强调 */
color: #D4AF37;

/* 禁用 */
color: #E0E0E0;
```

---

## 11. 三面板编辑器布局规范

### 11.1 顶部导航栏

```css
height: 64px;
background: #FFFFFF;
border-bottom: 1px solid #E0E0E0;
box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
position: fixed;
top: 0;
left: 0;
right: 0;
z-index: 1000;
```

### 11.2 左侧章节导航

```css
width: 80px;
background: #F8F5F0;
border-right: 1px solid #E0E0E0;
position: fixed;
top: 64px;
left: 0;
bottom: 0;
overflow-y: auto;
```

### 11.3 中央画布区域

```css
margin-left: 80px;
margin-right: 450px; /* 右侧面板宽度 */
margin-top: 64px;
background: #FFFFFF;
min-height: calc(100vh - 64px);
```

### 11.4 右侧编辑面板

```css
width: 450px;
background: #FFFFFF;
border-left: 1px solid #E0E0E0;
position: fixed;
top: 64px;
right: 0;
bottom: 0;
overflow-y: auto;
box-shadow: -2px 0 8px rgba(0, 0, 0, 0.05);

/* 收起状态 */
transform: translateX(450px);
transition: transform 0.3s ease;
```

---

## 12. 可访问性规范

### 12.1 颜色对比度

- 正文文字: ≥ 4.5:1
- 大号文字 (18px+): ≥ 3:1
- 图标和图形: ≥ 3:1

### 12.2 焦点指示器

```css
:focus-visible {
  outline: 2px solid #D4AF37;
  outline-offset: 2px;
}
```

### 12.3 触摸目标

最小尺寸: 44px × 44px (移动端)

### 12.4 ARIA标签

所有交互元素必须有适当的ARIA标签和角色。

---

## 13. 设计令牌 (Design Tokens)

```json
{
  "colors": {
    "primary": {
      "deep-gray": "#2D2D2D",
      "gold": "#D4AF37"
    },
    "secondary": {
      "off-white": "#F8F5F0",
      "light-gray": "#E0E0E0",
      "medium-gray": "#9E9E9E",
      "white": "#FFFFFF"
    },
    "functional": {
      "success": "#4CAF50",
      "warning": "#FF9800",
      "error": "#F44336",
      "info": "#2196F3"
    }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "12px",
    "base": "16px",
    "lg": "20px",
    "xl": "24px",
    "2xl": "32px",
    "3xl": "40px",
    "4xl": "48px",
    "5xl": "64px",
    "6xl": "80px",
    "7xl": "96px"
  },
  "typography": {
    "fontFamily": {
      "chinese": "'Source Han Sans CN', 'Noto Sans SC', 'PingFang SC', 'Microsoft YaHei', sans-serif",
      "english": "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif",
      "mono": "'JetBrains Mono', 'Fira Code', 'Consolas', monospace"
    },
    "fontSize": {
      "h1": "48px",
      "h2": "36px",
      "h3": "28px",
      "h4": "24px",
      "h5": "20px",
      "h6": "18px",
      "body-lg": "18px",
      "body": "16px",
      "body-sm": "14px",
      "caption": "12px",
      "overline": "11px"
    }
  },
  "borderRadius": {
    "none": "0",
    "sm": "4px",
    "base": "8px",
    "lg": "12px",
    "xl": "16px",
    "full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 3px rgba(0, 0, 0, 0.08)",
    "base": "0 2px 8px rgba(0, 0, 0, 0.1)",
    "md": "0 4px 16px rgba(0, 0, 0, 0.12)",
    "lg": "0 8px 24px rgba(0, 0, 0, 0.15)",
    "xl": "0 16px 48px rgba(0, 0, 0, 0.2)"
  }
}
```

---

**文档版本**: 3.0
**最后更新**: 2026-02-04
**维护者**: 设计团队
**状态**: 已发布
