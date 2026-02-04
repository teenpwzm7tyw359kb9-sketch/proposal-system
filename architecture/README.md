# 提案展示系统技术架构文档

## 文档概述

本目录包含提案展示系统的完整技术架构文档，涵盖系统设计、数据库架构、API规范、ERP集成和AI集成等核心技术领域。

## 文档列表

### 1. 系统架构文档 (system-architecture.md)
**内容概要**:
- 整体系统架构设计
- 技术栈选型与justification
- 前端架构 (Next.js 14+ App Router, React 18+, TypeScript)
- 后端架构 (Node.js + Nest.js)
- 数据库设计 (PostgreSQL + Redis)
- 文件存储方案 (阿里云OSS)
- 认证授权系统 (JWT + RBAC)
- 部署架构 (Kubernetes)
- 安全防护 (OWASP Top 10)
- 监控与日志策略

**适用人群**: 架构师、技术负责人、全栈开发工程师

### 2. 数据库架构 (database-schema.sql)
**内容概要**:
- 完整的PostgreSQL数据库架构
- 14个核心业务表组
- 性能优化索引
- 外键约束和数据完整性
- 触发器和审计日志
- 常用查询视图
- 初始化数据

**核心表结构**:
- 用户与权限: users, roles, permissions, user_roles, role_permissions
- 提案管理: proposals, proposal_versions, proposal_pages, proposal_shares, proposal_views
- 作品集: portfolios, portfolio_items, portfolio_categories
- 模板: templates, template_categories
- 预约日历: appointments, calendar_events
- AI功能: ai_generations, ai_usage_logs, ai_quotas
- 产品报价: products, quotations, quotation_items
- 客户管理: customers, customer_contacts
- ERP集成: erp_connections, erp_sync_logs
- 系统支持: files, notifications, audit_logs

**适用人群**: 数据库管理员、后端开发工程师

### 3. API规范文档 (api-specification.md)
**内容概要**:
- RESTful API设计规范
- 完整的API端点定义
- 请求/响应格式
- 认证与授权机制
- 错误处理标准
- 限流规则
- Webhook机制
- SDK使用示例

**核心API模块**:
- 认证授权 (登录、注册、OAuth2)
- 提案管理 (CRUD、版本控制、分享、统计)
- 作品集管理
- 模板管理
- 预约与日历
- AI集成 (图像生成、文案创作)
- 产品报价
- 客户管理
- 文件管理

**适用人群**: 前端开发工程师、后端开发工程师、API集成开发者

### 4. ERP集成规范 (erp-integration-spec.md)
**内容概要**:
- ERP集成架构设计
- 标准化数据模型
- 统一API接口规范
- 主流ERP系统集成方案
  - 用友ERP (U8, NC)
  - 金蝶ERP (K3, 云星空)
  - SAP (Business One, S/4HANA)
  - 自定义ERP
- 数据同步策略
- 错误处理与重试机制
- Webhook回调机制
- 安全与认证

**核心功能**:
- 客户数据双向同步
- 产品信息同步
- 订单数据推送
- 库存实时查询
- 数据映射与转换
- 冲突解决策略

**适用人群**: 后端开发工程师、ERP集成工程师、系统架构师

### 5. AI集成架构 (ai-integration-architecture.md)
**内容概要**:
- 多提供商AI架构
- OpenAI集成 (GPT-4, DALL-E 3)
- Anthropic Claude集成
- Google Gemini集成
- 统一服务抽象层
- 提供商选择策略
- 配额管理系统
- 异步任务队列
- 缓存优化策略
- 错误处理与降级

**核心功能**:
- 图像生成 (文生图、图生图、风格转换)
- 文案创作 (提案文案、设计理念、产品描述)
- 智能建议 (配色、布局、预算)
- 用户自带API Key支持
- OAuth2授权流程
- Token计费与成本控制

**适用人群**: AI工程师、后端开发工程师、系统架构师

## 技术栈总览

### 前端技术栈
```
框架: Next.js 14+ (App Router)
UI库: React 18+
语言: TypeScript 5+
状态管理: Zustand + React Query
UI组件: Ant Design 5 + Tailwind CSS
表单: React Hook Form + Zod
图表: ECharts
3D渲染: Three.js
构建工具: Turbopack
包管理: pnpm
```

### 后端技术栈
```
运行时: Node.js 20 LTS
框架: Nest.js 10+
语言: TypeScript 5+
数据库: PostgreSQL 15
缓存: Redis 7
ORM: Prisma
消息队列: RabbitMQ
搜索引擎: Elasticsearch 8
分析数据库: ClickHouse
```

### 基础设施
```
云服务商: 阿里云 (中国大陆)
容器化: Docker
编排: Kubernetes (ACK)
存储: 阿里云OSS
CDN: 阿里云CDN
负载均衡: 阿里云SLB
监控: Prometheus + Grafana
日志: ELK Stack
追踪: Jaeger
CI/CD: GitLab CI/CD
```

### AI服务
```
OpenAI: GPT-4, GPT-3.5, DALL-E 3, DALL-E 2
Anthropic: Claude 3 (Opus, Sonnet, Haiku)
Google: Gemini Pro, Gemini Pro Vision
```

### ERP系统
```
用友: U8, NC
金蝶: K3, 云星空
SAP: Business One, S/4HANA
自定义: 标准化API接口
```

## 架构特点

### 1. 微服务架构
- 12个核心微服务
- 独立部署和扩展
- 服务间通信使用gRPC/REST
- 服务网格 (Istio)

### 2. 云原生设计
- 容器化部署
- Kubernetes编排
- 自动扩缩容
- 声明式配置

### 3. 高性能
- 多级缓存 (内存 + Redis)
- CDN加速
- 数据库读写分离
- 连接池优化
- 异步任务处理

### 4. 高可用
- 99.9%可用性保证
- 多副本部署
- 健康检查和自动恢复
- 降级和熔断机制
- 灾难恢复方案

### 5. 安全防护
- OWASP Top 10防护
- 数据加密 (传输层TLS 1.3, 存储层AES-256)
- JWT + RBAC权限控制
- API限流和防护
- 审计日志

### 6. 可扩展性
- 水平扩展支持
- 插件化架构
- 标准化接口
- 多租户支持

## 性能指标

### 系统性能
- 页面加载时间: P95 < 2秒
- API响应时间: P95 < 500ms
- 并发用户: ≥ 10,000
- 系统可用性: 99.9%

### 数据库性能
- 查询响应: P95 < 100ms
- 写入TPS: ≥ 5,000
- 连接池: 200连接
- 缓存命中率: ≥ 80%

### AI性能
- 文本生成: 平均 3-5秒
- 图像生成: 平均 20-30秒
- 配额限制: 根据订阅计划
- 成本优化: 智能模型选择

## 安全合规

### 数据合规
- 数据存储: 中国大陆境内
- 隐私保护: 符合《个人信息保护法》
- 等保认证: 等保三级
- 内容审核: 阿里云内容安全

### 安全措施
- 传输加密: TLS 1.3
- 存储加密: AES-256
- 密码策略: 强密码要求
- 双因素认证: 支持
- API密钥管理: 加密存储
- 审计日志: 完整记录

## 部署架构

### 生产环境
```
Region: 中国大陆 (华北/华东/华南)
Availability Zones: 3个可用区
Kubernetes Cluster: 生产集群
Node Count: 10-50 (自动扩缩容)
Database: RDS PostgreSQL (主从架构)
Cache: Redis企业版 (集群模式)
Storage: OSS (标准存储)
CDN: 全国节点覆盖
```

### 开发环境
```
Kubernetes Cluster: 开发集群
Node Count: 3-5
Database: RDS PostgreSQL (单实例)
Cache: Redis (单实例)
Storage: OSS (低频存储)
```

## 监控与告警

### 监控指标
- 系统指标: CPU、内存、磁盘、网络
- 应用指标: QPS、响应时间、错误率
- 业务指标: 用户活跃度、功能使用率
- 数据库指标: 连接数、慢查询、锁等待

### 告警策略
- 紧急告警: 系统宕机、数据库故障
- 重要告警: 性能下降、错误率上升
- 一般告警: 资源使用率高、慢查询
- 通知渠道: 钉钉、企业微信、邮件、短信

## 开发规范

### 代码规范
- ESLint + Prettier
- TypeScript严格模式
- Git提交规范 (Conventional Commits)
- 代码审查 (Code Review)

### 测试规范
- 单元测试覆盖率 ≥ 80%
- 集成测试
- E2E测试
- 性能测试
- 安全测试

### 文档规范
- API文档 (Swagger/OpenAPI)
- 代码注释
- README文档
- 变更日志

## 快速开始

### 1. 环境准备
```bash
# 安装依赖
node >= 20.0.0
pnpm >= 8.0.0
docker >= 24.0.0
kubectl >= 1.28.0

# 克隆代码
git clone https://github.com/your-org/proposal-system.git
cd proposal-system

# 安装依赖
pnpm install
```

### 2. 本地开发
```bash
# 启动数据库
docker-compose up -d postgres redis

# 运行数据库迁移
pnpm prisma migrate dev

# 启动开发服务器
pnpm dev
```

### 3. 构建部署
```bash
# 构建Docker镜像
docker build -t proposal-system:latest .

# 部署到Kubernetes
kubectl apply -f k8s/
```

## 相关链接

- **产品需求文档**: `/home/ubuntu/proposal-system-prd.md`
- **设计系统**: `/home/ubuntu/design-system/`
- **技术架构**: `/home/ubuntu/architecture/`
- **API文档**: `https://api.proposal-system.com/docs`
- **用户手册**: `https://docs.proposal-system.com`
- **问题反馈**: `https://github.com/your-org/proposal-system/issues`

## 版本历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|---------|------|
| 1.0 | 2026-02-04 | 初始版本发布 | 技术架构团队 |

## 联系方式

- **技术支持**: tech-support@proposal-system.com
- **架构咨询**: architecture@proposal-system.com
- **安全问题**: security@proposal-system.com

---

**文档维护**: 技术架构组  
**最后更新**: 2026年2月4日  
**文档版本**: 1.0
