# 提案展示系统技术架构文档

## 文档信息
- **版本**: 1.0
- **最后更新**: 2026年2月4日
- **作者**: 技术架构团队
- **状态**: 正式版

## 1. 系统架构概述

### 1.1 架构愿景

提案展示系统采用现代化的微服务架构，基于云原生技术栈构建，旨在为中国设计行业提供高性能、高可用、高安全的SaaS平台。系统架构遵循以下核心原则：

- **可扩展性**: 支持水平扩展，满足业务快速增长需求
- **高可用性**: 99.9%系统可用性保证
- **安全性**: 符合等保三级要求，全方位安全防护
- **性能优化**: P95响应时间<2秒，支持10,000+并发用户
- **合规性**: 数据存储在中国大陆境内，符合《个人信息保护法》

### 1.2 整体架构图（文本描述）

```
┌─────────────────────────────────────────────────────────────────┐
│                          客户端层                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ Web浏览器 │  │ 移动浏览器 │  │  微信小程序│  │  桌面应用 │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓ HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                       CDN + 负载均衡层                            │
│  ┌──────────────────┐         ┌──────────────────┐             │
│  │  阿里云CDN        │         │  阿里云SLB        │             │
│  │  (静态资源加速)    │         │  (负载均衡)       │             │
│  └──────────────────┘         └──────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                         API网关层                                │
│  ┌──────────────────────────────────────────────────┐           │
│  │  Kong API Gateway                                 │           │
│  │  - 路由管理  - 认证授权  - 限流熔断  - 日志监控   │           │
│  └──────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        应用服务层                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │用户服务   │  │提案服务   │  │作品集服务 │  │模板服务   │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │预约服务   │  │日历服务   │  │AI服务     │  │权限服务   │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │ERP集成服务│  │文件服务   │  │通知服务   │  │分析服务   │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                        数据存储层                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │PostgreSQL │  │  Redis    │  │阿里云OSS  │  │Elasticsearch│     │
│  │(主数据库) │  │  (缓存)   │  │(文件存储) │  │  (搜索)    │     │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐                                     │
│  │RabbitMQ   │  │  ClickHouse│                                   │
│  │(消息队列) │  │  (分析数据库)│                                  │
│  └──────────┘  └──────────┘                                     │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                       外部服务集成层                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │OpenAI API │  │Claude API │  │Gemini API │  │阿里云服务 │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │微信API    │  │短信服务   │  │邮件服务   │  │ERP系统    │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 架构特点

#### 1.3.1 微服务架构
- **服务拆分**: 按业务领域拆分为12个核心微服务
- **独立部署**: 每个服务独立开发、测试、部署
- **技术异构**: 根据业务特点选择最适合的技术栈
- **故障隔离**: 单个服务故障不影响整体系统

#### 1.3.2 云原生设计
- **容器化**: 所有服务基于Docker容器化部署
- **编排管理**: 使用Kubernetes进行容器编排
- **弹性伸缩**: 根据负载自动扩缩容
- **服务网格**: 使用Istio实现服务间通信管理

#### 1.3.3 数据架构
- **读写分离**: PostgreSQL主从架构，读写分离
- **缓存优先**: Redis多级缓存策略
- **分库分表**: 支持水平分片，应对数据增长
- **数据备份**: 每日全量备份，实时增量备份

## 2. 技术栈选型

### 2.1 前端技术栈

#### 2.1.1 核心框架
```javascript
{
  "framework": "Next.js 14+",
  "reason": "支持SSR/SSG，SEO友好，性能优异",
  "features": [
    "App Router架构",
    "Server Components",
    "Streaming SSR",
    "Image优化",
    "自动代码分割"
  ]
}
```

#### 2.1.2 UI框架
```javascript
{
  "react": "18+",
  "typescript": "5+",
  "stateManagement": "Zustand + React Query",
  "uiLibrary": "Ant Design 5 + Tailwind CSS",
  "formManagement": "React Hook Form + Zod",
  "charts": "ECharts",
  "3d": "Three.js + React Three Fiber",
  "editor": "Slate.js / Lexical"
}
```

#### 2.1.3 构建工具
```javascript
{
  "bundler": "Turbopack (Next.js内置)",
  "packageManager": "pnpm",
  "linter": "ESLint + Prettier",
  "testing": "Vitest + React Testing Library + Playwright"
}
```

### 2.2 后端技术栈

#### 2.2.1 核心框架
```javascript
{
  "runtime": "Node.js 20 LTS",
  "framework": "Nest.js 10+",
  "reason": "企业级框架，TypeScript原生支持，模块化架构",
  "features": [
    "依赖注入",
    "模块化设计",
    "装饰器语法",
    "内置验证",
    "微服务支持"
  ]
}
```

#### 2.2.2 数据库
```javascript
{
  "primary": {
    "database": "PostgreSQL 15",
    "orm": "Prisma",
    "features": ["JSONB支持", "全文搜索", "地理位置", "事务支持"]
  },
  "cache": {
    "database": "Redis 7",
    "client": "ioredis",
    "features": ["缓存", "会话", "队列", "发布订阅"]
  },
  "search": {
    "engine": "Elasticsearch 8",
    "client": "@elastic/elasticsearch",
    "features": ["全文搜索", "聚合分析", "日志存储"]
  },
  "analytics": {
    "database": "ClickHouse",
    "features": ["实时分析", "大数据处理", "列式存储"]
  }
}
```

#### 2.2.3 消息队列
```javascript
{
  "mq": "RabbitMQ",
  "client": "amqplib",
  "useCases": [
    "异步任务处理",
    "AI图像生成队列",
    "邮件发送队列",
    "数据同步队列"
  ]
}
```

### 2.3 基础设施

#### 2.3.1 云服务提供商
```yaml
provider: 阿里云（中国大陆）
services:
  compute: ECS (弹性计算服务)
  container: ACK (容器服务Kubernetes版)
  storage: OSS (对象存储服务)
  database: RDS for PostgreSQL
  cache: Redis企业版
  cdn: 阿里云CDN
  loadBalancer: SLB (负载均衡)
  security: WAF + DDoS防护
```

#### 2.3.2 DevOps工具链
```yaml
versionControl: GitLab
ci_cd: GitLab CI/CD
containerRegistry: 阿里云容器镜像服务
monitoring: Prometheus + Grafana
logging: ELK Stack (Elasticsearch + Logstash + Kibana)
tracing: Jaeger
alerting: AlertManager + 钉钉/企业微信
```

## 3. 前端架构设计

### 3.1 Next.js App Router架构

#### 3.1.1 目录结构
```
proposal-system-frontend/
├── app/                          # App Router目录
│   ├── (auth)/                   # 认证路由组
│   │   ├── login/
│   │   ├── register/
│   │   └── layout.tsx
│   ├── (dashboard)/              # 主应用路由组
│   │   ├── proposals/            # 提案管理
│   │   ├── portfolios/           # 作品集管理
│   │   ├── templates/            # 模板管理
│   │   ├── appointments/         # 预约管理
│   │   ├── calendar/             # 日历
│   │   ├── ai/                   # AI功能
│   │   ├── settings/             # 设置
│   │   └── layout.tsx
│   ├── api/                      # API路由
│   │   ├── auth/
│   │   ├── upload/
│   │   └── webhooks/
│   ├── layout.tsx                # 根布局
│   ├── page.tsx                  # 首页
│   └── error.tsx                 # 错误页面
├── components/                   # 组件目录
│   ├── ui/                       # 基础UI组件
│   ├── features/                 # 功能组件
│   ├── layouts/                  # 布局组件
│   └── shared/                   # 共享组件
├── lib/                          # 工具库
│   ├── api/                      # API客户端
│   ├── hooks/                    # 自定义Hooks
│   ├── utils/                    # 工具函数
│   └── constants/                # 常量定义
├── stores/                       # 状态管理
│   ├── auth.store.ts
│   ├── proposal.store.ts
│   └── ui.store.ts
├── styles/                       # 样式文件
│   ├── globals.css
│   └── themes/
├── types/                        # TypeScript类型定义
├── public/                       # 静态资源
└── next.config.js                # Next.js配置
```

#### 3.1.2 Server Components vs Client Components

**Server Components (默认)**:
- 数据获取
- 访问后端资源
- 保护敏感信息
- 减少客户端JavaScript

**Client Components (use client)**:
- 交互性组件
- 使用浏览器API
- 使用React Hooks
- 状态管理

示例:
```typescript
// app/proposals/page.tsx (Server Component)
import { ProposalList } from '@/components/features/proposals/ProposalList'
import { getProposals } from '@/lib/api/proposals'

export default async function ProposalsPage() {
  const proposals = await getProposals()
  
  return (
    <div>
      <h1>提案管理</h1>
      <ProposalList initialData={proposals} />
    </div>
  )
}

// components/features/proposals/ProposalList.tsx (Client Component)
'use client'

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'

export function ProposalList({ initialData }) {
  const [filter, setFilter] = useState('all')
  const { data } = useQuery({
    queryKey: ['proposals', filter],
    queryFn: () => fetchProposals(filter),
    initialData
  })
  
  return (
    // 交互式列表组件
  )
}
```

### 3.2 状态管理策略

#### 3.2.1 Zustand - 全局状态
```typescript
// stores/auth.store.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

interface AuthState {
  user: User | null
  token: string | null
  login: (credentials: Credentials) => Promise<void>
  logout: () => void
  refreshToken: () => Promise<void>
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      login: async (credentials) => {
        const { user, token } = await authAPI.login(credentials)
        set({ user, token })
      },
      logout: () => {
        set({ user: null, token: null })
      },
      refreshToken: async () => {
        const { token } = await authAPI.refresh(get().token)
        set({ token })
      }
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ token: state.token })
    }
  )
)
```

#### 3.2.2 React Query - 服务端状态
```typescript
// lib/api/proposals.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

export function useProposals(filters?: ProposalFilters) {
  return useQuery({
    queryKey: ['proposals', filters],
    queryFn: () => proposalAPI.getAll(filters),
    staleTime: 5 * 60 * 1000, // 5分钟
    cacheTime: 10 * 60 * 1000 // 10分钟
  })
}

export function useCreateProposal() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: (data: CreateProposalDTO) => proposalAPI.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposals'] })
    }
  })
}
```

### 3.3 API客户端设计

#### 3.3.1 Axios封装
```typescript
// lib/api/client.ts
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios'
import { useAuthStore } from '@/stores/auth.store'

class APIClient {
  private client: AxiosInstance

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL,
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json'
      }
    })

    this.setupInterceptors()
  }

  private setupInterceptors() {
    // 请求拦截器 - 添加认证token
    this.client.interceptors.request.use(
      (config) => {
        const token = useAuthStore.getState().token
        if (token) {
          config.headers.Authorization = `Bearer ${token}`
        }
        return config
      },
      (error) => Promise.reject(error)
    )

    // 响应拦截器 - 处理错误和token刷新
    this.client.interceptors.response.use(
      (response) => response.data,
      async (error) => {
        const originalRequest = error.config

        // Token过期，尝试刷新
        if (error.response?.status === 401 && !originalRequest._retry) {
          originalRequest._retry = true
          
          try {
            await useAuthStore.getState().refreshToken()
            return this.client(originalRequest)
          } catch (refreshError) {
            useAuthStore.getState().logout()
            window.location.href = '/login'
            return Promise.reject(refreshError)
          }
        }

        return Promise.reject(error)
      }
    )
  }

  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.client.get(url, config)
  }

  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return this.client.post(url, data, config)
  }

  async put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    return this.client.put(url, data, config)
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    return this.client.delete(url, config)
  }

  async upload<T>(url: string, file: File, onProgress?: (progress: number) => void): Promise<T> {
    const formData = new FormData()
    formData.append('file', file)

    return this.client.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      },
      onUploadProgress: (progressEvent) => {
        if (onProgress && progressEvent.total) {
          const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
          onProgress(progress)
        }
      }
    })
  }
}

export const apiClient = new APIClient()
```

### 3.4 性能优化策略

#### 3.4.1 代码分割
```typescript
// 动态导入大型组件
import dynamic from 'next/dynamic'

const ProposalEditor = dynamic(
  () => import('@/components/features/proposals/ProposalEditor'),
  {
    loading: () => <EditorSkeleton />,
    ssr: false // 编辑器不需要SSR
  }
)

const AIImageGenerator = dynamic(
  () => import('@/components/features/ai/ImageGenerator'),
  { ssr: false }
)
```

#### 3.4.2 图片优化
```typescript
import Image from 'next/image'

// 使用Next.js Image组件
<Image
  src="/proposal-cover.jpg"
  alt="提案封面"
  width={800}
  height={600}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
  priority={false}
  loading="lazy"
/>
```

#### 3.4.3 缓存策略
```typescript
// app/proposals/[id]/page.tsx
export const revalidate = 60 // ISR: 60秒重新验证

export async function generateStaticParams() {
  const proposals = await getPopularProposals()
  return proposals.map((p) => ({ id: p.id }))
}
```

## 4. 后端架构设计

### 4.1 Nest.js微服务架构

#### 4.1.1 项目结构
```
proposal-system-backend/
├── apps/                         # 微服务应用
│   ├── api-gateway/              # API网关
│   ├── auth-service/             # 认证服务
│   ├── proposal-service/         # 提案服务
│   ├── portfolio-service/        # 作品集服务
│   ├── template-service/         # 模板服务
│   ├── appointment-service/      # 预约服务
│   ├── calendar-service/         # 日历服务
│   ├── ai-service/               # AI服务
│   ├── file-service/             # 文件服务
│   ├── notification-service/     # 通知服务
│   ├── analytics-service/        # 分析服务
│   └── erp-integration-service/  # ERP集成服务
├── libs/                         # 共享库
│   ├── common/                   # 通用模块
│   │   ├── decorators/
│   │   ├── filters/
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── pipes/
│   │   └── utils/
│   ├── database/                 # 数据库模块
│   │   ├── prisma/
│   │   └── redis/
│   ├── config/                   # 配置模块
│   └── logger/                   # 日志模块
├── prisma/                       # Prisma配置
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── docker/                       # Docker配置
├── k8s/                          # Kubernetes配置
└── nest-cli.json
```

#### 4.1.2 API网关服务
```typescript
// apps/api-gateway/src/main.ts
import { NestFactory } from '@nestjs/core'
import { ValidationPipe } from '@nestjs/common'
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger'
import { AppModule } from './app.module'
import helmet from 'helmet'
import rateLimit from 'express-rate-limit'

async function bootstrap() {
  const app = await NestFactory.create(AppModule)

  // 安全中间件
  app.use(helmet())
  
  // 限流
  app.use(
    rateLimit({
      windowMs: 15 * 60 * 1000, // 15分钟
      max: 100 // 限制100个请求
    })
  )

  // 全局验证管道
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true
    })
  )

  // CORS配置
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(','),
    credentials: true
  })

  // Swagger文档
  const config = new DocumentBuilder()
    .setTitle('提案展示系统API')
    .setDescription('提案展示系统RESTful API文档')
    .setVersion('1.0')
    .addBearerAuth()
    .build()
  const document = SwaggerModule.createDocument(app, config)
  SwaggerModule.setup('api/docs', app, document)

  await app.listen(3000)
}

bootstrap()
```

#### 4.1.3 提案服务示例
```typescript
// apps/proposal-service/src/proposal/proposal.controller.ts
import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { ProposalService } from './proposal.service'
import { JwtAuthGuard } from '@/common/guards/jwt-auth.guard'
import { RolesGuard } from '@/common/guards/roles.guard'
import { Roles } from '@/common/decorators/roles.decorator'
import { CurrentUser } from '@/common/decorators/current-user.decorator'

@ApiTags('提案管理')
@ApiBearerAuth()
@Controller('proposals')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProposalController {
  constructor(private readonly proposalService: ProposalService) {}

  @Get()
  @ApiOperation({ summary: '获取提案列表' })
  async findAll(@Query() query: ProposalQueryDto, @CurrentUser() user: User) {
    return this.proposalService.findAll(query, user)
  }

  @Get(':id')
  @ApiOperation({ summary: '获取提案详情' })
  async findOne(@Param('id') id: string, @CurrentUser() user: User) {
    return this.proposalService.findOne(id, user)
  }

  @Post()
  @Roles('admin', 'editor')
  @ApiOperation({ summary: '创建提案' })
  async create(@Body() dto: CreateProposalDto, @CurrentUser() user: User) {
    return this.proposalService.create(dto, user)
  }

  @Put(':id')
  @Roles('admin', 'editor')
  @ApiOperation({ summary: '更新提案' })
  async update(@Param('id') id: string, @Body() dto: UpdateProposalDto, @CurrentUser() user: User) {
    return this.proposalService.update(id, dto, user)
  }

  @Delete(':id')
  @Roles('admin')
  @ApiOperation({ summary: '删除提案' })
  async remove(@Param('id') id: string, @CurrentUser() user: User) {
    return this.proposalService.remove(id, user)
  }
}

// apps/proposal-service/src/proposal/proposal.service.ts
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common'
import { PrismaService } from '@/database/prisma/prisma.service'
import { RedisService } from '@/database/redis/redis.service'
import { EventEmitter2 } from '@nestjs/event-emitter'

@Injectable()
export class ProposalService {
  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
    private eventEmitter: EventEmitter2
  ) {}

  async findAll(query: ProposalQueryDto, user: User) {
    const cacheKey = `proposals:${user.id}:${JSON.stringify(query)}`
    
    // 尝试从缓存获取
    const cached = await this.redis.get(cacheKey)
    if (cached) {
      return JSON.parse(cached)
    }

    // 从数据库查询
    const proposals = await this.prisma.proposal.findMany({
      where: {
        userId: user.id,
        status: query.status,
        ...query.filters
      },
      include: {
        customer: true,
        tags: true
      },
      orderBy: { updatedAt: 'desc' },
      skip: query.skip,
      take: query.take
    })

    // 缓存结果
    await this.redis.setex(cacheKey, 300, JSON.stringify(proposals))

    return proposals
  }

  async create(dto: CreateProposalDto, user: User) {
    const proposal = await this.prisma.proposal.create({
      data: {
        ...dto,
        userId: user.id,
        status: 'draft'
      }
    })

    // 发送事件
    this.eventEmitter.emit('proposal.created', { proposal, user })

    // 清除缓存
    await this.redis.del(`proposals:${user.id}:*`)

    return proposal
  }

  async update(id: string, dto: UpdateProposalDto, user: User) {
    // 检查权限
    const proposal = await this.prisma.proposal.findUnique({ where: { id } })
    if (!proposal) {
      throw new NotFoundException('提案不存在')
    }
    if (proposal.userId !== user.id && user.role !== 'admin') {
      throw new ForbiddenException('无权限修改此提案')
    }

    // 更新提案
    const updated = await this.prisma.proposal.update({
      where: { id },
      data: dto
    })

    // 发送事件
    this.eventEmitter.emit('proposal.updated', { proposal: updated, user })

    // 清除缓存
    await this.redis.del(`proposals:${user.id}:*`)
    await this.redis.del(`proposal:${id}`)

    return updated
  }
}
```

### 4.2 数据库设计概览

#### 4.2.1 核心表结构
```
用户相关:
- users (用户表)
- roles (角色表)
- permissions (权限表)
- user_roles (用户角色关联表)
- role_permissions (角色权限关联表)

提案相关:
- proposals (提案表)
- proposal_versions (提案版本表)
- proposal_pages (提案页面表)
- proposal_shares (提案分享记录表)
- proposal_views (提案访问记录表)

作品集相关:
- portfolios (作品集表)
- portfolio_items (作品集项目表)
- portfolio_categories (作品集分类表)

模板相关:
- templates (模板表)
- template_categories (模板分类表)

预约相关:
- appointments (预约表)
- appointment_types (预约类型表)

日历相关:
- calendar_events (日历事件表)
- calendar_shares (日历共享表)

AI相关:
- ai_generations (AI生成记录表)
- ai_usage_logs (AI使用日志表)
- ai_quotas (AI配额表)

产品报价相关:
- products (产品表)
- product_categories (产品分类表)
- quotations (报价单表)
- quotation_items (报价单项目表)

客户相关:
- customers (客户表)
- customer_contacts (客户联系人表)

ERP集成相关:
- erp_connections (ERP连接配置表)
- erp_sync_logs (ERP同步日志表)

系统相关:
- audit_logs (审计日志表)
- notifications (通知表)
- files (文件表)
```

### 4.3 缓存策略

#### 4.3.1 多级缓存架构
```typescript
// libs/database/redis/cache.service.ts
import { Injectable } from '@nestjs/common'
import { RedisService } from './redis.service'

@Injectable()
export class CacheService {
  constructor(private redis: RedisService) {}

  // L1: 内存缓存 (应用级)
  private memoryCache = new Map<string, { data: any; expiry: number }>()

  // L2: Redis缓存 (分布式)
  async get<T>(key: string): Promise<T | null> {
    // 先查内存缓存
    const memCached = this.memoryCache.get(key)
    if (memCached && memCached.expiry > Date.now()) {
      return memCached.data
    }

    // 再查Redis
    const redisCached = await this.redis.get(key)
    if (redisCached) {
      const data = JSON.parse(redisCached)
      // 回填内存缓存
      this.memoryCache.set(key, {
        data,
        expiry: Date.now() + 60000 // 1分钟
      })
      return data
    }

    return null
  }

  async set(key: string, value: any, ttl: number = 300): Promise<void> {
    // 写入Redis
    await this.redis.setex(key, ttl, JSON.stringify(value))
    
    // 写入内存缓存
    this.memoryCache.set(key, {
      data: value,
      expiry: Date.now() + Math.min(ttl * 1000, 60000)
    })
  }

  async del(pattern: string): Promise<void> {
    // 清除Redis缓存
    const keys = await this.redis.keys(pattern)
    if (keys.length > 0) {
      await this.redis.del(...keys)
    }

    // 清除内存缓存
    for (const key of this.memoryCache.keys()) {
      if (key.match(pattern)) {
        this.memoryCache.delete(key)
      }
    }
  }
}
```

#### 4.3.2 缓存策略
```typescript
// 缓存策略配置
const CACHE_STRATEGIES = {
  // 用户信息 - 长期缓存
  user: {
    ttl: 3600, // 1小时
    pattern: 'user:{id}'
  },
  
  // 提案列表 - 短期缓存
  proposals: {
    ttl: 300, // 5分钟
    pattern: 'proposals:{userId}:{filters}'
  },
  
  // 提案详情 - 中期缓存
  proposal: {
    ttl: 600, // 10分钟
    pattern: 'proposal:{id}'
  },
  
  // 模板列表 - 长期缓存
  templates: {
    ttl: 1800, // 30分钟
    pattern: 'templates:{category}'
  },
  
  // AI生成结果 - 永久缓存
  aiGeneration: {
    ttl: 0, // 不过期
    pattern: 'ai:generation:{id}'
  }
}
```

### 4.4 文件存储方案

#### 4.4.1 阿里云OSS集成
```typescript
// libs/common/services/oss.service.ts
import { Injectable } from '@nestjs/common'
import OSS from 'ali-oss'
import { ConfigService } from '@nestjs/config'

@Injectable()
export class OSSService {
  private client: OSS

  constructor(private config: ConfigService) {
    this.client = new OSS({
      region: this.config.get('OSS_REGION'),
      accessKeyId: this.config.get('OSS_ACCESS_KEY_ID'),
      accessKeySecret: this.config.get('OSS_ACCESS_KEY_SECRET'),
      bucket: this.config.get('OSS_BUCKET')
    })
  }

  async upload(file: Express.Multer.File, path: string): Promise<string> {
    const fileName = `${path}/${Date.now()}-${file.originalname}`
    
    const result = await this.client.put(fileName, file.buffer, {
      headers: {
        'Content-Type': file.mimetype,
        'Cache-Control': 'public, max-age=31536000'
      }
    })

    return result.url
  }

  async uploadStream(stream: NodeJS.ReadableStream, fileName: string): Promise<string> {
    const result = await this.client.putStream(fileName, stream)
    return result.url
  }

  async delete(fileName: string): Promise<void> {
    await this.client.delete(fileName)
  }

  async getSignedUrl(fileName: string, expires: number = 3600): Promise<string> {
    return this.client.signatureUrl(fileName, { expires })
  }

  async listFiles(prefix: string): Promise<string[]> {
    const result = await this.client.list({ prefix })
    return result.objects.map(obj => obj.name)
  }
}
```

#### 4.4.2 文件上传处理
```typescript
// apps/file-service/src/upload/upload.controller.ts
import { Controller, Post, UseInterceptors, UploadedFile, UploadedFiles } from '@nestjs/common'
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express'
import { ApiTags, ApiConsumes, ApiBody } from '@nestjs/swagger'
import { OSSService } from '@/common/services/oss.service'
import { ImageProcessingService } from './image-processing.service'

@ApiTags('文件上传')
@Controller('upload')
export class UploadController {
  constructor(
    private ossService: OSSService,
    private imageProcessing: ImageProcessingService
  ) {}

  @Post('image')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    // 图片处理
    const processed = await this.imageProcessing.process(file, {
      resize: { width: 1920, height: 1080, fit: 'inside' },
      format: 'webp',
      quality: 85
    })

    // 上传原图
    const originalUrl = await this.ossService.upload(file, 'images/original')
    
    // 上传处理后的图片
    const processedUrl = await this.ossService.upload(processed, 'images/processed')
    
    // 生成缩略图
    const thumbnail = await this.imageProcessing.createThumbnail(file, 400, 300)
    const thumbnailUrl = await this.ossService.upload(thumbnail, 'images/thumbnails')

    return {
      original: originalUrl,
      processed: processedUrl,
      thumbnail: thumbnailUrl
    }
  }

  @Post('batch')
  @UseInterceptors(FilesInterceptor('files', 10))
  async uploadBatch(@UploadedFiles() files: Express.Multer.File[]) {
    const results = await Promise.all(
      files.map(file => this.uploadImage(file))
    )
    return results
  }
}
```

### 4.5 认证与授权系统

#### 4.5.1 JWT认证
```typescript
// apps/auth-service/src/auth/auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common'
import { JwtService } from '@nestjs/jwt'
import { PrismaService } from '@/database/prisma/prisma.service'
import * as bcrypt from 'bcrypt'

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService
  ) {}

  async login(email: string, password: string) {
    // 查找用户
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { roles: { include: { permissions: true } } }
    })

    if (!user) {
      throw new UnauthorizedException('用户名或密码错误')
    }

    // 验证密码
    const isPasswordValid = await bcrypt.compare(password, user.password)
    if (!isPasswordValid) {
      throw new UnauthorizedException('用户名或密码错误')
    }

    // 生成token
    const payload = {
      sub: user.id,
      email: user.email,
      roles: user.roles.map(r => r.name)
    }

    const accessToken = this.jwtService.sign(payload, { expiresIn: '15m' })
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' })

    // 保存refresh token
    await this.prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId: user.id,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      }
    })

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        roles: user.roles.map(r => r.name)
      }
    }
  }

  async refreshToken(refreshToken: string) {
    // 验证refresh token
    const payload = this.jwtService.verify(refreshToken)
    
    // 检查token是否在数据库中
    const tokenRecord = await this.prisma.refreshToken.findFirst({
      where: {
        token: refreshToken,
        userId: payload.sub,
        expiresAt: { gt: new Date() }
      }
    })

    if (!tokenRecord) {
      throw new UnauthorizedException('无效的refresh token')
    }

    // 生成新的access token
    const newPayload = {
      sub: payload.sub,
      email: payload.email,
      roles: payload.roles
    }

    const accessToken = this.jwtService.sign(newPayload, { expiresIn: '15m' })

    return { accessToken }
  }

  async logout(userId: string, refreshToken: string) {
    await this.prisma.refreshToken.deleteMany({
      where: {
        userId,
        token: refreshToken
      }
    })
  }
}
```

#### 4.5.2 RBAC权限控制
```typescript
// libs/common/guards/roles.guard.ts
import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common'
import { Reflector } from '@nestjs/core'
import { PrismaService } from '@/database/prisma/prisma.service'

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private prisma: PrismaService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.get<string[]>('roles', context.getHandler())
    if (!requiredRoles) {
      return true
    }

    const request = context.switchToHttp().getRequest()
    const user = request.user

    // 检查用户角色
    const userRoles = await this.prisma.userRole.findMany({
      where: { userId: user.id },
      include: { role: true }
    })

    const hasRole = userRoles.some(ur => 
      requiredRoles.includes(ur.role.name)
    )

    return hasRole
  }
}

// libs/common/guards/permissions.guard.ts
@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private prisma: PrismaService
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.get<string[]>('permissions', context.getHandler())
    if (!requiredPermissions) {
      return true
    }

    const request = context.switchToHttp().getRequest()
    const user = request.user

    // 获取用户所有权限
    const userPermissions = await this.prisma.user.findUnique({
      where: { id: user.id },
      include: {
        roles: {
          include: {
            permissions: true
          }
        }
      }
    })

    const permissions = userPermissions.roles
      .flatMap(role => role.permissions)
      .map(p => p.name)

    const hasPermission = requiredPermissions.every(p => 
      permissions.includes(p)
    )

    return hasPermission
  }
}
```

### 4.6 外部链接分享机制

#### 4.6.1 分享链接生成
```typescript
// apps/proposal-service/src/share/share.service.ts
import { Injectable } from '@nestjs/common'
import { PrismaService } from '@/database/prisma/prisma.service'
import { nanoid } from 'nanoid'
import * as bcrypt from 'bcrypt'

@Injectable()
export class ShareService {
  constructor(private prisma: PrismaService) {}

  async createShareLink(proposalId: string, options: ShareOptions) {
    // 生成唯一的分享码
    const shareCode = nanoid(12)
    
    // 加密密码（如果有）
    const hashedPassword = options.password 
      ? await bcrypt.hash(options.password, 10)
      : null

    // 计算过期时间
    const expiresAt = options.expiryDays 
      ? new Date(Date.now() + options.expiryDays * 24 * 60 * 60 * 1000)
      : null

    // 创建分享记录
    const share = await this.prisma.proposalShare.create({
      data: {
        proposalId,
        shareCode,
        password: hashedPassword,
        expiresAt,
        allowDownload: options.allowDownload,
        allowComment: options.allowComment,
        watermark: options.watermark,
        trackViews: options.trackViews
      }
    })

    // 生成分享链接
    const shareUrl = `${process.env.APP_URL}/share/${shareCode}`

    return {
      shareUrl,
      shareCode,
      expiresAt
    }
  }

  async verifyShareAccess(shareCode: string, password?: string) {
    const share = await this.prisma.proposalShare.findUnique({
      where: { shareCode },
      include: { proposal: true }
    })

    if (!share) {
      throw new NotFoundException('分享链接不存在')
    }

    // 检查是否过期
    if (share.expiresAt && share.expiresAt < new Date()) {
      throw new ForbiddenException('分享链接已过期')
    }

    // 验证密码
    if (share.password) {
      if (!password) {
        throw new UnauthorizedException('需要密码访问')
      }
      const isPasswordValid = await bcrypt.compare(password, share.password)
      if (!isPasswordValid) {
        throw new UnauthorizedException('密码错误')
      }
    }

    return share
  }

  async trackView(shareCode: string, viewerInfo: ViewerInfo) {
    const share = await this.prisma.proposalShare.findUnique({
      where: { shareCode }
    })

    if (!share || !share.trackViews) {
      return
    }

    // 记录访问
    await this.prisma.proposalView.create({
      data: {
        proposalId: share.proposalId,
        shareId: share.id,
        viewerIp: viewerInfo.ip,
        viewerUserAgent: viewerInfo.userAgent,
        viewerLocation: viewerInfo.location,
        duration: 0
      }
    })

    // 更新访问次数
    await this.prisma.proposalShare.update({
      where: { id: share.id },
      data: { viewCount: { increment: 1 } }
    })
  }
}
```

## 5. 部署架构

### 5.1 Kubernetes部署

#### 5.1.1 集群架构
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: proposal-system
  labels:
    name: proposal-system
```

#### 5.1.2 服务部署示例
```yaml
# k8s/deployments/api-gateway.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: proposal-system
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: registry.cn-hangzhou.aliyuncs.com/proposal-system/api-gateway:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-secret
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: proposal-system
spec:
  selector:
    app: api-gateway
  ports:
  - protocol: TCP
    port: 80
    targetPort: 3000
  type: ClusterIP
```


#### 5.1.3 水平自动扩缩容
```yaml
# k8s/hpa/api-gateway-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway-hpa
  namespace: proposal-system
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### 5.2 监控与日志

#### 5.2.1 Prometheus监控
```yaml
# k8s/monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
```

#### 5.2.2 日志收集
```yaml
# k8s/logging/fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>

    <filter kubernetes.**>
      @type kubernetes_metadata
    </filter>

    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      logstash_format true
      logstash_prefix kubernetes
      <buffer>
        @type file
        path /var/log/fluentd-buffers/kubernetes.system.buffer
        flush_mode interval
        retry_type exponential_backoff
        flush_interval 5s
        retry_forever false
        retry_max_interval 30
        chunk_limit_size 2M
        queue_limit_length 8
        overflow_action block
      </buffer>
    </match>
```

### 5.3 安全架构

#### 5.3.1 网络安全
```yaml
# k8s/network-policies/api-gateway-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-gateway-policy
  namespace: proposal-system
spec:
  podSelector:
    matchLabels:
      app: api-gateway
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 3000
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: proposal-service
    - podSelector:
        matchLabels:
          app: auth-service
    ports:
    - protocol: TCP
      port: 3000
  - to:
    - namespaceSelector: {}
      podSelector:
        matchLabels:
          app: postgresql
    ports:
    - protocol: TCP
      port: 5432
```

#### 5.3.2 密钥管理
```yaml
# k8s/secrets/database-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: database-secret
  namespace: proposal-system
type: Opaque
stringData:
  url: postgresql://user:password@postgresql.proposal-system.svc.cluster.local:5432/proposal_db
  username: proposal_user
  password: <encrypted-password>
```

## 6. 可扩展性与性能

### 6.1 数据库优化

#### 6.1.1 读写分离
```typescript
// libs/database/prisma/prisma.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common'
import { PrismaClient } from '@prisma/client'

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  private readReplica: PrismaClient

  constructor() {
    super({
      datasources: {
        db: {
          url: process.env.DATABASE_URL // 主库
        }
      }
    })

    // 配置只读副本
    this.readReplica = new PrismaClient({
      datasources: {
        db: {
          url: process.env.DATABASE_READ_URL // 从库
        }
      }
    })
  }

  async onModuleInit() {
    await this.$connect()
    await this.readReplica.$connect()
  }

  // 读操作使用从库
  get read() {
    return this.readReplica
  }

  // 写操作使用主库
  get write() {
    return this
  }
}
```

#### 6.1.2 连接池配置
```typescript
// prisma/schema.prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  
  // 连接池配置
  connection_limit = 20
  pool_timeout = 10
  connect_timeout = 10
}
```

### 6.2 缓存优化

#### 6.2.1 缓存预热
```typescript
// apps/api-gateway/src/cache/cache-warmer.service.ts
import { Injectable, OnModuleInit } from '@nestjs/common'
import { CacheService } from '@/database/redis/cache.service'
import { TemplateService } from '@/services/template.service'

@Injectable()
export class CacheWarmerService implements OnModuleInit {
  constructor(
    private cache: CacheService,
    private templateService: TemplateService
  ) {}

  async onModuleInit() {
    // 应用启动时预热缓存
    await this.warmupTemplates()
    await this.warmupCommonData()
  }

  private async warmupTemplates() {
    const templates = await this.templateService.findAll()
    await this.cache.set('templates:all', templates, 3600)
  }

  private async warmupCommonData() {
    // 预热其他常用数据
  }
}
```

### 6.3 CDN加速

#### 6.3.1 静态资源CDN配置
```typescript
// next.config.js
module.exports = {
  images: {
    domains: ['cdn.proposal-system.com'],
    loader: 'custom',
    loaderFile: './lib/cdn-loader.ts'
  },
  assetPrefix: process.env.NODE_ENV === 'production' 
    ? 'https://cdn.proposal-system.com'
    : ''
}

// lib/cdn-loader.ts
export default function cdnLoader({ src, width, quality }) {
  const params = new URLSearchParams({
    url: src,
    w: width.toString(),
    q: (quality || 75).toString()
  })
  return `https://cdn.proposal-system.com/image?${params}`
}
```

## 7. 安全防护

### 7.1 OWASP Top 10防护

#### 7.1.1 SQL注入防护
```typescript
// 使用Prisma ORM，自动防止SQL注入
const user = await prisma.user.findUnique({
  where: { email: userInput } // 自动参数化查询
})
```

#### 7.1.2 XSS防护
```typescript
// libs/common/pipes/sanitize.pipe.ts
import { PipeTransform, Injectable } from '@nestjs/common'
import * as sanitizeHtml from 'sanitize-html'

@Injectable()
export class SanitizePipe implements PipeTransform {
  transform(value: any) {
    if (typeof value === 'string') {
      return sanitizeHtml(value, {
        allowedTags: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
        allowedAttributes: {
          'a': ['href']
        }
      })
    }
    return value
  }
}
```

#### 7.1.3 CSRF防护
```typescript
// apps/api-gateway/src/main.ts
import * as csurf from 'csurf'

app.use(csurf({ 
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict'
  }
}))
```

#### 7.1.4 限流防护
```typescript
// libs/common/guards/throttle.guard.ts
import { Injectable } from '@nestjs/common'
import { ThrottlerGuard } from '@nestjs/throttler'

@Injectable()
export class CustomThrottlerGuard extends ThrottlerGuard {
  protected async getTracker(req: Record<string, any>): Promise<string> {
    // 基于用户ID或IP限流
    return req.user?.id || req.ip
  }
}

// 使用示例
@UseGuards(CustomThrottlerGuard)
@Throttle(10, 60) // 60秒内最多10次请求
@Post('login')
async login(@Body() dto: LoginDto) {
  return this.authService.login(dto)
}
```

### 7.2 数据加密

#### 7.2.1 传输层加密
```nginx
# nginx配置 - TLS 1.3
server {
    listen 443 ssl http2;
    server_name api.proposal-system.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # HSTS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

#### 7.2.2 存储层加密
```typescript
// libs/common/services/encryption.service.ts
import { Injectable } from '@nestjs/common'
import * as crypto from 'crypto'

@Injectable()
export class EncryptionService {
  private algorithm = 'aes-256-gcm'
  private key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex')

  encrypt(text: string): string {
    const iv = crypto.randomBytes(16)
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv)
    
    let encrypted = cipher.update(text, 'utf8', 'hex')
    encrypted += cipher.final('hex')
    
    const authTag = cipher.getAuthTag()
    
    return `${iv.toString('hex')}:${authTag.toString('hex')}:${encrypted}`
  }

  decrypt(encryptedText: string): string {
    const [ivHex, authTagHex, encrypted] = encryptedText.split(':')
    
    const iv = Buffer.from(ivHex, 'hex')
    const authTag = Buffer.from(authTagHex, 'hex')
    const decipher = crypto.createDecipheriv(this.algorithm, this.key, iv)
    
    decipher.setAuthTag(authTag)
    
    let decrypted = decipher.update(encrypted, 'hex', 'utf8')
    decrypted += decipher.final('utf8')
    
    return decrypted
  }
}
```

## 8. 监控与日志策略

### 8.1 应用监控

#### 8.1.1 健康检查
```typescript
// apps/api-gateway/src/health/health.controller.ts
import { Controller, Get } from '@nestjs/common'
import { HealthCheck, HealthCheckService, PrismaHealthIndicator, RedisHealthIndicator } from '@nestjs/terminus'

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private prisma: PrismaHealthIndicator,
    private redis: RedisHealthIndicator
  ) {}

  @Get()
  @HealthCheck()
  check() {
    return this.health.check([
      () => this.prisma.pingCheck('database'),
      () => this.redis.pingCheck('redis'),
      () => this.checkDiskSpace(),
      () => this.checkMemory()
    ])
  }

  private async checkDiskSpace() {
    const diskUsage = await this.getDiskUsage()
    return {
      disk: {
        status: diskUsage < 90 ? 'up' : 'down',
        usage: `${diskUsage}%`
      }
    }
  }

  private async checkMemory() {
    const memUsage = process.memoryUsage()
    return {
      memory: {
        status: 'up',
        heapUsed: `${Math.round(memUsage.heapUsed / 1024 / 1024)}MB`,
        heapTotal: `${Math.round(memUsage.heapTotal / 1024 / 1024)}MB`
      }
    }
  }
}
```

#### 8.1.2 性能监控
```typescript
// libs/common/interceptors/performance.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common'
import { Observable } from 'rxjs'
import { tap } from 'rxjs/operators'
import { PrometheusService } from '@/monitoring/prometheus.service'

@Injectable()
export class PerformanceInterceptor implements NestInterceptor {
  constructor(private prometheus: PrometheusService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest()
    const { method, url } = request
    const startTime = Date.now()

    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - startTime
        
        // 记录到Prometheus
        this.prometheus.recordHttpRequest(method, url, duration)
        
        // 慢查询告警
        if (duration > 2000) {
          this.prometheus.recordSlowRequest(method, url, duration)
        }
      })
    )
  }
}
```

### 8.2 日志管理

#### 8.2.1 结构化日志
```typescript
// libs/logger/logger.service.ts
import { Injectable, LoggerService } from '@nestjs/common'
import * as winston from 'winston'

@Injectable()
export class CustomLogger implements LoggerService {
  private logger: winston.Logger

  constructor() {
    this.logger = winston.createLogger({
      level: process.env.LOG_LEVEL || 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
      ),
      defaultMeta: {
        service: process.env.SERVICE_NAME,
        environment: process.env.NODE_ENV
      },
      transports: [
        new winston.transports.Console(),
        new winston.transports.File({ 
          filename: 'logs/error.log', 
          level: 'error' 
        }),
        new winston.transports.File({ 
          filename: 'logs/combined.log' 
        })
      ]
    })
  }

  log(message: string, context?: string) {
    this.logger.info(message, { context })
  }

  error(message: string, trace?: string, context?: string) {
    this.logger.error(message, { trace, context })
  }

  warn(message: string, context?: string) {
    this.logger.warn(message, { context })
  }

  debug(message: string, context?: string) {
    this.logger.debug(message, { context })
  }

  verbose(message: string, context?: string) {
    this.logger.verbose(message, { context })
  }
}
```

## 9. 灾难恢复

### 9.1 数据备份策略

#### 9.1.1 数据库备份
```bash
#!/bin/bash
# scripts/backup-database.sh

# 配置
BACKUP_DIR="/backups/postgresql"
RETENTION_DAYS=30
DB_NAME="proposal_db"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 全量备份
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME -F c -f "$BACKUP_DIR/full_backup_$TIMESTAMP.dump"

# 上传到OSS
ossutil cp "$BACKUP_DIR/full_backup_$TIMESTAMP.dump" "oss://proposal-backups/database/"

# 清理旧备份
find $BACKUP_DIR -name "*.dump" -mtime +$RETENTION_DAYS -delete

# 验证备份
pg_restore --list "$BACKUP_DIR/full_backup_$TIMESTAMP.dump" > /dev/null
if [ $? -eq 0 ]; then
    echo "Backup successful: full_backup_$TIMESTAMP.dump"
else
    echo "Backup verification failed!"
    exit 1
fi
```

#### 9.1.2 增量备份
```bash
#!/bin/bash
# scripts/incremental-backup.sh

# WAL归档配置
# postgresql.conf:
# wal_level = replica
# archive_mode = on
# archive_command = 'ossutil cp %p oss://proposal-backups/wal/%f'
```

### 9.2 故障恢复

#### 9.2.1 数据库恢复
```bash
#!/bin/bash
# scripts/restore-database.sh

BACKUP_FILE=$1

# 停止应用
kubectl scale deployment --all --replicas=0 -n proposal-system

# 恢复数据库
pg_restore -h $DB_HOST -U $DB_USER -d $DB_NAME -c $BACKUP_FILE

# 验证数据完整性
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) FROM users;"

# 重启应用
kubectl scale deployment --all --replicas=3 -n proposal-system
```

## 10. 技术债务管理

### 10.1 代码质量

#### 10.1.1 代码审查流程
```yaml
# .gitlab-ci.yml
stages:
  - lint
  - test
  - build
  - deploy

lint:
  stage: lint
  script:
    - npm run lint
    - npm run format:check
  only:
    - merge_requests

test:
  stage: test
  script:
    - npm run test:unit
    - npm run test:e2e
  coverage: '/Statements\s*:\s*(\d+\.\d+)%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml
```

#### 10.1.2 技术债务追踪
```typescript
// 使用TODO注释标记技术债务
/**
 * TODO: 优化查询性能
 * @debt 性能优化
 * @priority high
 * @estimate 2天
 * @created 2026-02-04
 */
async function getProposals() {
  // 当前实现
}
```

## 11. 总结

本技术架构文档详细描述了提案展示系统的整体架构设计，包括：

1. **微服务架构**: 12个核心服务，独立部署，故障隔离
2. **技术栈**: Next.js 14 + Nest.js + PostgreSQL + Redis
3. **云原生**: Kubernetes编排，Docker容器化
4. **高性能**: 多级缓存，CDN加速，读写分离
5. **高可用**: 99.9%可用性，自动扩缩容
6. **安全防护**: OWASP Top 10防护，数据加密
7. **监控日志**: Prometheus + ELK Stack
8. **灾难恢复**: 自动备份，快速恢复

该架构支持：
- 10,000+并发用户
- P95响应时间<2秒
- 99.9%系统可用性
- 符合中国数据合规要求

---
**文档版本**: 1.0  
**最后更新**: 2026年2月4日  
**维护团队**: 技术架构组
