# 编辑器组件设计规范 V3.0

**版本**: 3.0
**更新日期**: 2026-02-04
**适用范围**: 提案编辑器三面板布局及所有12个模块

---

## 目录

1. [顶部导航栏](#1-顶部导航栏)
2. [左侧章节导航](#2-左侧章节导航)
3. [中央画布区域](#3-中央画布区域)
4. [右侧编辑面板](#4-右侧编辑面板)
5. [AI集成UI](#5-ai集成ui)
6. [版本控制UI](#6-版本控制ui)
7. [作品集导入对话框](#7-作品集导入对话框)

---

## 1. 顶部导航栏

### 1.1 布局规范

```
尺寸: 100% × 64px (固定高度)
位置: fixed, top: 0, z-index: 1000
背景: #FFFFFF
边框: border-bottom: 1px solid #E0E0E0
阴影: box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05)
```

### 1.2 内容结构

```
┌─────────────────────────────────────────────────────────────────┐
│ [Logo] Hero | Insight | Manifesto | ... [💾已保存] [预览] [分享] [👤] │
└─────────────────────────────────────────────────────────────────┘
```

**左侧区域 (Logo + 章节快速跳转)**
- Logo: 32px × 32px, margin-left: 24px
- 章节链接: 间距 16px, font-size: 14px, color: #2D2D2D
- 当前章节: color: #D4AF37, border-bottom: 2px solid #D4AF37

**右侧区域 (操作按钮)**
- 保存状态指示器: 显示"已保存"/"保存中"/"未保存"
- 预览按钮: 眼睛图标 + "预览"文字
- 分享按钮: 链接图标 + "分享"文字
- 用户菜单: 头像 + 下拉箭头

### 1.3 保存状态指示器

```css
/* 已保存 */
.save-status.saved {
  color: #4CAF50;
  display: flex;
  align-items: center;
  gap: 8px;
}
.save-status.saved::before {
  content: "✓";
  color: #4CAF50;
}

/* 保存中 */
.save-status.saving {
  color: #FF9800;
  animation: pulse 1.5s ease-in-out infinite;
}

/* 未保存 */
.save-status.unsaved {
  color: #9E9E9E;
}
```

### 1.4 章节快速跳转

```css
.chapter-nav {
  display: flex;
  gap: 16px;
  overflow-x: auto;
  scrollbar-width: none; /* 隐藏滚动条 */
}

.chapter-link {
  padding: 8px 12px;
  font-size: 14px;
  color: #2D2D2D;
  text-decoration: none;
  border-bottom: 2px solid transparent;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.chapter-link:hover {
  color: #D4AF37;
}

.chapter-link.active {
  color: #D4AF37;
  border-bottom-color: #D4AF37;
  font-weight: 600;
}
```

---

## 2. 左侧章节导航

### 2.1 布局规范

```
尺寸: 80px × 100vh (固定宽度)
位置: fixed, left: 0, top: 64px
背景: #F8F5F0
边框: border-right: 1px solid #E0E0E0
滚动: overflow-y: auto
```

### 2.2 章节缩略图

```css
.chapter-thumbnail {
  width: 64px;
  height: 64px;
  margin: 8px auto;
  border-radius: 8px;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  overflow: hidden;
}

.chapter-thumbnail:hover {
  border-color: #D4AF37;
  transform: scale(1.05);
}

.chapter-thumbnail.active {
  border-color: #D4AF37;
  box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.2);
}

/* 拖拽状态 */
.chapter-thumbnail.dragging {
  opacity: 0.5;
  cursor: grabbing;
}

.chapter-thumbnail.drag-over {
  border-color: #2196F3;
  background: rgba(33, 150, 243, 0.1);
}
```

### 2.3 添加按钮

```css
.add-chapter-btn {
  width: 64px;
  height: 64px;
  margin: 8px auto;
  border: 2px dashed #D4AF37;
  border-radius: 8px;
  background: transparent;
  color: #D4AF37;
  font-size: 24px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.add-chapter-btn:hover {
  background: rgba(212, 175, 55, 0.1);
  transform: scale(1.05);
}
```

### 2.4 拖拽排序

```javascript
// 拖拽手柄显示
.chapter-thumbnail:hover::before {
  content: "⋮⋮";
  position: absolute;
  top: 4px;
  left: 4px;
  color: #FFFFFF;
  background: rgba(0, 0, 0, 0.5);
  padding: 2px 4px;
  border-radius: 4px;
  font-size: 12px;
}
```

---

## 3. 中央画布区域

### 3.1 布局规范

```css
.canvas-area {
  margin-left: 80px;
  margin-right: 450px; /* 右侧面板宽度 */
  margin-top: 64px;
  background: #FFFFFF;
  min-height: calc(100vh - 64px);
  padding: 48px 64px;
}

/* 右侧面板收起时 */
.canvas-area.panel-collapsed {
  margin-right: 0;
}
```

### 3.2 模块容器

```css
.module-container {
  margin-bottom: 64px;
  position: relative;
  scroll-margin-top: 80px; /* 滚动时的顶部偏移 */
}

.module-container:last-child {
  margin-bottom: 0;
}

/* 模块悬停效果 */
.module-container:hover {
  outline: 2px dashed rgba(212, 175, 55, 0.3);
  outline-offset: 8px;
}

/* 当前编辑模块 */
.module-container.active {
  outline: 2px solid #D4AF37;
  outline-offset: 8px;
}
```

### 3.3 模块操作工具栏

```css
.module-toolbar {
  position: absolute;
  top: -40px;
  right: 0;
  display: flex;
  gap: 8px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.module-container:hover .module-toolbar {
  opacity: 1;
}

.module-toolbar button {
  width: 32px;
  height: 32px;
  border-radius: 4px;
  border: 1px solid #E0E0E0;
  background: #FFFFFF;
  color: #2D2D2D;
  cursor: pointer;
  transition: all 0.2s ease;
}

.module-toolbar button:hover {
  background: #F8F5F0;
  border-color: #D4AF37;
}
```

### 3.4 全屏滚动体验

```css
/* 平滑滚动 */
html {
  scroll-behavior: smooth;
}

/* 滚动条样式 */
.canvas-area::-webkit-scrollbar {
  width: 8px;
}

.canvas-area::-webkit-scrollbar-track {
  background: #F8F5F0;
}

.canvas-area::-webkit-scrollbar-thumb {
  background: #D4AF37;
  border-radius: 4px;
}

.canvas-area::-webkit-scrollbar-thumb:hover {
  background: #C19F2F;
}
```

---

## 4. 右侧编辑面板

### 4.1 布局规范

```css
.edit-panel {
  width: 450px;
  position: fixed;
  top: 64px;
  right: 0;
  bottom: 0;
  background: #FFFFFF;
  border-left: 1px solid #E0E0E0;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.05);
  overflow-y: auto;
  z-index: 900;
  transition: transform 0.3s ease;
}

/* 收起状态 */
.edit-panel.collapsed {
  transform: translateX(450px);
}
```

### 4.2 面板头部

```css
.panel-header {
  padding: 24px;
  border-bottom: 1px solid #E0E0E0;
  background: #F8F5F0;
  position: sticky;
  top: 0;
  z-index: 10;
}

.panel-title {
  font-size: 18px;
  font-weight: 600;
  color: #2D2D2D;
  margin-bottom: 8px;
}

.panel-subtitle {
  font-size: 14px;
  color: #9E9E9E;
}

/* 收起按钮 */
.collapse-btn {
  position: absolute;
  top: 24px;
  right: 24px;
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: #2D2D2D;
  cursor: pointer;
  transition: all 0.2s ease;
}

.collapse-btn:hover {
  color: #D4AF37;
  transform: scale(1.1);
}
```

### 4.3 表单控件

**输入框**
```css
.form-group {
  margin-bottom: 24px;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: #2D2D2D;
  margin-bottom: 8px;
}

.form-input {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  font-size: 14px;
  color: #2D2D2D;
  transition: all 0.2s ease;
}

.form-input:focus {
  outline: none;
  border-color: #D4AF37;
  box-shadow: 0 0 0 3px rgba(212, 175, 55, 0.1);
}
```

**文本域**
```css
.form-textarea {
  width: 100%;
  min-height: 120px;
  padding: 12px 16px;
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  font-size: 14px;
  color: #2D2D2D;
  resize: vertical;
  font-family: inherit;
}
```

**下拉选择**
```css
.form-select {
  width: 100%;
  padding: 12px 16px;
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  font-size: 14px;
  color: #2D2D2D;
  background: #FFFFFF;
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,..."); /* 下拉箭头 */
  background-repeat: no-repeat;
  background-position: right 12px center;
}
```

**复选框**
```css
.form-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.form-checkbox input[type="checkbox"] {
  width: 20px;
  height: 20px;
  border: 2px solid #E0E0E0;
  border-radius: 4px;
  cursor: pointer;
}

.form-checkbox input[type="checkbox"]:checked {
  background: #D4AF37;
  border-color: #D4AF37;
}
```

**滑块**
```css
.form-slider {
  width: 100%;
  height: 4px;
  border-radius: 2px;
  background: #E0E0E0;
  outline: none;
  appearance: none;
}

.form-slider::-webkit-slider-thumb {
  appearance: none;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  background: #D4AF37;
  cursor: pointer;
}
```

### 4.4 图片上传区域

```css
.image-upload {
  border: 2px dashed #E0E0E0;
  border-radius: 8px;
  padding: 24px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.image-upload:hover {
  border-color: #D4AF37;
  background: rgba(212, 175, 55, 0.05);
}

.image-upload.has-image {
  border-style: solid;
  padding: 0;
}

.image-preview {
  width: 100%;
  border-radius: 8px;
  overflow: hidden;
}

.image-actions {
  display: flex;
  gap: 8px;
  margin-top: 12px;
}
```

---

## 5. AI集成UI

### 5.1 AI按钮组

```css
.ai-actions {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #E0E0E0;
}

.ai-section-title {
  font-size: 14px;
  font-weight: 600;
  color: #2D2D2D;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.ai-section-title::before {
  content: "🤖";
  font-size: 18px;
}

.ai-button {
  width: 100%;
  padding: 12px 16px;
  margin-bottom: 8px;
  border: 1px solid #D4AF37;
  border-radius: 8px;
  background: linear-gradient(135deg, #D4AF37 0%, #C19F2F 100%);
  color: #FFFFFF;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.ai-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(212, 175, 55, 0.3);
}

.ai-button:active {
  transform: translateY(0);
}
```

### 5.2 AI生成对话框

```css
.ai-dialog {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 600px;
  max-height: 80vh;
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.2);
  z-index: 2000;
  overflow: hidden;
}

.ai-dialog-header {
  padding: 24px;
  border-bottom: 1px solid #E0E0E0;
  background: linear-gradient(135deg, #D4AF37 0%, #C19F2F 100%);
  color: #FFFFFF;
}

.ai-dialog-title {
  font-size: 20px;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 12px;
}

.ai-dialog-body {
  padding: 24px;
  max-height: 60vh;
  overflow-y: auto;
}

.ai-dialog-footer {
  padding: 24px;
  border-top: 1px solid #E0E0E0;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}
```

### 5.3 AI提供商选择

```css
.ai-provider-selector {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.provider-option {
  flex: 1;
  padding: 16px;
  border: 2px solid #E0E0E0;
  border-radius: 8px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.provider-option:hover {
  border-color: #D4AF37;
}

.provider-option.selected {
  border-color: #D4AF37;
  background: rgba(212, 175, 55, 0.1);
}

.provider-logo {
  width: 48px;
  height: 48px;
  margin: 0 auto 8px;
}

.provider-name {
  font-size: 14px;
  font-weight: 500;
  color: #2D2D2D;
}
```

### 5.4 AI生成进度

```css
.ai-progress {
  margin: 24px 0;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background: #E0E0E0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #D4AF37 0%, #C19F2F 100%);
  transition: width 0.3s ease;
  animation: shimmer 1.5s infinite;
}

@keyframes shimmer {
  0% { background-position: -200px 0; }
  100% { background-position: 200px 0; }
}

.progress-text {
  margin-top: 8px;
  font-size: 14px;
  color: #9E9E9E;
  text-align: center;
}
```

### 5.5 AI结果选择

```css
.ai-results {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-top: 24px;
}

.ai-result-card {
  padding: 16px;
  border: 2px solid #E0E0E0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.ai-result-card:hover {
  border-color: #D4AF37;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.ai-result-card.selected {
  border-color: #D4AF37;
  background: rgba(212, 175, 55, 0.05);
}

.ai-result-image {
  width: 100%;
  border-radius: 4px;
  margin-bottom: 12px;
}

.ai-result-text {
  font-size: 14px;
  color: #2D2D2D;
  line-height: 1.6;
}
```

---

## 6. 版本控制UI

### 6.1 版本历史面板

```css
.version-panel {
  position: fixed;
  top: 64px;
  right: 0;
  width: 400px;
  height: calc(100vh - 64px);
  background: #FFFFFF;
  border-left: 1px solid #E0E0E0;
  box-shadow: -2px 0 8px rgba(0, 0, 0, 0.05);
  z-index: 1100;
  transform: translateX(400px);
  transition: transform 0.3s ease;
}

.version-panel.open {
  transform: translateX(0);
}
```

### 6.2 版本列表

```css
.version-list {
  padding: 24px;
  overflow-y: auto;
  height: calc(100% - 80px);
}

.version-item {
  padding: 16px;
  margin-bottom: 12px;
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.version-item:hover {
  border-color: #D4AF37;
  background: rgba(212, 175, 55, 0.05);
}

.version-item.current {
  border-color: #D4AF37;
  background: rgba(212, 175, 55, 0.1);
}

.version-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.version-time {
  font-size: 14px;
  font-weight: 600;
  color: #2D2D2D;
}

.version-author {
  font-size: 12px;
  color: #9E9E9E;
}

.version-summary {
  font-size: 14px;
  color: #2D2D2D;
  margin-bottom: 8px;
}

.version-actions {
  display: flex;
  gap: 8px;
}

.version-action-btn {
  padding: 6px 12px;
  font-size: 12px;
  border: 1px solid #E0E0E0;
  border-radius: 4px;
  background: #FFFFFF;
  color: #2D2D2D;
  cursor: pointer;
  transition: all 0.2s ease;
}

.version-action-btn:hover {
  border-color: #D4AF37;
  color: #D4AF37;
}
```

### 6.3 版本对比视图

```css
.version-diff {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  padding: 24px;
}

.diff-column {
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  overflow: hidden;
}

.diff-header {
  padding: 12px 16px;
  background: #F8F5F0;
  font-size: 14px;
  font-weight: 600;
  color: #2D2D2D;
}

.diff-content {
  padding: 16px;
  max-height: 600px;
  overflow-y: auto;
}

.diff-added {
  background: rgba(76, 175, 80, 0.1);
  border-left: 3px solid #4CAF50;
  padding: 8px;
  margin: 4px 0;
}

.diff-removed {
  background: rgba(244, 67, 54, 0.1);
  border-left: 3px solid #F44336;
  padding: 8px;
  margin: 4px 0;
}
```

---

## 7. 作品集导入对话框

### 7.1 对话框布局

```css
.portfolio-import-dialog {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 800px;
  max-height: 90vh;
  background: #FFFFFF;
  border-radius: 16px;
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.2);
  z-index: 2000;
  overflow: hidden;
}

.dialog-header {
  padding: 24px;
  border-bottom: 1px solid #E0E0E0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dialog-title {
  font-size: 20px;
  font-weight: 600;
  color: #2D2D2D;
}

.dialog-close {
  width: 32px;
  height: 32px;
  border: none;
  background: transparent;
  color: #9E9E9E;
  cursor: pointer;
  font-size: 24px;
  transition: all 0.2s ease;
}

.dialog-close:hover {
  color: #2D2D2D;
}
```

### 7.2 章节选择列表

```css
.chapter-selection {
  padding: 24px;
  max-height: 50vh;
  overflow-y: auto;
}

.chapter-checkbox-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.chapter-checkbox-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.chapter-checkbox-item:hover {
  background: #F8F5F0;
  border-color: #D4AF37;
}

.chapter-checkbox-item input[type="checkbox"] {
  width: 20px;
  height: 20px;
}

.chapter-info {
  flex: 1;
}

.chapter-name {
  font-size: 16px;
  font-weight: 500;
  color: #2D2D2D;
  margin-bottom: 4px;
}

.chapter-badge {
  display: inline-block;
  padding: 4px 8px;
  font-size: 12px;
  border-radius: 4px;
  margin-left: 8px;
}

.badge-recommended {
  background: rgba(76, 175, 80, 0.1);
  color: #4CAF50;
}

.badge-optional {
  background: rgba(33, 150, 243, 0.1);
  color: #2196F3;
}

.badge-remove {
  background: rgba(244, 67, 54, 0.1);
  color: #F44336;
}
```

### 7.3 快速选择按钮

```css
.quick-select-buttons {
  display: flex;
  gap: 12px;
  padding: 16px 24px;
  background: #F8F5F0;
  border-top: 1px solid #E0E0E0;
  border-bottom: 1px solid #E0E0E0;
}

.quick-select-btn {
  padding: 8px 16px;
  font-size: 14px;
  border: 1px solid #E0E0E0;
  border-radius: 6px;
  background: #FFFFFF;
  color: #2D2D2D;
  cursor: pointer;
  transition: all 0.2s ease;
}

.quick-select-btn:hover {
  border-color: #D4AF37;
  color: #D4AF37;
}
```

### 7.4 预览区域

```css
.import-preview {
  padding: 24px;
  background: #F8F5F0;
}

.preview-section {
  margin-bottom: 16px;
}

.preview-title {
  font-size: 14px;
  font-weight: 600;
  color: #2D2D2D;
  margin-bottom: 8px;
}

.preview-list {
  font-size: 14px;
  color: #2D2D2D;
  line-height: 1.6;
}

.preview-list.kept {
  color: #4CAF50;
}

.preview-list.removed {
  color: #F44336;
  text-decoration: line-through;
}
```

### 7.5 作品信息表单

```css
.portfolio-info-form {
  padding: 24px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
  margin-bottom: 16px;
}
```

---

**文档版本**: 3.0
**最后更新**: 2026-02-04
**维护者**: 设计团队
