# 交互模式规范 V3.0

**版本**: 3.0
**更新日期**: 2026-02-04
**适用范围**: 提案编辑器所有交互行为

---

## 1. 拖拽交互

### 1.1 模块拖拽排序

**触发方式**
- 鼠标: 点击章节缩略图并拖动
- 触摸: 长按章节缩略图1秒后拖动

**视觉反馈**
```css
/* 拖拽开始 */
.dragging {
  opacity: 0.6;
  transform: scale(1.05);
  cursor: grabbing;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  z-index: 1000;
}

/* 拖拽目标区域 */
.drag-over {
  border: 2px dashed #D4AF37;
  background: rgba(212, 175, 55, 0.1);
}

/* 插入指示器 */
.drop-indicator {
  height: 4px;
  background: #D4AF37;
  border-radius: 2px;
  animation: pulse 1s infinite;
}
```

**交互流程**
1. 用户点击并按住章节缩略图
2. 缩略图变为半透明并跟随鼠标
3. 其他章节显示可放置区域
4. 悬停时显示插入位置指示器
5. 释放鼠标完成排序
6. 播放平滑的重排动画

**动画效果**
```css
.chapter-reorder {
  transition: transform 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
}
```

---

## 2. 自动保存反馈

### 2.1 保存状态指示

**状态类型**
- 未保存 (Unsaved): 有未保存的更改
- 保存中 (Saving): 正在保存
- 已保存 (Saved): 所有更改已保存
- 保存失败 (Failed): 保存出错

**视觉设计**
```css
/* 未保存 */
.save-status.unsaved {
  color: #9E9E9E;
}
.save-status.unsaved::before {
  content: "●";
  color: #FF9800;
  margin-right: 8px;
}

/* 保存中 */
.save-status.saving {
  color: #2196F3;
  animation: pulse 1.5s ease-in-out infinite;
}
.save-status.saving::before {
  content: "⟳";
  animation: spin 1s linear infinite;
}

/* 已保存 */
.save-status.saved {
  color: #4CAF50;
}
.save-status.saved::before {
  content: "✓";
  margin-right: 8px;
}

/* 保存失败 */
.save-status.failed {
  color: #F44336;
  cursor: pointer;
}
.save-status.failed::before {
  content: "⚠";
  margin-right: 8px;
}
```

### 2.2 自动保存机制

**防抖策略**
- 用户停止输入后3秒触发保存
- 增量更新，只保存变更的字段
- 后台静默保存，不打断用户操作

**保存动画**
```css
@keyframes save-flash {
  0% { background: transparent; }
  50% { background: rgba(76, 175, 80, 0.1); }
  100% { background: transparent; }
}

.field-saved {
  animation: save-flash 0.5s ease;
}
```

---

## 3. AI生成流程

### 3.1 AI对话框打开

**触发方式**
- 点击右侧面板的AI按钮
- 键盘快捷键: Cmd/Ctrl + K

**打开动画**
```css
@keyframes dialog-appear {
  from {
    opacity: 0;
    transform: translate(-50%, -48%) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translate(-50%, -50%) scale(1);
  }
}

.ai-dialog {
  animation: dialog-appear 0.3s cubic-bezier(0.4, 0.0, 0.2, 1);
}
```

### 3.2 生成过程

**步骤流程**
1. 选择AI提供商和模型
2. 输入提示词或选择预设
3. 点击"生成"按钮
4. 显示进度条和预计时间
5. 展示生成结果（多个选项）
6. 选择并应用结果

**加载状态**
```css
.ai-generating {
  position: relative;
  pointer-events: none;
}

.ai-generating::after {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 进度条动画 */
@keyframes progress-shimmer {
  0% { background-position: -200px 0; }
  100% { background-position: 200px 0; }
}
```

### 3.3 结果选择

**交互方式**
- 单选: 点击卡片选中
- 预览: 悬停显示大图
- 对比: 并排查看多个结果
- 重新生成: 不满意可重新生成

**选中效果**
```css
.ai-result-card.selected {
  border: 2px solid #D4AF37;
  background: rgba(212, 175, 55, 0.05);
  transform: scale(1.02);
}

.ai-result-card.selected::after {
  content: "✓";
  position: absolute;
  top: 8px;
  right: 8px;
  width: 24px;
  height: 24px;
  background: #D4AF37;
  color: #FFFFFF;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}
```

---

## 4. 版本控制交互

### 4.1 版本历史浏览

**打开方式**
- 点击顶部导航的"历史"按钮
- 从右侧滑入版本面板

**滑入动画**
```css
@keyframes slide-in-right {
  from {
    transform: translateX(100%);
  }
  to {
    transform: translateX(0);
  }
}

.version-panel.open {
  animation: slide-in-right 0.3s ease;
}
```

### 4.2 版本对比

**对比视图**
- 左右分栏显示两个版本
- 高亮显示差异部分
- 支持滚动同步

**差异高亮**
```css
.diff-added {
  background: rgba(76, 175, 80, 0.2);
  border-left: 3px solid #4CAF50;
  padding: 4px 8px;
  margin: 2px 0;
}

.diff-removed {
  background: rgba(244, 67, 54, 0.2);
  border-left: 3px solid #F44336;
  padding: 4px 8px;
  margin: 2px 0;
  text-decoration: line-through;
}

.diff-modified {
  background: rgba(255, 152, 0, 0.2);
  border-left: 3px solid #FF9800;
  padding: 4px 8px;
  margin: 2px 0;
}
```

### 4.3 版本回滚

**确认对话框**
```
标题: 确认回滚到此版本？
内容: 当前未保存的更改将会丢失。此操作会创建一个新的版本快照。
按钮: [取消] [确认回滚]
```

**回滚动画**
```css
@keyframes rollback-flash {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.rolling-back {
  animation: rollback-flash 0.5s ease 3;
}
```

---

## 5. 模块添加流程

### 5.1 添加按钮交互

**悬停效果**
```css
.add-chapter-btn:hover {
  background: rgba(212, 175, 55, 0.1);
  transform: scale(1.05) rotate(90deg);
  transition: all 0.3s ease;
}
```

### 5.2 模块选择菜单

**打开动画**
```css
@keyframes menu-expand {
  from {
    opacity: 0;
    transform: translateY(-10px) scale(0.95);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.module-menu {
  animation: menu-expand 0.2s ease;
}
```

**模块项悬停**
```css
.module-menu-item {
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.module-menu-item:hover {
  background: rgba(212, 175, 55, 0.1);
  padding-left: 24px;
}
```

### 5.3 插入位置指示

**插入点动画**
```css
.insertion-point {
  height: 4px;
  background: #D4AF37;
  margin: 16px 0;
  animation: pulse-width 1s ease-in-out infinite;
}

@keyframes pulse-width {
  0%, 100% { width: 100%; }
  50% { width: 80%; margin-left: 10%; }
}
```

---

## 6. 热点编辑交互

### 6.1 添加热点

**交互流程**
1. 点击"添加热点"按钮
2. 鼠标变为十字准星
3. 点击图片上的位置
4. 显示热点标记和编辑表单
5. 填写热点信息
6. 保存热点

**准星光标**
```css
.hotspot-mode {
  cursor: crosshair;
}

.hotspot-mode::after {
  content: "点击图片添加热点";
  position: fixed;
  bottom: 24px;
  left: 50%;
  transform: translateX(-50%);
  padding: 12px 24px;
  background: rgba(0, 0, 0, 0.8);
  color: #FFFFFF;
  border-radius: 8px;
  font-size: 14px;
  pointer-events: none;
}
```

### 6.2 拖动热点位置

**拖动交互**
```css
.hotspot-marker {
  cursor: move;
  transition: transform 0.2s ease;
}

.hotspot-marker:hover {
  transform: scale(1.2);
  z-index: 10;
}

.hotspot-marker.dragging {
  transform: scale(1.3);
  box-shadow: 0 4px 12px rgba(212, 175, 55, 0.5);
}
```

### 6.3 热点悬停提示

**提示卡片动画**
```css
.hotspot-tooltip {
  opacity: 0;
  transform: translateY(10px);
  transition: all 0.2s ease;
  pointer-events: none;
}

.hotspot-marker:hover + .hotspot-tooltip {
  opacity: 1;
  transform: translateY(0);
  pointer-events: auto;
}
```

---

## 7. 图片上传管理

### 7.1 拖拽上传

**拖拽区域**
```css
.upload-zone {
  border: 2px dashed #E0E0E0;
  transition: all 0.2s ease;
}

.upload-zone.drag-over {
  border-color: #D4AF37;
  background: rgba(212, 175, 55, 0.05);
}

.upload-zone.drag-over::before {
  content: "释放以上传";
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 18px;
  color: #D4AF37;
  font-weight: 600;
}
```

### 7.2 上传进度

**进度条**
```css
.upload-progress {
  position: relative;
  height: 4px;
  background: #E0E0E0;
  border-radius: 2px;
  overflow: hidden;
}

.upload-progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #D4AF37, #C19F2F);
  transition: width 0.3s ease;
}

/* 上传完成动画 */
@keyframes upload-complete {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

.upload-complete {
  animation: upload-complete 0.5s ease;
}
```

### 7.3 图片预览

**灯箱效果**
```css
.lightbox {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  z-index: 3000;
  display: flex;
  align-items: center;
  justify-content: center;
  animation: fade-in 0.3s ease;
}

.lightbox-image {
  max-width: 90vw;
  max-height: 90vh;
  animation: zoom-in 0.3s ease;
}

@keyframes zoom-in {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
```

---

## 8. 响应式触摸交互

### 8.1 移动端手势

**滑动切换章节**
```javascript
// 左滑: 下一章节
// 右滑: 上一章节
// 最小滑动距离: 50px
// 滑动速度阈值: 0.3px/ms
```

**双指缩放**
```javascript
// 画布区域支持双指缩放
// 缩放范围: 50% - 200%
// 缩放中心: 双指中点
```

### 8.2 触摸目标优化

**最小触摸尺寸**
```css
.touch-target {
  min-width: 44px;
  min-height: 44px;
  padding: 12px;
}

/* 触摸反馈 */
.touch-target:active {
  background: rgba(212, 175, 55, 0.1);
  transform: scale(0.95);
}
```

### 8.3 长按菜单

**长按触发**
```javascript
// 长按时间: 500ms
// 触发后震动反馈 (如果支持)
// 显示上下文菜单
```

**菜单动画**
```css
@keyframes context-menu-appear {
  from {
    opacity: 0;
    transform: scale(0.8);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.context-menu {
  animation: context-menu-appear 0.2s ease;
}
```

---

## 9. 键盘快捷键

### 9.1 全局快捷键

```
Cmd/Ctrl + S: 手动保存
Cmd/Ctrl + Z: 撤销
Cmd/Ctrl + Shift + Z: 重做
Cmd/Ctrl + K: 打开AI助手
Cmd/Ctrl + P: 预览
Cmd/Ctrl + /: 显示快捷键列表
Esc: 关闭对话框/取消操作
```

### 9.2 编辑器快捷键

```
Cmd/Ctrl + D: 复制当前模块
Cmd/Ctrl + Delete: 删除当前模块
Cmd/Ctrl + ↑/↓: 移动模块位置
Tab: 切换到下一个输入框
Shift + Tab: 切换到上一个输入框
```

### 9.3 快捷键提示

**提示浮层**
```css
.shortcut-hint {
  position: fixed;
  bottom: 24px;
  right: 24px;
  padding: 16px;
  background: rgba(0, 0, 0, 0.9);
  color: #FFFFFF;
  border-radius: 8px;
  font-size: 14px;
  animation: slide-up 0.3s ease;
}

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
```

---

## 10. 错误处理交互

### 10.1 表单验证

**实时验证**
```css
.form-input.error {
  border-color: #F44336;
  animation: shake 0.3s ease;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-8px); }
  75% { transform: translateX(8px); }
}

.error-message {
  color: #F44336;
  font-size: 12px;
  margin-top: 4px;
  animation: fade-in 0.2s ease;
}
```

### 10.2 网络错误

**重试机制**
```css
.retry-button {
  padding: 8px 16px;
  background: #FF9800;
  color: #FFFFFF;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  animation: pulse 2s ease-in-out infinite;
}
```

### 10.3 成功反馈

**成功提示**
```css
.success-toast {
  position: fixed;
  top: 80px;
  right: 24px;
  padding: 16px 24px;
  background: #4CAF50;
  color: #FFFFFF;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  animation: toast-appear 0.3s ease;
}

@keyframes toast-appear {
  from {
    opacity: 0;
    transform: translateX(100%);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}
```

---

**文档版本**: 3.0
**最后更新**: 2026-02-04
**维护者**: 设计团队
