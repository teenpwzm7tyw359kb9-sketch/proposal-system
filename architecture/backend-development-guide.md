# 后端开发规范文档
## 提案展示系统后端开发指南

**版本**: 1.0
**技术栈**: Node.js + Nest.js | PostgreSQL | Redis
**更新日期**: 2026-02-04

---

## 📋 目录

1. [项目结构](#1-项目结构)
2. [技术栈详解](#2-技术栈详解)
3. [架构设计](#3-架构设计)
4. [API开发规范](#4-api开发规范)
5. [AI服务抽象层](#5-ai服务抽象层)
6. [自动保存机制](#6-自动保存机制)
7. [版本控制系统](#7-版本控制系统)
8. [ERP集成](#8-erp集成)
9. [测试规范](#9-测试规范)

---

## 1. 项目结构

```
proposal-system-backend/
├── src/
│   ├── main.ts                       # 应用入口
│   ├── app.module.ts                 # 根模块
│   │
│   ├── modules/                      # 功能模块
│   │   ├── auth/                     # 认证授权
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── strategies/
│   │   │   │   ├── jwt.strategy.ts
│   │   │   │   └── local.strategy.ts
│   │   │   └── guards/
│   │   │       ├── jwt-auth.guard.ts
│   │   │       └── roles.guard.ts
│   │   │
│   │   ├── proposals/                # 提案管理
│   │   │   ├── proposals.controller.ts
│   │   │   ├── proposals.service.ts
│   │   │   ├── proposals.module.ts
│   │   │   ├── dto/
│   │   │   │   ├── create-proposal.dto.ts
│   │   │   │   └── update-proposal.dto.ts
│   │   │   └── entities/
│   │   │       └── proposal.entity.ts
│   │   │
│   │   ├── versions/                 # 版本管理
│   │   │   ├── versions.controller.ts
│   │   │   ├── versions.service.ts
│   │   │   ├── versions.module.ts
│   │   │   └── version-diff.service.ts
│   │   │
│   │   ├── autosave/                 # 自动保存
│   │   │   ├── autosave.controller.ts
│   │   │   ├── autosave.service.ts
│   │   │   └── autosave.module.ts
│   │   │
│   │   ├── quotations/               # 产品报价
│   │   │   ├── quotations.controller.ts
│   │   │   ├── quotations.service.ts
│   │   │   ├── quotations.module.ts
│   │   │   └── products/
│   │   │       ├── products.controller.ts
│   │   │       └── products.service.ts
│   │   │
│   │   ├── ai/                       # AI集成
│   │   │   ├── ai.controller.ts
│   │   │   ├── ai.service.ts
│   │   │   ├── ai.module.ts
│   │   │   ├── providers/
│   │   │   │   ├── ai-provider.interface.ts
│   │   │   │   ├── openai.provider.ts
│   │   │   │   ├── claude.provider.ts
│   │   │   │   └── gemini.provider.ts
│   │   │   └── strategies/
│   │   │       ├── context-ai.strategy.ts
│   │   │       └── global-ai.strategy.ts
│   │   │
│   │   ├── assets/                   # 素材库
│   │   │   ├── assets.controller.ts
│   │   │   ├── assets.service.ts
│   │   │   └── assets.module.ts
│   │   │
│   │   ├── erp/                      # ERP集成
│   │   │   ├── erp.controller.ts
│   │   │   ├── erp.service.ts
│   │   │   ├── erp.module.ts
│   │   │   └── adapters/
│   │   │       ├── yonyou.adapter.ts
│   │   │       ├── kingdee.adapter.ts
│   │   │       └── sap.adapter.ts
│   │   │
│   │   └── analytics/                # 分析统计
│   │       ├── analytics.controller.ts
│   │       └── analytics.service.ts
│   │
│   ├── common/                       # 通用模块
│   │   ├── decorators/
│   │   │   ├── roles.decorator.ts
│   │   │   └── current-user.decorator.ts
│   │   ├── filters/
│   │   │   └── http-exception.filter.ts
│   │   ├── interceptors/
│   │   │   ├── logging.interceptor.ts
│   │   │   └── transform.interceptor.ts
│   │   ├── pipes/
│   │   │   └── validation.pipe.ts
│   │   └── guards/
│   │       └── throttle.guard.ts
│   │
│   ├── config/                       # 配置
│   │   ├── database.config.ts
│   │   ├── redis.config.ts
│   │   ├── jwt.config.ts
│   │   └── app.config.ts
│   │
│   └── database/                     # 数据库
│       ├── migrations/
│       └── seeds/
│
├── test/                             # 测试
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env                              # 环境变量
├── .env.example
├── nest-cli.json
├── tsconfig.json
└── package.json
```

---

## 2. 技术栈详解

### 2.1 核心框架

**Nest.js**
- 模块化架构
- 依赖注入
- 装饰器模式
- TypeScript原生支持

**TypeORM**
- 数据库ORM
- 迁移管理
- 关系映射

**Redis**
- 缓存
- 会话存储
- 任务队列（Bull）

### 2.2 依赖包

```json
{
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/typeorm": "^10.0.0",
    "@nestjs/jwt": "^10.0.0",
    "@nestjs/passport": "^10.0.0",
    "@nestjs/bull": "^10.0.0",
    "typeorm": "^0.3.0",
    "pg": "^8.11.0",
    "redis": "^4.6.0",
    "bull": "^4.11.0",
    "bcrypt": "^5.1.0",
    "class-validator": "^0.14.0",
    "class-transformer": "^0.5.1",
    "openai": "^4.0.0",
    "@anthropic-ai/sdk": "^0.9.0",
    "@google/generative-ai": "^0.1.0"
  }
}
```

---

## 3. 架构设计

### 3.1 分层架构

```
┌─────────────────────────────────────┐
│         Controller Layer            │  HTTP请求处理
├─────────────────────────────────────┤
│          Service Layer              │  业务逻辑
├─────────────────────────────────────┤
│        Repository Layer             │  数据访问
├─────────────────────────────────────┤
│         Database Layer              │  PostgreSQL
└─────────────────────────────────────┘
```

### 3.2 模块依赖关系

```typescript
// app.module.ts
import { Module } from '@nestjs/common'
import { TypeOrmModule } from '@nestjs/typeorm'
import { ConfigModule } from '@nestjs/config'
import { BullModule } from '@nestjs/bull'

import { AuthModule } from './modules/auth/auth.module'
import { ProposalsModule } from './modules/proposals/proposals.module'
import { VersionsModule } from './modules/versions/versions.module'
import { AutosaveModule } from './modules/autosave/autosave.module'
import { QuotationsModule } from './modules/quotations/quotations.module'
import { AIModule } from './modules/ai/ai.module'
import { AssetsModule } from './modules/assets/assets.module'
import { ERPModule } from './modules/erp/erp.module'

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST,
      port: parseInt(process.env.DB_PORT),
      username: process.env.DB_USERNAME,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_DATABASE,
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: false, // 生产环境必须为false
      logging: process.env.NODE_ENV === 'development',
    }),
    BullModule.forRoot({
      redis: {
        host: process.env.REDIS_HOST,
        port: parseInt(process.env.REDIS_PORT),
      },
    }),
    AuthModule,
    ProposalsModule,
    VersionsModule,
    AutosaveModule,
    QuotationsModule,
    AIModule,
    AssetsModule,
    ERPModule,
  ],
})
export class AppModule {}
```

---

## 4. API开发规范

### 4.1 Controller规范

```typescript
// modules/proposals/proposals.controller.ts
import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common'
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { Roles } from '../../common/decorators/roles.decorator'
import { CurrentUser } from '../../common/decorators/current-user.decorator'
import { ProposalsService } from './proposals.service'
import { CreateProposalDto, UpdateProposalDto } from './dto'
import { User } from '../auth/entities/user.entity'

@ApiTags('proposals')
@ApiBearerAuth()
@Controller('proposals')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ProposalsController {
  constructor(private readonly proposalsService: ProposalsService) {}

  @Post()
  @Roles('admin', 'editor')
  @ApiOperation({ summary: '创建提案' })
  @ApiResponse({ status: 201, description: '创建成功' })
  @ApiResponse({ status: 400, description: '请求参数错误' })
  @ApiResponse({ status: 401, description: '未授权' })
  async create(
    @Body() createProposalDto: CreateProposalDto,
    @CurrentUser() user: User,
  ) {
    return this.proposalsService.create(createProposalDto, user.id)
  }

  @Get()
  @ApiOperation({ summary: '获取提案列表' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async findAll(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
    @Query('status') status?: string,
    @CurrentUser() user: User,
  ) {
    return this.proposalsService.findAll(user.id, { page, limit, status })
  }

  @Get(':id')
  @ApiOperation({ summary: '获取提案详情' })
  @ApiResponse({ status: 200, description: '获取成功' })
  @ApiResponse({ status: 404, description: '提案不存在' })
  async findOne(@Param('id') id: string, @CurrentUser() user: User) {
    return this.proposalsService.findOne(id, user.id)
  }

  @Patch(':id')
  @Roles('admin', 'editor')
  @ApiOperation({ summary: '更新提案' })
  @ApiResponse({ status: 200, description: '更新成功' })
  async update(
    @Param('id') id: string,
    @Body() updateProposalDto: UpdateProposalDto,
    @CurrentUser() user: User,
  ) {
    return this.proposalsService.update(id, updateProposalDto, user.id)
  }

  @Delete(':id')
  @Roles('admin', 'editor')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '删除提案' })
  @ApiResponse({ status: 204, description: '删除成功' })
  async remove(@Param('id') id: string, @CurrentUser() user: User) {
    return this.proposalsService.remove(id, user.id)
  }
}
```

### 4.2 Service规范

```typescript
// modules/proposals/proposals.service.ts
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { Proposal } from './entities/proposal.entity'
import { CreateProposalDto, UpdateProposalDto } from './dto'
import { Logger } from '@nestjs/common'

@Injectable()
export class ProposalsService {
  private readonly logger = new Logger(ProposalsService.name)

  constructor(
    @InjectRepository(Proposal)
    private readonly proposalRepository: Repository<Proposal>,
  ) {}

  async create(createProposalDto: CreateProposalDto, userId: string): Promise<Proposal> {
    this.logger.log(`Creating proposal for user ${userId}`)

    try {
      const proposal = this.proposalRepository.create({
        ...createProposalDto,
        ownerId: userId,
        slug: this.generateSlug(createProposalDto.title),
        shareToken: this.generateShareToken(),
      })

      const saved = await this.proposalRepository.save(proposal)
      this.logger.log(`Proposal created: ${saved.id}`)

      return saved
    } catch (error) {
      this.logger.error(`Failed to create proposal: ${error.message}`, error.stack)
      throw error
    }
  }

  async findAll(
    userId: string,
    options: { page: number; limit: number; status?: string },
  ): Promise<{ data: Proposal[]; total: number; page: number; limit: number }> {
    const { page, limit, status } = options

    const query = this.proposalRepository
      .createQueryBuilder('proposal')
      .where('proposal.ownerId = :userId', { userId })
      .andWhere('proposal.deletedAt IS NULL')

    if (status) {
      query.andWhere('proposal.status = :status', { status })
    }

    const [data, total] = await query
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('proposal.createdAt', 'DESC')
      .getManyAndCount()

    return {
      data,
      total,
      page,
      limit,
    }
  }

  async findOne(id: string, userId: string): Promise<Proposal> {
    const proposal = await this.proposalRepository.findOne({
      where: { id, ownerId: userId, deletedAt: null },
      relations: ['modules', 'currentVersion'],
    })

    if (!proposal) {
      throw new NotFoundException(`Proposal with ID ${id} not found`)
    }

    return proposal
  }

  async update(
    id: string,
    updateProposalDto: UpdateProposalDto,
    userId: string,
  ): Promise<Proposal> {
    const proposal = await this.findOne(id, userId)

    Object.assign(proposal, updateProposalDto)
    return this.proposalRepository.save(proposal)
  }

  async remove(id: string, userId: string): Promise<void> {
    const proposal = await this.findOne(id, userId)
    proposal.deletedAt = new Date()
    await this.proposalRepository.save(proposal)
  }

  private generateSlug(title: string): string {
    return title
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .substring(0, 100)
  }

  private generateShareToken(): string {
    return Math.random().toString(36).substring(2, 15) +
           Math.random().toString(36).substring(2, 15)
  }
}
```

### 4.3 DTO规范

```typescript
// modules/proposals/dto/create-proposal.dto.ts
import { IsString, IsOptional, IsArray, IsUUID, MaxLength } from 'class-validator'
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger'

export class CreateProposalDto {
  @ApiProperty({ description: '提案标题', example: '春江花园别墅设计方案' })
  @IsString()
  @MaxLength(255)
  title: string

  @ApiPropertyOptional({ description: '提案描述' })
  @IsString()
  @IsOptional()
  description?: string

  @ApiPropertyOptional({ description: '客户名称' })
  @IsString()
  @IsOptional()
  clientName?: string

  @ApiPropertyOptional({ description: '客户邮箱' })
  @IsString()
  @IsOptional()
  clientEmail?: string

  @ApiPropertyOptional({ description: '项目类型' })
  @IsString()
  @IsOptional()
  projectType?: string

  @ApiPropertyOptional({ description: '设计风格' })
  @IsString()
  @IsOptional()
  designStyle?: string

  @ApiPropertyOptional({ description: '关键词', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  keywords?: string[]

  @ApiPropertyOptional({ description: '模板ID' })
  @IsUUID()
  @IsOptional()
  templateId?: string
}
```

### 4.4 Entity规范

```typescript
// modules/proposals/entities/proposal.entity.ts
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm'
import { User } from '../../auth/entities/user.entity'
import { ProposalModule } from './proposal-module.entity'
import { ProposalVersion } from '../../versions/entities/proposal-version.entity'

@Entity('proposals')
export class Proposal {
  @PrimaryGeneratedColumn('uuid')
  id: string

  @Column({ length: 255 })
  title: string

  @Column({ length: 255, unique: true })
  slug: string

  @Column({ type: 'text', nullable: true })
  description: string

  @Column({ name: 'client_name', length: 200, nullable: true })
  clientName: string

  @Column({ name: 'client_email', length: 255, nullable: true })
  clientEmail: string

  @Column({ name: 'project_type', length: 50, nullable: true })
  projectType: string

  @Column({ name: 'design_style', length: 50, nullable: true })
  designStyle: string

  @Column({ type: 'text', array: true, nullable: true })
  keywords: string[]

  @Column({ name: 'cover_image_url', type: 'text', nullable: true })
  coverImageUrl: string

  @Column({ length: 20, default: 'draft' })
  status: string

  @Column({ length: 20, default: 'private' })
  visibility: string

  @Column({ name: 'password_hash', length: 255, nullable: true })
  passwordHash: string

  @Column({ name: 'share_token', length: 100, unique: true })
  shareToken: string

  @Column({ name: 'share_expires_at', type: 'timestamp with time zone', nullable: true })
  shareExpiresAt: Date

  @Column({ name: 'view_count', default: 0 })
  viewCount: number

  @Column({ name: 'owner_id', type: 'uuid' })
  ownerId: string

  @Column({ name: 'current_version_id', type: 'uuid', nullable: true })
  currentVersionId: string

  @Column({ name: 'published_at', type: 'timestamp with time zone', nullable: true })
  publishedAt: Date

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date

  @DeleteDateColumn({ name: 'deleted_at' })
  deletedAt: Date

  // 关系
  @ManyToOne(() => User)
  @JoinColumn({ name: 'owner_id' })
  owner: User

  @OneToMany(() => ProposalModule, (module) => module.proposal)
  modules: ProposalModule[]

  @ManyToOne(() => ProposalVersion)
  @JoinColumn({ name: 'current_version_id' })
  currentVersion: ProposalVersion
}
```

---

## 5. AI服务抽象层

### 5.1 AI Provider接口

```typescript
// modules/ai/providers/ai-provider.interface.ts
export interface AIGenerationParams {
  prompt: string
  context?: Record<string, any>
  parameters?: Record<string, any>
}

export interface AIGenerationResult {
  id: string
  type: 'image' | 'text'
  data: any
  urls?: string[]
  tokensUsed?: number
  cost?: number
  durationMs: number
}

export interface IAIProvider {
  readonly name: string
  readonly supportedFeatures: string[]

  generateImage(params: AIGenerationParams): Promise<AIGenerationResult>
  generateText(params: AIGenerationParams): Promise<AIGenerationResult>
  isAvailable(): Promise<boolean>
}
```

### 5.2 OpenAI Provider实现

```typescript
// modules/ai/providers/openai.provider.ts
import { Injectable, Logger } from '@nestjs/common'
import OpenAI from 'openai'
import { IAIProvider, AIGenerationParams, AIGenerationResult } from './ai-provider.interface'

@Injectable()
export class OpenAIProvider implements IAIProvider {
  private readonly logger = new Logger(OpenAIProvider.name)
  readonly name = 'openai'
  readonly supportedFeatures = ['image_generation', 'text_generation', 'chat']

  private client: OpenAI

  constructor(apiKey: string) {
    this.client = new OpenAI({ apiKey })
  }

  async generateImage(params: AIGenerationParams): Promise<AIGenerationResult> {
    const startTime = Date.now()

    try {
      const response = await this.client.images.generate({
        model: params.parameters?.model || 'dall-e-3',
        prompt: params.prompt,
        n: params.parameters?.count || 1,
        size: params.parameters?.size || '1024x1024',
        quality: params.parameters?.quality || 'standard',
      })

      const durationMs = Date.now() - startTime

      return {
        id: crypto.randomUUID(),
        type: 'image',
        data: response.data,
        urls: response.data.map((img) => img.url),
        cost: this.calculateImageCost(params.parameters?.model, params.parameters?.count),
        durationMs,
      }
    } catch (error) {
      this.logger.error(`OpenAI image generation failed: ${error.message}`, error.stack)
      throw error
    }
  }

  async generateText(params: AIGenerationParams): Promise<AIGenerationResult> {
    const startTime = Date.now()

    try {
      const response = await this.client.chat.completions.create({
        model: params.parameters?.model || 'gpt-4-turbo',
        messages: [
          {
            role: 'system',
            content: this.buildSystemPrompt(params.context),
          },
          {
            role: 'user',
            content: params.prompt,
          },
        ],
        max_tokens: params.parameters?.maxTokens || 2000,
        temperature: params.parameters?.temperature || 0.7,
      })

      const durationMs = Date.now() - startTime

      return {
        id: crypto.randomUUID(),
        type: 'text',
        data: response.choices[0].message.content,
        tokensUsed: response.usage.total_tokens,
        cost: this.calculateTextCost(params.parameters?.model, response.usage.total_tokens),
        durationMs,
      }
    } catch (error) {
      this.logger.error(`OpenAI text generation failed: ${error.message}`, error.stack)
      throw error
    }
  }

  async isAvailable(): Promise<boolean> {
    try {
      await this.client.models.list()
      return true
    } catch {
      return false
    }
  }

  private buildSystemPrompt(context?: Record<string, any>): string {
    if (!context) return '你是一个专业的室内设计文案撰写助手。'

    return `你是一个专业的室内设计文案撰写助手。
项目信息：
- 项目名称：${context.projectName || '未知'}
- 设计风格：${context.designStyle || '未知'}
- 关键词：${context.keywords?.join('、') || '无'}

请根据以上信息生成专业、有吸引力的设计文案。`
  }

  private calculateImageCost(model: string, count: number): number {
    const prices = {
      'dall-e-3': 0.04,
      'dall-e-2': 0.02,
    }
    return (prices[model] || 0.04) * count
  }

  private calculateTextCost(model: string, tokens: number): number {
    const prices = {
      'gpt-4-turbo': 0.01,
      'gpt-4': 0.03,
      'gpt-3.5-turbo': 0.002,
    }
    return ((prices[model] || 0.01) * tokens) / 1000
  }
}
```


### 5.3 AI Service（统一服务层）

```typescript
// modules/ai/ai.service.ts
import { Injectable, Logger, BadRequestException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { InjectQueue } from '@nestjs/bull'
import { Queue } from 'bull'
import { AIGeneration } from './entities/ai-generation.entity'
import { UserAIConfig } from './entities/user-ai-config.entity'
import { OpenAIProvider } from './providers/openai.provider'
import { ClaudeProvider } from './providers/claude.provider'
import { GeminiProvider } from './providers/gemini.provider'
import { IAIProvider } from './providers/ai-provider.interface'

@Injectable()
export class AIService {
  private readonly logger = new Logger(AIService.name)
  private providers: Map<string, IAIProvider> = new Map()

  constructor(
    @InjectRepository(AIGeneration)
    private readonly generationRepository: Repository<AIGeneration>,
    @InjectRepository(UserAIConfig)
    private readonly configRepository: Repository<UserAIConfig>,
    @InjectQueue('ai-generation')
    private readonly aiQueue: Queue,
  ) {}

  async generateWithContext(
    userId: string,
    params: {
      proposalId: string
      moduleType: string
      generationType: 'image' | 'text'
      prompt: string
      context?: Record<string, any>
      parameters?: Record<string, any>
      provider?: string
    },
  ): Promise<{ generationId: string; status: string }> {
    this.logger.log(`Context AI generation for user ${userId}, module ${params.moduleType}`)

    // 创建生成记录
    const generation = this.generationRepository.create({
      userId,
      proposalId: params.proposalId,
      moduleType: params.moduleType,
      generationType: params.generationType,
      triggerSource: 'module_context',
      providerName: params.provider || await this.getPreferredProvider(userId),
      prompt: params.prompt,
      promptContext: params.context,
      parameters: params.parameters,
      status: 'pending',
    })

    const saved = await this.generationRepository.save(generation)

    // 添加到队列异步处理
    await this.aiQueue.add('generate', {
      generationId: saved.id,
      userId,
      params,
    })

    return {
      generationId: saved.id,
      status: 'processing',
    }
  }

  async generateGlobal(
    userId: string,
    params: {
      generationType: 'image' | 'text'
      prompt: string
      parameters?: Record<string, any>
      provider?: string
    },
  ): Promise<{ generationId: string; status: string }> {
    this.logger.log(`Global AI generation for user ${userId}`)

    const generation = this.generationRepository.create({
      userId,
      generationType: params.generationType,
      triggerSource: 'global_tool',
      providerName: params.provider || await this.getPreferredProvider(userId),
      prompt: params.prompt,
      parameters: params.parameters,
      status: 'pending',
    })

    const saved = await this.generationRepository.save(generation)

    await this.aiQueue.add('generate', {
      generationId: saved.id,
      userId,
      params,
    })

    return {
      generationId: saved.id,
      status: 'processing',
    }
  }

  async processGeneration(generationId: string, userId: string, params: any): Promise<void> {
    const generation = await this.generationRepository.findOne({
      where: { id: generationId, userId },
    })

    if (!generation) {
      throw new BadRequestException('Generation not found')
    }

    try {
      generation.status = 'processing'
      await this.generationRepository.save(generation)

      // 获取AI Provider
      const provider = await this.getProvider(userId, generation.providerName)

      // 执行生成
      const startTime = Date.now()
      let result

      if (params.generationType === 'image') {
        result = await provider.generateImage({
          prompt: params.prompt,
          context: params.context,
          parameters: params.parameters,
        })
      } else {
        result = await provider.generateText({
          prompt: params.prompt,
          context: params.context,
          parameters: params.parameters,
        })
      }

      // 更新生成记录
      generation.status = 'completed'
      generation.resultData = result.data
      generation.resultUrls = result.urls
      generation.tokensUsed = result.tokensUsed
      generation.cost = result.cost
      generation.durationMs = Date.now() - startTime

      await this.generationRepository.save(generation)

      this.logger.log(`Generation ${generationId} completed in ${generation.durationMs}ms`)
    } catch (error) {
      this.logger.error(`Generation ${generationId} failed: ${error.message}`, error.stack)

      generation.status = 'failed'
      generation.errorMessage = error.message
      await this.generationRepository.save(generation)
    }
  }

  private async getProvider(userId: string, providerName: string): Promise<IAIProvider> {
    // 从缓存获取
    if (this.providers.has(`${userId}:${providerName}`)) {
      return this.providers.get(`${userId}:${providerName}`)
    }

    // 获取用户配置
    const config = await this.configRepository.findOne({
      where: { userId, providerName, isActive: true },
    })

    if (!config) {
      throw new BadRequestException(`AI provider ${providerName} not configured`)
    }

    // 创建Provider实例
    let provider: IAIProvider

    switch (providerName) {
      case 'openai':
        provider = new OpenAIProvider(this.decryptApiKey(config.apiKeyEncrypted))
        break
      case 'claude':
        provider = new ClaudeProvider(this.decryptApiKey(config.apiKeyEncrypted))
        break
      case 'gemini':
        provider = new GeminiProvider(this.decryptApiKey(config.apiKeyEncrypted))
        break
      default:
        throw new BadRequestException(`Unsupported provider: ${providerName}`)
    }

    // 缓存Provider
    this.providers.set(`${userId}:${providerName}`, provider)

    return provider
  }

  private async getPreferredProvider(userId: string): Promise<string> {
    const config = await this.configRepository.findOne({
      where: { userId, isActive: true },
      order: { createdAt: 'ASC' },
    })

    return config?.providerName || 'openai'
  }

  private decryptApiKey(encrypted: string): string {
    // 实现解密逻辑
    // 使用crypto模块解密存储的API Key
    return encrypted // 简化示例
  }
}
```

---

## 6. 自动保存机制

### 6.1 自动保存Service

```typescript
// modules/autosave/autosave.service.ts
import { Injectable, Logger } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository, LessThan } from 'typeorm'
import { Cron, CronExpression } from '@nestjs/schedule'
import { AutosaveSnapshot } from './entities/autosave-snapshot.entity'

@Injectable()
export class AutosaveService {
  private readonly logger = new Logger(AutosaveService.name)

  constructor(
    @InjectRepository(AutosaveSnapshot)
    private readonly snapshotRepository: Repository<AutosaveSnapshot>,
  ) {}

  async saveSnapshot(
    proposalId: string,
    userId: string,
    sessionId: string,
    content: any,
    contentDelta?: any,
  ): Promise<AutosaveSnapshot> {
    this.logger.debug(`Saving autosave snapshot for proposal ${proposalId}`)

    const snapshot = this.snapshotRepository.create({
      proposalId,
      userId,
      sessionId,
      content,
      contentDelta,
    })

    return this.snapshotRepository.save(snapshot)
  }

  async getLatestSnapshot(
    proposalId: string,
    sessionId: string,
  ): Promise<AutosaveSnapshot | null> {
    return this.snapshotRepository.findOne({
      where: { proposalId, sessionId },
      order: { createdAt: 'DESC' },
    })
  }

  async getSnapshotHistory(
    proposalId: string,
    limit: number = 10,
  ): Promise<AutosaveSnapshot[]> {
    return this.snapshotRepository.find({
      where: { proposalId },
      order: { createdAt: 'DESC' },
      take: limit,
    })
  }

  // 定时清理旧快照（每小时执行）
  @Cron(CronExpression.EVERY_HOUR)
  async cleanupOldSnapshots(): Promise<void> {
    const cutoffDate = new Date()
    cutoffDate.setHours(cutoffDate.getHours() - 24)

    const result = await this.snapshotRepository.delete({
      createdAt: LessThan(cutoffDate),
    })

    this.logger.log(`Cleaned up ${result.affected} old autosave snapshots`)
  }
}
```

### 6.2 自动保存Controller

```typescript
// modules/autosave/autosave.controller.ts
import { Controller, Post, Get, Body, Param, Query, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { CurrentUser } from '../../common/decorators/current-user.decorator'
import { AutosaveService } from './autosave.service'
import { User } from '../auth/entities/user.entity'

@ApiTags('autosave')
@ApiBearerAuth()
@Controller('proposals/:proposalId/autosave')
@UseGuards(JwtAuthGuard)
export class AutosaveController {
  constructor(private readonly autosaveService: AutosaveService) {}

  @Post()
  @ApiOperation({ summary: '保存自动保存快照' })
  async saveSnapshot(
    @Param('proposalId') proposalId: string,
    @Body() body: { sessionId: string; content?: any; contentDelta?: any },
    @CurrentUser() user: User,
  ) {
    const snapshot = await this.autosaveService.saveSnapshot(
      proposalId,
      user.id,
      body.sessionId,
      body.content,
      body.contentDelta,
    )

    return {
      success: true,
      data: {
        snapshotId: snapshot.id,
        createdAt: snapshot.createdAt,
        nextAutosaveIn: 3, // 秒
      },
    }
  }

  @Get('latest')
  @ApiOperation({ summary: '获取最新自动保存快照' })
  async getLatest(
    @Param('proposalId') proposalId: string,
    @Query('sessionId') sessionId: string,
  ) {
    const snapshot = await this.autosaveService.getLatestSnapshot(proposalId, sessionId)

    return {
      success: true,
      data: snapshot,
    }
  }
}
```

---

## 7. 版本控制系统

### 7.1 版本Service

```typescript
// modules/versions/versions.service.ts
import { Injectable, Logger, NotFoundException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { ProposalVersion } from './entities/proposal-version.entity'
import { VersionDiff } from './entities/version-diff.entity'
import { VersionDiffService } from './version-diff.service'

@Injectable()
export class VersionsService {
  private readonly logger = new Logger(VersionsService.name)

  constructor(
    @InjectRepository(ProposalVersion)
    private readonly versionRepository: Repository<ProposalVersion>,
    @InjectRepository(VersionDiff)
    private readonly diffRepository: Repository<VersionDiff>,
    private readonly diffService: VersionDiffService,
  ) {}

  async createVersion(
    proposalId: string,
    userId: string,
    content: any,
    description?: string,
    tags?: string[],
  ): Promise<ProposalVersion> {
    this.logger.log(`Creating version for proposal ${proposalId}`)

    // 获取最新版本号
    const latestVersion = await this.versionRepository.findOne({
      where: { proposalId },
      order: { versionNumber: 'DESC' },
    })

    const versionNumber = (latestVersion?.versionNumber || 0) + 1

    // 计算内容哈希
    const contentHash = this.calculateHash(content)

    const version = this.versionRepository.create({
      proposalId,
      versionNumber,
      title: `版本 ${versionNumber}`,
      description,
      content,
      contentHash,
      tags,
      isSnapshot: false,
      snapshotType: 'manual',
      createdBy: userId,
    })

    return this.versionRepository.save(version)
  }

  async getVersionHistory(
    proposalId: string,
    page: number = 1,
    limit: number = 20,
  ): Promise<{ versions: ProposalVersion[]; total: number }> {
    const [versions, total] = await this.versionRepository.findAndCount({
      where: { proposalId },
      order: { versionNumber: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
      relations: ['createdByUser'],
    })

    return { versions, total }
  }

  async getVersion(versionId: string): Promise<ProposalVersion> {
    const version = await this.versionRepository.findOne({
      where: { id: versionId },
      relations: ['createdByUser'],
    })

    if (!version) {
      throw new NotFoundException(`Version ${versionId} not found`)
    }

    return version
  }

  async compareVersions(
    proposalId: string,
    fromVersionId: string,
    toVersionId: string,
  ): Promise<any> {
    // 检查是否已有缓存的差异
    let diff = await this.diffRepository.findOne({
      where: { proposalId, fromVersionId, toVersionId },
    })

    if (!diff) {
      // 计算差异
      const fromVersion = await this.getVersion(fromVersionId)
      const toVersion = await this.getVersion(toVersionId)

      const diffResult = this.diffService.calculateDiff(
        fromVersion.content,
        toVersion.content,
      )

      // 保存差异
      diff = this.diffRepository.create({
        proposalId,
        fromVersionId,
        toVersionId,
        diffSummary: diffResult.summary,
        changesCount: diffResult.changesCount,
      })

      await this.diffRepository.save(diff)
    }

    return {
      fromVersion: await this.getVersion(fromVersionId),
      toVersion: await this.getVersion(toVersionId),
      diffSummary: diff.diffSummary,
      detailedDiff: this.diffService.getDetailedDiff(diff.diffSummary),
    }
  }

  async restoreVersion(
    proposalId: string,
    versionId: string,
    userId: string,
  ): Promise<ProposalVersion> {
    const versionToRestore = await this.getVersion(versionId)

    // 创建新版本（恢复操作）
    const newVersion = await this.createVersion(
      proposalId,
      userId,
      versionToRestore.content,
      `恢复到版本 ${versionToRestore.versionNumber}`,
      ['恢复'],
    )

    this.logger.log(
      `Restored proposal ${proposalId} to version ${versionToRestore.versionNumber}`,
    )

    return newVersion
  }

  private calculateHash(content: any): string {
    const crypto = require('crypto')
    return crypto.createHash('sha256').update(JSON.stringify(content)).digest('hex')
  }
}
```

### 7.2 版本差异Service

```typescript
// modules/versions/version-diff.service.ts
import { Injectable } from '@nestjs/common'

@Injectable()
export class VersionDiffService {
  calculateDiff(oldContent: any, newContent: any): { summary: any; changesCount: number } {
    const summary = {
      modulesAdded: [],
      modulesRemoved: [],
      modulesModified: [],
    }

    let changesCount = 0

    // 比较模块
    const oldModules = oldContent.modules || []
    const newModules = newContent.modules || []

    const oldModuleIds = new Set(oldModules.map((m) => m.id))
    const newModuleIds = new Set(newModules.map((m) => m.id))

    // 找出新增的模块
    for (const module of newModules) {
      if (!oldModuleIds.has(module.id)) {
        summary.modulesAdded.push(module.type)
        changesCount++
      }
    }

    // 找出删除的模块
    for (const module of oldModules) {
      if (!newModuleIds.has(module.id)) {
        summary.modulesRemoved.push(module.type)
        changesCount++
      }
    }

    // 找出修改的模块
    for (const newModule of newModules) {
      const oldModule = oldModules.find((m) => m.id === newModule.id)
      if (oldModule && JSON.stringify(oldModule) !== JSON.stringify(newModule)) {
        summary.modulesModified.push(newModule.type)
        changesCount++
      }
    }

    return { summary, changesCount }
  }

  getDetailedDiff(summary: any): any {
    // 返回详细的差异信息
    return {
      modulesAdded: summary.modulesAdded,
      modulesRemoved: summary.modulesRemoved,
      modulesModified: summary.modulesModified,
    }
  }
}
```

---

## 8. ERP集成

### 8.1 ERP Adapter接口

```typescript
// modules/erp/adapters/erp-adapter.interface.ts
export interface ERPCustomer {
  erpCustomerId: string
  name: string
  email?: string
  phone?: string
  address?: string
  [key: string]: any
}

export interface ERPProduct {
  erpProductId: string
  sku: string
  name: string
  price: number
  stock: number
  [key: string]: any
}

export interface IERPAdapter {
  readonly name: string

  // 客户数据同步
  syncCustomers(): Promise<ERPCustomer[]>
  getCustomer(erpCustomerId: string): Promise<ERPCustomer>
  createCustomer(customer: Partial<ERPCustomer>): Promise<ERPCustomer>
  updateCustomer(erpCustomerId: string, customer: Partial<ERPCustomer>): Promise<ERPCustomer>

  // 产品数据同步
  syncProducts(): Promise<ERPProduct[]>
  getProduct(erpProductId: string): Promise<ERPProduct>
  updateProductStock(erpProductId: string, quantity: number): Promise<void>

  // 提案数据推送
  pushProposal(proposalData: any): Promise<{ erpProposalId: string }>

  // 预约数据同步
  syncAppointments(): Promise<any[]>
  createAppointment(appointment: any): Promise<{ erpAppointmentId: string }>

  // 连接测试
  testConnection(): Promise<boolean>
}
```

### 8.2 用友ERP Adapter

```typescript
// modules/erp/adapters/yonyou.adapter.ts
import { Injectable, Logger } from '@nestjs/common'
import axios, { AxiosInstance } from 'axios'
import { IERPAdapter, ERPCustomer, ERPProduct } from './erp-adapter.interface'

@Injectable()
export class YonyouAdapter implements IERPAdapter {
  private readonly logger = new Logger(YonyouAdapter.name)
  readonly name = 'yonyou'
  private client: AxiosInstance

  constructor(
    private readonly apiEndpoint: string,
    private readonly apiKey: string,
  ) {
    this.client = axios.create({
      baseURL: apiEndpoint,
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      timeout: 30000,
    })
  }

  async syncCustomers(): Promise<ERPCustomer[]> {
    try {
      const response = await this.client.get('/api/customers')
      return response.data.map(this.mapCustomer)
    } catch (error) {
      this.logger.error(`Failed to sync customers: ${error.message}`)
      throw error
    }
  }

  async getCustomer(erpCustomerId: string): Promise<ERPCustomer> {
    const response = await this.client.get(`/api/customers/${erpCustomerId}`)
    return this.mapCustomer(response.data)
  }

  async createCustomer(customer: Partial<ERPCustomer>): Promise<ERPCustomer> {
    const response = await this.client.post('/api/customers', customer)
    return this.mapCustomer(response.data)
  }

  async updateCustomer(
    erpCustomerId: string,
    customer: Partial<ERPCustomer>,
  ): Promise<ERPCustomer> {
    const response = await this.client.put(`/api/customers/${erpCustomerId}`, customer)
    return this.mapCustomer(response.data)
  }

  async syncProducts(): Promise<ERPProduct[]> {
    const response = await this.client.get('/api/products')
    return response.data.map(this.mapProduct)
  }

  async getProduct(erpProductId: string): Promise<ERPProduct> {
    const response = await this.client.get(`/api/products/${erpProductId}`)
    return this.mapProduct(response.data)
  }

  async updateProductStock(erpProductId: string, quantity: number): Promise<void> {
    await this.client.patch(`/api/products/${erpProductId}/stock`, { quantity })
  }

  async pushProposal(proposalData: any): Promise<{ erpProposalId: string }> {
    const response = await this.client.post('/api/proposals', proposalData)
    return { erpProposalId: response.data.id }
  }

  async syncAppointments(): Promise<any[]> {
    const response = await this.client.get('/api/appointments')
    return response.data
  }

  async createAppointment(appointment: any): Promise<{ erpAppointmentId: string }> {
    const response = await this.client.post('/api/appointments', appointment)
    return { erpAppointmentId: response.data.id }
  }

  async testConnection(): Promise<boolean> {
    try {
      await this.client.get('/api/health')
      return true
    } catch {
      return false
    }
  }

  private mapCustomer(data: any): ERPCustomer {
    return {
      erpCustomerId: data.id,
      name: data.name,
      email: data.email,
      phone: data.phone,
      address: data.address,
    }
  }

  private mapProduct(data: any): ERPProduct {
    return {
      erpProductId: data.id,
      sku: data.sku,
      name: data.name,
      price: data.price,
      stock: data.stock,
    }
  }
}
```

---

## 9. 测试规范

### 9.1 单元测试

```typescript
// modules/proposals/proposals.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing'
import { getRepositoryToken } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { ProposalsService } from './proposals.service'
import { Proposal } from './entities/proposal.entity'

describe('ProposalsService', () => {
  let service: ProposalsService
  let repository: Repository<Proposal>

  const mockRepository = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    createQueryBuilder: jest.fn(),
  }

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ProposalsService,
        {
          provide: getRepositoryToken(Proposal),
          useValue: mockRepository,
        },
      ],
    }).compile()

    service = module.get<ProposalsService>(ProposalsService)
    repository = module.get<Repository<Proposal>>(getRepositoryToken(Proposal))
  })

  it('should be defined', () => {
    expect(service).toBeDefined()
  })

  describe('create', () => {
    it('should create a proposal', async () => {
      const createDto = {
        title: 'Test Proposal',
        description: 'Test Description',
      }

      const mockProposal = {
        id: 'uuid',
        ...createDto,
        slug: 'test-proposal',
        shareToken: 'abc123',
      }

      mockRepository.create.mockReturnValue(mockProposal)
      mockRepository.save.mockResolvedValue(mockProposal)

      const result = await service.create(createDto, 'user-id')

      expect(result).toEqual(mockProposal)
      expect(mockRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          title: createDto.title,
          ownerId: 'user-id',
        }),
      )
    })
  })
})
```

### 9.2 集成测试

```typescript
// test/integration/proposals.e2e-spec.ts
import { Test, TestingModule } from '@nestjs/testing'
import { INestApplication } from '@nestjs/common'
import * as request from 'supertest'
import { AppModule } from '../src/app.module'

describe('Proposals (e2e)', () => {
  let app: INestApplication
  let authToken: string

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile()

    app = moduleFixture.createNestApplication()
    await app.init()

    // 登录获取token
    const loginResponse = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'test@example.com', password: 'password' })

    authToken = loginResponse.body.data.access_token
  })

  afterAll(async () => {
    await app.close()
  })

  it('/proposals (POST)', () => {
    return request(app.getHttpServer())
      .post('/proposals')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Test Proposal',
        description: 'Test Description',
      })
      .expect(201)
      .expect((res) => {
        expect(res.body.success).toBe(true)
        expect(res.body.data).toHaveProperty('id')
        expect(res.body.data.title).toBe('Test Proposal')
      })
  })

  it('/proposals (GET)', () => {
    return request(app.getHttpServer())
      .get('/proposals')
      .set('Authorization', `Bearer ${authToken}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.success).toBe(true)
        expect(Array.isArray(res.body.data.proposals)).toBe(true)
      })
  })
})
```

---

## 附录：环境变量配置

```bash
# .env.example

# 应用配置
NODE_ENV=development
PORT=3000
API_PREFIX=api/v1

# 数据库配置
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=password
DB_DATABASE=proposal_system

# Redis配置
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT配置
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=3600

# AI Provider配置
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_API_KEY=...

# 文件存储配置
STORAGE_TYPE=s3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_S3_BUCKET=...
AWS_REGION=cn-north-1

# 阿里云OSS配置（可选）
ALIYUN_ACCESS_KEY_ID=...
ALIYUN_ACCESS_KEY_SECRET=...
ALIYUN_OSS_BUCKET=...
ALIYUN_OSS_REGION=oss-cn-beijing

# 日志配置
LOG_LEVEL=debug
LOG_FILE_PATH=./logs
```

---

## 附录：常用命令

```bash
# 开发
npm run start:dev

# 构建
npm run build

# 生产运行
npm run start:prod

# 测试
npm run test
npm run test:watch
npm run test:cov
npm run test:e2e

# 数据库迁移
npm run migration:generate -- -n MigrationName
npm run migration:run
npm run migration:revert

# 代码检查
npm run lint
npm run format
```
