# 模块设计规范 V3.0

**版本**: 3.0
**更新日期**: 2026-02-04
**包含**: 12个核心模块的详细设计规范

---

## 1. Hero 模块

### 视觉规范
- 全屏布局: 100vw × 100vh
- 背景图片: 1920×1080px (最小)
- 遮罩层: rgba(0,0,0,0.3-0.5)
- 文字颜色: #FFFFFF
- 标题字号: 48px (桌面), 32px (移动)
- 副标题字号: 24px (桌面), 18px (移动)

### 布局结构
```
居中对齐 (默认)
- 标题: 中文 + 英文
- 副标题: 风格描述
- 客户名称: "为 XXX 设计"
- 按钮: CTA按钮
```

### 按钮样式
- 尺寸: padding 16px 48px
- 背景: transparent, border 2px solid #FFFFFF
- 悬停: background #FFFFFF, color #2D2D2D
- 圆角: 8px

---

## 2. Insight 模块

### 布局规范
- 两栏布局: 左文右图
- 比例选项: 40/60, 50/50, 60/40
- 间距: gap 48px
- 内边距: 64px

### 左侧文本区
- 标签: 大写英文, 12px, letter-spacing 0.08em
- 标题: 28px, font-weight 600
- 正文: 16px, line-height 1.8
- 颜色: #2D2D2D

### 右侧图片区
- 宽高比: 4:3 或 16:9
- 灰度滤镜: filter grayscale(100%) (可选)
- 圆角: 8px
- 悬停: 放大效果 scale(1.02)

---

## 3. Manifesto 模块

### 视觉规范
- 背景色: #2D2D2D
- 文字颜色: #FFFFFF
- 布局比例: 左30% 右70%
- 内边距: 80px

### 左侧文本
- 标签: 大写, 金色 #D4AF37
- 标题: 24px
- 正文: 18px, line-height 2.0
- 最大宽度: 400px

### 右侧图片
- 大尺寸展示
- 圆角: 0 (保持锐利边缘)
- 对象适配: cover

---

## 4. Floorplan 模块

### 切换按钮
- 位置: 图片上方居中
- 样式: 标签页式
- 尺寸: padding 12px 32px
- 激活状态: background #D4AF37, color #FFFFFF

### 图片展示
- 容器: 固定高度 600px
- 过渡效果:
  - 淡入淡出: opacity transition 0.5s
  - 左右滑动: translateX transition 0.5s
  - 上下滑动: translateY transition 0.5s

### 说明文字
- 位置: 图片下方
- 字号: 14px
- 颜色: #9E9E9E
- 对齐: 居中

---

## 5. Storage 模块

### 网格布局
- 2列: grid-template-columns repeat(2, 1fr)
- 3列: grid-template-columns repeat(3, 1fr)
- 间距: gap 24px

### 区域卡片
- 背景: #FFFFFF
- 边框: 1px solid #E0E0E0
- 圆角: 12px
- 内边距: 24px
- 阴影: 0 2px 8px rgba(0,0,0,0.1)

### 卡片内容
- 图片: 宽高比 4:3, 圆角 8px
- 区域名称: 18px, font-weight 600
- 体积显示: 24px, color #D4AF37
- 功能说明: 14px, line-height 1.6

---

## 6. Rendering 模块

### 主图布局
- 宽度: 70%
- 高度: 自适应
- 位置: 相对定位

### 热点标记
- 尺寸: 24px × 24px
- 背景: #D4AF37
- 边框: 2px solid #FFFFFF
- 圆角: 50%
- 动画: pulse 2s infinite

### 热点悬停卡片
- 背景: #FFFFFF
- 阴影: 0 4px 16px rgba(0,0,0,0.15)
- 圆角: 8px
- 内边距: 16px
- 最大宽度: 280px

### 侧边栏清单
- 宽度: 30%
- 背景: #F8F5F0
- 内边距: 24px
- 项目间距: 16px

---

## 7. Gallery 模块

### 分类标签
- 布局: flex, gap 16px
- 样式: padding 8px 20px
- 默认: background transparent, border 1px solid #E0E0E0
- 激活: background #D4AF37, color #FFFFFF

### 网格布局
- 2列: grid-template-columns repeat(2, 1fr)
- 3列: grid-template-columns repeat(3, 1fr)
- 4列: grid-template-columns repeat(4, 1fr)
- 间距: gap 24px

### 图片卡片
- 宽高比: 16:9
- 圆角: 8px
- 悬停: transform translateY(-4px), shadow增强
- 过渡: all 0.3s ease

### 灯箱效果
- 背景: rgba(0,0,0,0.9)
- 图片: 最大90vw × 90vh
- 关闭按钮: 右上角, 48px × 48px

---

## 8. Moodboard 模块

### 色板区域
- 布局: flex, gap 12px
- 色块尺寸: 80px × 80px
- 圆角: 8px
- 边框: 1px solid #E0E0E0

### 色块信息
- 色值: 12px, 等宽字体
- 名称: 14px, 居中对齐
- 位置: 色块下方

### 参考图片
- 不对称布局: CSS Grid
- 尺寸变化: 小(1fr), 中(1.5fr), 大(2fr)
- 间距: gap 16px
- 圆角: 8px

### 图片透明度
- 范围: 0-100%
- 控制: 滑块
- 实时预览: opacity属性

---

## 9. Technical 模块

### 单栏布局
- 最大宽度: 800px
- 居中对齐
- 内边距: 48px

### 双栏布局
- 比例: 1:1
- 间距: gap 48px
- 响应式: 移动端堆叠

### 文本样式
- 标题: 20px, font-weight 600, margin-bottom 16px
- 正文: 16px, line-height 1.8
- 列表: 左侧圆点, 缩进 24px
- 列表项间距: 8px

### 表格样式
- 边框: 1px solid #E0E0E0
- 表头: background #F8F5F0, font-weight 600
- 单元格: padding 12px 16px
- 斑马纹: nth-child(even) background #FAFAFA

---

## 10. Delivery 模块

### 阶段卡片
- 背景: #FFFFFF
- 边框: 1px solid #E0E0E0
- 圆角: 12px
- 内边距: 24px
- 间距: margin-bottom 24px

### 阶段标题
- 字号: 20px
- 颜色: #2D2D2D
- 粗细: font-weight 600
- 图标: 左侧数字徽章

### 周期显示
- 字号: 16px
- 颜色: #D4AF37
- 位置: 标题右侧
- 样式: badge

### 内容清单
- 列表样式: 复选框图标
- 字号: 14px
- 行高: 1.8
- 颜色: #2D2D2D

### 时间线可视化
- 左侧竖线: 2px solid #D4AF37
- 节点: 12px圆点
- 连接线: 虚线

---

## 11. Quotation 模块

### 表格设计
- 宽度: 100%
- 边框: 1px solid #E0E0E0
- 圆角: 8px (外层容器)
- 背景: #FFFFFF

### 表头
- 背景: #F8F5F0
- 字号: 14px
- 粗细: font-weight 600
- 颜色: #2D2D2D
- 内边距: 16px

### 表格行
- 内边距: 12px 16px
- 边框: border-bottom 1px solid #E0E0E0
- 悬停: background #FAFAFA

### 价格显示
- 字号: 16px
- 颜色: #2D2D2D
- 对齐: 右对齐
- 格式: ¥X,XXX

### 总计区域
- 背景: #F8F5F0
- 字号: 18px
- 粗细: font-weight 700
- 颜色: #D4AF37
- 内边距: 24px

### 备注区域
- 字号: 14px
- 颜色: #9E9E9E
- 行高: 1.6
- 内边距: 16px

---

## 12. Ending 模块

### 全屏布局
- 高度: 100vh
- 对齐: 居中
- 背景: 纯色或图片

### 文字层级
- 主标题: 36px, font-weight 600
- 英文标题: 24px, font-weight 400
- 副标题: 20px
- 公司信息: 16px, line-height 2.0

### 二维码
- 尺寸: 120px × 120px
- 间距: gap 32px
- 标签: 12px, 居中对齐
- 布局: flex, 水平排列

### 联系信息
- 图标: 20px, 左对齐
- 文字: 16px
- 间距: 每项 margin-bottom 12px
- 颜色: #2D2D2D (浅色背景) / #FFFFFF (深色背景)

---

## 响应式适配

### 移动端 (<768px)
- Hero: 标题 32px, 副标题 18px
- Insight/Manifesto: 单栏堆叠
- Floorplan: 按钮缩小, 图片高度 400px
- Storage: 单列布局
- Rendering: 侧边栏移至底部
- Gallery: 单列或双列
- Moodboard: 色板滚动, 图片单列
- Technical: 单栏
- Delivery: 卡片全宽
- Quotation: 表格横向滚动
- Ending: 二维码垂直排列

### 平板端 (768-1023px)
- 保持桌面布局
- 字号略微缩小
- 间距适当减少
- 图片尺寸优化

---

**文档版本**: 3.0
**最后更新**: 2026-02-04
**维护者**: 设计团队
