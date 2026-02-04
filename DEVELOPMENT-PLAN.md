# 方案汇报系统 - 开发执行计划

## 项目信息

- **项目名称**: 方案汇报系统 (Proposal Presentation System)
- **目标市场**: 中国大陆设计公司、全屋定制公司、软装公司
- **代码标准**: 工业级代码质量
- **开发模式**: 分阶段批次验收

## Git 分支策略

### 主要分支

1. **main** - 生产分支
   - 只接受来自 `develop` 的合并
   - 每次合并打标签 (v1.0.0, v1.1.0, etc.)
   - 受保护，需要 PR 审核

2. **develop** - 开发主分支
   - 集成所有功能分支
   - 每个阶段完成后合并到 main
   - 日常开发基准分支

### 功能分支命名规范

- **后端基础设施**: `feature/backend-infrastructure`
- **后端核心功能**: `feature/backend-core-features`
- **AI集成服务**: `feature/ai-integration`
- **前端框架**: `feature/frontend-framework`
- **前端编辑器**: `feature/frontend-editor`
- **前端AI集成**: `feature/frontend-ai`
- **其他功能**: `feature/portfolio-templates-appointments`
- **测试优化**: `feature/testing-optimization`

### 提交信息规范

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Type 类型**:
- `feat`: 新功能
- `fix`: Bug修复
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `test`: 测试相关
- `chore`: 构建/工具配置

**示例**:
```
feat(auth): implement JWT authentication with RBAC

- Add JWT token generation and validation
- Implement role-based access control
- Add refresh token mechanism
- Add unit tests for auth service

Closes #123
```

## 开发阶段划分

### 批次 1: 后端基础设施 (Phase 1)

**目标**: 搭建后端核心基础设施，为所有功能提供基础支撑

**分支**: `feature/backend-infrastructure`

**工作内容**:

1. **项目初始化**
   - [ ] 创建 Nest.js 项目结构
   - [ ] 配置 TypeScript (strict mode)
   - [ ] 配置 ESLint + Prettier
   - [ ] 配置环境变量管理 (.env)
   - [ ] 配置 Docker Compose (PostgreSQL + Redis)

2. **数据库设置**
   - [ ] 配置 TypeORM/Prisma
   - [ ] 创建数据库迁移系统
   - [ ] 执行初始数据库 schema (50+ tables)
   - [ ] 配置数据库连接池
   - [ ] 添加数据库健康检查

3. **认证授权系统**
   - [ ] 实现 JWT 认证 (access + refresh token)
   - [ ] 实现 RBAC 权限系统 (Admin/Editor/Viewer)
   - [ ] 创建认证守卫 (Guards)
   - [ ] 创建权限装饰器 (Decorators)
   - [ ] 添加认证中间件
   - [ ] 单元测试 (覆盖率 > 80%)

4. **核心基础设施**
   - [ ] 全局异常过滤器
   - [ ] 请求日志中间件 (Winston/Pino)
   - [ ] DTO 验证管道 (class-validator)
   - [ ] 响应拦截器 (统一响应格式)
   - [ ] 健康检查端点 (/health)
   - [ ] API 文档 (Swagger/OpenAPI)

5. **Redis 缓存层**
   - [ ] 配置 Redis 连接
   - [ ] 创建缓存服务抽象
   - [ ] 实现缓存装饰器
   - [ ] 配置缓存策略 (TTL, invalidation)

**验收标准**:
- ✅ 所有测试通过 (覆盖率 > 80%)
- ✅ API 文档自动生成
- ✅ Docker Compose 一键启动
- ✅ 健康检查端点正常
- ✅ 认证授权功能完整
- ✅ 代码通过 ESLint 检查

**预计时间**: 3-4天

---

### 批次 2: 后端核心功能 (Phase 2)

**目标**: 实现提案管理、模块系统、自动保存、版本控制

**分支**: `feature/backend-core-features`

**依赖**: 批次 1 完成

**工作内容**:

1. **提案 CRUD API**
   - [ ] 提案创建 (POST /proposals)
   - [ ] 提案列表 (GET /proposals)
   - [ ] 提案详情 (GET /proposals/:id)
   - [ ] 提案更新 (PUT /proposals/:id)
   - [ ] 提案删除 (DELETE /proposals/:id)
   - [ ] 提案分享设置 (POST /proposals/:id/share)
   - [ ] 提案权限检查
   - [ ] 单元测试 + 集成测试

2. **模块管理 API (12种模块)**
   - [ ] Hero 模块 CRUD
   - [ ] Insight 模块 CRUD
   - [ ] Manifesto 模块 CRUD
   - [ ] Floorplan 模块 CRUD
   - [ ] Storage 模块 CRUD
   - [ ] Rendering 模块 CRUD
   - [ ] Gallery 模块 CRUD
   - [ ] Moodboard 模块 CRUD
   - [ ] Technical 模块 CRUD
   - [ ] Delivery 模块 CRUD
   - [ ] Quotation 模块 CRUD
   - [ ] Ending 模块 CRUD
   - [ ] 模块排序 API
   - [ ] 模块复制 API

3. **自动保存服务**
   - [ ] 实现防抖保存 (3-5秒)
   - [ ] 增量更新机制
   - [ ] 保存状态追踪
   - [ ] 冲突检测
   - [ ] 自动保存 API (POST /proposals/:id/autosave)
   - [ ] 单元测试

4. **版本控制系统**
   - [ ] 版本快照创建
   - [ ] 版本差异计算 (diff)
   - [ ] 版本历史列表 (GET /proposals/:id/versions)
   - [ ] 版本对比 (GET /proposals/:id/versions/compare)
   - [ ] 版本回滚 (POST /proposals/:id/versions/:versionId/restore)
   - [ ] 版本元数据管理
   - [ ] 单元测试 + 集成测试

5. **文件上传服务**
   - [ ] 配置阿里云 OSS
   - [ ] 图片上传 API
   - [ ] 文件类型验证
   - [ ] 文件大小限制
   - [ ] 图片压缩和优化
   - [ ] 单元测试

**验收标准**:
- ✅ 所有 API 端点正常工作
- ✅ 自动保存功能稳定 (3-5秒防抖)
- ✅ 版本控制功能完整 (创建/对比/回滚)
- ✅ 12种模块全部支持
- ✅ 测试覆盖率 > 80%
- ✅ API 响应时间 < 500ms (P95)

**预计时间**: 5-6天

---

### 批次 3: AI 集成服务 (Phase 3)

**目标**: 集成 OpenAI、Claude、Gemini，实现统一 AI 服务层

**分支**: `feature/ai-integration`

**依赖**: 批次 2 完成

**工作内容**:

1. **AI 服务抽象层**
   - [ ] 定义统一 AI 服务接口
   - [ ] 实现策略模式 (多供应商切换)
   - [ ] 实现工厂模式 (AI 客户端创建)
   - [ ] 配置管理 (API Keys, OAuth2)
   - [ ] 单元测试

2. **OpenAI 集成**
   - [ ] GPT-4 文案生成
   - [ ] DALL-E 图像生成
   - [ ] API Key 认证
   - [ ] OAuth2 认证流程
   - [ ] 错误处理和重试
   - [ ] 单元测试

3. **Claude 集成**
   - [ ] Claude API 文案生成
   - [ ] API Key 认证
   - [ ] 错误处理和重试
   - [ ] 单元测试

4. **Gemini 集成**
   - [ ] Gemini API 文案生成
   - [ ] Gemini 图像生成
   - [ ] API Key 认证
   - [ ] 错误处理和重试
   - [ ] 单元测试

5. **AI 功能 API**
   - [ ] 12个模块的 AI 生成端点
   - [ ] 使用限额管理
   - [ ] 生成历史记录
   - [ ] Token 计数
   - [ ] 异步任务队列 (Bull)
   - [ ] Webhook 回调
   - [ ] 集成测试

6. **AI 使用统计**
   - [ ] 使用次数追踪
   - [ ] 成本计算
   - [ ] 限额告警
   - [ ] 统计报表

**验收标准**:
- ✅ 三个 AI 供应商全部集成
- ✅ 统一接口可切换供应商
- ✅ 12个模块全部支持 AI 生成
- ✅ 错误处理和重试机制完善
- ✅ 使用限额管理正常
- ✅ 测试覆盖率 > 80%

**预计时间**: 4-5天

---

### 批次 4: 前端核心框架 (Phase 4)

**目标**: 搭建 Next.js 前端框架，配置路由、状态管理、API 客户端

**分支**: `feature/frontend-framework`

**依赖**: 批次 1-3 完成

**工作内容**:

1. **项目初始化**
   - [ ] 创建 Next.js 14+ 项目 (App Router)
   - [ ] 配置 TypeScript (strict mode)
   - [ ] 配置 Tailwind CSS
   - [ ] 配置 ESLint + Prettier
   - [ ] 配置环境变量

2. **设计系统集成**
   - [ ] 创建设计 tokens (colors, spacing, typography)
   - [ ] 创建基础组件库 (Button, Input, Modal, etc.)
   - [ ] 配置 Framer Motion
   - [ ] 创建主题系统
   - [ ] Storybook 配置 (可选)

3. **路由结构**
   - [ ] 登录页 (/login)
   - [ ] 主布局 (sidebar + header)
   - [ ] 提案列表 (/proposals)
   - [ ] 提案编辑器 (/proposals/:id/edit)
   - [ ] 作品集 (/portfolio)
   - [ ] 模板库 (/templates)
   - [ ] 预约管理 (/appointments)
   - [ ] 日历 (/calendar)
   - [ ] 设置 (/settings)

4. **状态管理 (Zustand)**
   - [ ] 认证 store (auth, user, permissions)
   - [ ] 提案 store (proposals, currentProposal)
   - [ ] 自动保存 store (saveStatus, lastSaved)
   - [ ] 版本控制 store (versions, currentVersion)
   - [ ] AI store (providers, models, usage)
   - [ ] UI store (sidebar, modals, notifications)

5. **API 客户端**
   - [ ] Axios 配置 (baseURL, interceptors)
   - [ ] 认证拦截器 (JWT token)
   - [ ] 错误处理拦截器
   - [ ] React Query 配置
   - [ ] API hooks (useProposals, useModules, etc.)
   - [ ] 类型定义 (TypeScript interfaces)

6. **认证流程**
   - [ ] 登录页面
   - [ ] 注册页面
   - [ ] 忘记密码
   - [ ] 受保护路由
   - [ ] 权限检查组件

**验收标准**:
- ✅ Next.js 项目正常运行
- ✅ 所有路由配置完成
- ✅ 状态管理正常工作
- ✅ API 客户端可调用后端
- ✅ 认证流程完整
- ✅ 设计系统组件可用
- ✅ 代码通过 ESLint 检查

**预计时间**: 3-4天

---

### 批次 5: 前端编辑器实现 (Phase 5)

**目标**: 实现三面板提案编辑器，支持12种模块、自动保存、版本控制

**分支**: `feature/frontend-editor`

**依赖**: 批次 4 完成

**工作内容**:

1. **编辑器布局**
   - [ ] 顶部导航栏 (64px, 固定)
   - [ ] 左侧章节导航 (80px, 固定)
   - [ ] 中央画布区域 (全屏滚动)
   - [ ] 右侧编辑面板 (450px, 可收起)
   - [ ] 响应式适配

2. **12种模块组件 (Canvas 显示)**
   - [ ] Hero 模块
   - [ ] Insight 模块
   - [ ] Manifesto 模块
   - [ ] Floorplan 模块
   - [ ] Storage 模块
   - [ ] Rendering 模块
   - [ ] Gallery 模块
   - [ ] Moodboard 模块
   - [ ] Technical 模块
   - [ ] Delivery 模块
   - [ ] Quotation 模块
   - [ ] Ending 模块

3. **12种模块编辑面板**
   - [ ] Hero 编辑面板
   - [ ] Insight 编辑面板
   - [ ] Manifesto 编辑面板
   - [ ] Floorplan 编辑面板
   - [ ] Storage 编辑面板
   - [ ] Rendering 编辑面板
   - [ ] Gallery 编辑面板
   - [ ] Moodboard 编辑面板
   - [ ] Technical 编辑面板
   - [ ] Delivery 编辑面板
   - [ ] Quotation 编辑面板
   - [ ] Ending 编辑面板

4. **自动保存功能**
   - [ ] 3-5秒防抖保存
   - [ ] 保存状态指示器
   - [ ] 乐观更新 UI
   - [ ] 冲突检测提示
   - [ ] 离线保存队列

5. **版本控制 UI**
   - [ ] 版本历史面板
   - [ ] 版本对比视图
   - [ ] 版本回滚确认
   - [ ] 版本元数据显示

6. **模块管理功能**
   - [ ] 添加模块 (分类菜单)
   - [ ] 删除模块
   - [ ] 拖拽排序
   - [ ] 复制模块
   - [ ] 模块搜索

7. **交互功能**
   - [ ] 键盘快捷键
   - [ ] 撤销/重做
   - [ ] 拖拽上传图片
   - [ ] 图片裁剪
   - [ ] 富文本编辑器

**验收标准**:
- ✅ 三面板布局完整
- ✅ 12种模块全部实现
- ✅ 自动保存稳定 (3-5秒)
- ✅ 版本控制功能正常
- ✅ 模块管理功能完整
- ✅ 交互流畅无卡顿
- ✅ 响应式设计良好

**预计时间**: 7-8天

---

### 批次 6: 前端 AI 集成 (Phase 6)

**目标**: 在编辑器中集成 AI 功能，支持所有12个模块

**分支**: `feature/frontend-ai`

**依赖**: 批次 5 完成

**工作内容**:

1. **AI 设置页面**
   - [ ] AI 供应商选择
   - [ ] API Key 配置
   - [ ] OAuth2 认证流程
   - [ ] 模型选择
   - [ ] 使用限额显示

2. **AI 生成对话框**
   - [ ] 通用生成对话框组件
   - [ ] 提示词输入
   - [ ] 生成参数配置
   - [ ] 生成进度显示
   - [ ] 多版本结果展示
   - [ ] 结果选择和应用

3. **12个模块的 AI 集成**
   - [ ] Hero 模块 AI 按钮
   - [ ] Insight 模块 AI 按钮
   - [ ] Manifesto 模块 AI 按钮
   - [ ] Floorplan 模块 AI 按钮
   - [ ] Storage 模块 AI 按钮
   - [ ] Rendering 模块 AI 按钮
   - [ ] Gallery 模块 AI 按钮
   - [ ] Moodboard 模块 AI 按钮
   - [ ] Technical 模块 AI 按钮
   - [ ] Delivery 模块 AI 按钮
   - [ ] Quotation 模块 AI 按钮
   - [ ] Ending 模块 AI 按钮

4. **AI 使用历史**
   - [ ] 历史记录列表
   - [ ] 历史记录搜索
   - [ ] 收藏功能
   - [ ] 重新应用历史结果

5. **AI 反馈机制**
   - [ ] 结果评分
   - [ ] 问题反馈
   - [ ] 优化建议

**验收标准**:
- ✅ AI 设置页面完整
- ✅ 12个模块全部支持 AI
- ✅ 生成流程流畅
- ✅ 错误处理完善
- ✅ 使用历史功能正常
- ✅ 反馈机制可用

**预计时间**: 4-5天

---

### 批次 7: 其他功能模块 (Phase 7)

**目标**: 实现作品集、模板、预约、日历等功能

**分支**: `feature/portfolio-templates-appointments`

**依赖**: 批次 6 完成

**工作内容**:

1. **作品集管理**
   - [ ] 作品集列表页
   - [ ] 作品集详情页
   - [ ] 从提案导入 (章节选择)
   - [ ] 作品集编辑器
   - [ ] 作品集公开展示页
   - [ ] SEO 优化
   - [ ] 社交分享

2. **模板管理**
   - [ ] 模板库页面
   - [ ] 模板预览
   - [ ] 从提案创建模板
   - [ ] 模板分类
   - [ ] 模板搜索

3. **预约管理**
   - [ ] 预约列表页
   - [ ] 预约创建
   - [ ] 预约日历视图
   - [ ] 客户预约界面
   - [ ] 预约提醒

4. **我的日历**
   - [ ] 日历视图 (日/周/月)
   - [ ] 事件创建
   - [ ] 事件编辑
   - [ ] 团队日历
   - [ ] 日历同步

5. **设计师管理**
   - [ ] 设计师列表
   - [ ] 设计师档案
   - [ ] 项目分配
   - [ ] 工作负载视图

6. **系统设置**
   - [ ] 基础设置
   - [ ] 品牌设置
   - [ ] 通知设置
   - [ ] 订阅管理
   - [ ] ERP 集成设置
   - [ ] 账号权限管理

**验收标准**:
- ✅ 所有功能页面完整
- ✅ 作品集导入流程正常
- ✅ 模板系统可用
- ✅ 预约功能完整
- ✅ 日历功能正常
- ✅ 设置页面完整

**预计时间**: 6-7天

---

### 批次 8: 测试与优化 (Phase 8)

**目标**: 完善测试、性能优化、安全加固

**分支**: `feature/testing-optimization`

**依赖**: 批次 7 完成

**工作内容**:

1. **单元测试**
   - [ ] 后端服务测试 (覆盖率 > 80%)
   - [ ] 前端组件测试 (Jest + RTL)
   - [ ] API hooks 测试
   - [ ] 工具函数测试

2. **集成测试**
   - [ ] API 端到端测试
   - [ ] 认证流程测试
   - [ ] 提案创建流程测试
   - [ ] AI 生成流程测试
   - [ ] 版本控制流程测试

3. **E2E 测试**
   - [ ] 登录注册流程
   - [ ] 提案编辑流程
   - [ ] 作品集管理流程
   - [ ] 预约流程
   - [ ] 关键用户路径

4. **性能优化**
   - [ ] 前端代码分割
   - [ ] 图片懒加载
   - [ ] API 响应缓存
   - [ ] 数据库查询优化
   - [ ] Redis 缓存策略
   - [ ] CDN 配置

5. **安全加固**
   - [ ] OWASP Top 10 检查
   - [ ] SQL 注入防护
   - [ ] XSS 防护
   - [ ] CSRF 防护
   - [ ] 速率限制
   - [ ] 安全头部配置

6. **文档完善**
   - [ ] API 文档更新
   - [ ] 部署文档
   - [ ] 开发者指南
   - [ ] 用户手册

**验收标准**:
- ✅ 测试覆盖率 > 80%
- ✅ 所有 E2E 测试通过
- ✅ 页面加载 < 2秒 (P95)
- ✅ API 响应 < 500ms (P95)
- ✅ 安全检查通过
- ✅ 文档完整

**预计时间**: 5-6天

---

## 总体时间估算

- **批次 1**: 3-4天
- **批次 2**: 5-6天
- **批次 3**: 4-5天
- **批次 4**: 3-4天
- **批次 5**: 7-8天
- **批次 6**: 4-5天
- **批次 7**: 6-7天
- **批次 8**: 5-6天

**总计**: 37-45天 (约 6-7周)

## 验收流程

每个批次完成后：

1. **代码审查**
   - 检查代码质量
   - 检查测试覆盖率
   - 检查文档完整性

2. **功能验收**
   - 运行所有测试
   - 手动测试核心功能
   - 检查性能指标

3. **Git 操作**
   - 合并到 develop 分支
   - 创建 Pull Request
   - 代码审查通过后合并

4. **文档更新**
   - 更新 CHANGELOG
   - 更新 README
   - 更新 API 文档

## 风险管理

### 技术风险

1. **AI API 不稳定**
   - 缓解: 实现重试机制和降级策略
   - 缓解: 多供应商备份

2. **性能瓶颈**
   - 缓解: 提前进行性能测试
   - 缓解: 实施缓存策略

3. **数据库迁移问题**
   - 缓解: 完善迁移脚本
   - 缓解: 备份策略

### 进度风险

1. **功能复杂度超预期**
   - 缓解: 分阶段交付
   - 缓解: MVP 优先

2. **测试时间不足**
   - 缓解: 并行开发和测试
   - 缓解: 自动化测试

## 下一步行动

1. ✅ 创建 develop 分支
2. ✅ 创建第一个功能分支 `feature/backend-infrastructure`
3. ✅ 开始批次 1 开发
4. 等待用户验收批次 1
5. 继续后续批次

---

**文档版本**: 1.0
**创建日期**: 2025年
**最后更新**: 2025年
