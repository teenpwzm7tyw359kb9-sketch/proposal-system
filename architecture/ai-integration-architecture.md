# AI集成架构文档

## 文档信息
- **版本**: 1.0
- **最后更新**: 2026年2月4日
- **适用范围**: 提案展示系统AI功能集成

## 目录
1. [AI架构概述](#1-ai架构概述)
2. [多提供商架构](#2-多提供商架构)
3. [OpenAI集成](#3-openai集成)
4. [Anthropic Claude集成](#4-anthropic-claude集成)
5. [Google Gemini集成](#5-google-gemini集成)
6. [统一服务抽象层](#6-统一服务抽象层)
7. [配额管理](#7-配额管理)
8. [异步任务队列](#8-异步任务队列)
9. [缓存策略](#9-缓存策略)
10. [错误处理](#10-错误处理)

---

## 1. AI架构概述

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │图像生成   │  │文案创作   │  │风格转换   │  │智能建议   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                 统一AI服务抽象层                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  - 提供商选择器                                       │   │
│  │  - 模型选择器                                         │   │
│  │  - 请求路由器                                         │   │
│  │  - 响应标准化                                         │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  AI提供商适配器层                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │OpenAI适配 │  │Claude适配 │  │Gemini适配 │  │自定义适配 │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  支持服务层                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │配额管理   │  │任务队列   │  │缓存服务   │  │监控日志   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  外部AI服务                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │OpenAI API │  │Claude API │  │Gemini API │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 设计原则

1. **提供商无关**: 应用层不依赖特定AI提供商
2. **灵活切换**: 支持动态切换AI提供商和模型
3. **降级策略**: 主提供商失败时自动切换备用
4. **成本优化**: 根据任务类型选择最优性价比模型
5. **用户选择**: 支持用户自带API Key使用特定提供商

### 1.3 认证模式

#### 1.3.1 系统级认证
- 使用系统配置的API Key
- 适用于未配置个人Key的用户
- 统一配额管理

#### 1.3.2 用户级认证
- 用户提供自己的API Key
- 不受系统配额限制
- 支持OAuth2授权（OpenAI）

---

## 2. 多提供商架构

### 2.1 提供商配置

```typescript
interface AIProviderConfig {
  name: string
  type: 'openai' | 'anthropic' | 'google' | 'custom'
  enabled: boolean
  priority: number
  authType: 'api_key' | 'oauth2'
  
  // API配置
  apiKey?: string
  apiEndpoint: string
  
  // OAuth2配置
  oauth2?: {
    clientId: string
    clientSecret: string
    authorizationUrl: string
    tokenUrl: string
    scopes: string[]
  }
  
  // 模型配置
  models: {
    [key: string]: AIModelConfig
  }
  
  // 限流配置
  rateLimit: {
    requestsPerMinute: number
    tokensPerMinute: number
  }
  
  // 重试配置
  retry: {
    maxRetries: number
    backoffMultiplier: number
  }
}

interface AIModelConfig {
  id: string
  name: string
  type: 'text' | 'image' | 'embedding'
  maxTokens: number
  costPerToken: {
    input: number
    output: number
  }
  capabilities: string[]
}
```

### 2.2 提供商注册表

```typescript
class AIProviderRegistry {
  private providers: Map<string, AIProvider> = new Map()
  
  register(name: string, provider: AIProvider): void {
    this.providers.set(name, provider)
  }
  
  get(name: string): AIProvider | undefined {
    return this.providers.get(name)
  }
  
  getByPriority(): AIProvider[] {
    return Array.from(this.providers.values())
      .filter(p => p.config.enabled)
      .sort((a, b) => b.config.priority - a.config.priority)
  }
  
  getByCapability(capability: string): AIProvider[] {
    return Array.from(this.providers.values())
      .filter(p => p.hasCapability(capability))
  }
}
```

### 2.3 提供商选择策略

```typescript
enum ProviderSelectionStrategy {
  PRIORITY = 'priority',           // 按优先级选择
  COST = 'cost',                   // 按成本选择
  PERFORMANCE = 'performance',     // 按性能选择
  USER_PREFERENCE = 'user_preference', // 用户偏好
  LOAD_BALANCE = 'load_balance'    // 负载均衡
}

class ProviderSelector {
  select(
    task: AITask,
    strategy: ProviderSelectionStrategy,
    userPreference?: string
  ): AIProvider {
    switch (strategy) {
      case ProviderSelectionStrategy.USER_PREFERENCE:
        if (userPreference) {
          return this.registry.get(userPreference)
        }
        // fallthrough
        
      case ProviderSelectionStrategy.PRIORITY:
        return this.selectByPriority(task)
        
      case ProviderSelectionStrategy.COST:
        return this.selectByCost(task)
        
      case ProviderSelectionStrategy.PERFORMANCE:
        return this.selectByPerformance(task)
        
      case ProviderSelectionStrategy.LOAD_BALANCE:
        return this.selectByLoadBalance(task)
    }
  }
  
  private selectByPriority(task: AITask): AIProvider {
    const providers = this.registry.getByCapability(task.capability)
    return providers[0] // 返回优先级最高的
  }
  
  private selectByCost(task: AITask): AIProvider {
    const providers = this.registry.getByCapability(task.capability)
    
    return providers.reduce((cheapest, current) => {
      const cheapestCost = this.estimateCost(task, cheapest)
      const currentCost = this.estimateCost(task, current)
      return currentCost < cheapestCost ? current : cheapest
    })
  }
  
  private estimateCost(task: AITask, provider: AIProvider): number {
    const model = provider.getModel(task.modelId)
    const estimatedTokens = this.estimateTokens(task)
    return estimatedTokens * model.costPerToken.input
  }
}
```

---

## 3. OpenAI集成

### 3.1 认证方式

#### 3.1.1 API Key认证
```typescript
class OpenAIProvider implements AIProvider {
  private client: OpenAI
  
  constructor(config: OpenAIConfig) {
    this.client = new OpenAI({
      apiKey: config.apiKey,
      organization: config.organizationId,
      baseURL: config.baseURL || 'https://api.openai.com/v1'
    })
  }
}
```

#### 3.1.2 OAuth2认证
```typescript
class OpenAIOAuth2Provider implements AIProvider {
  async authenticate(userId: string): Promise<string> {
    // 1. 重定向到OpenAI授权页面
    const authUrl = `https://auth.openai.com/authorize?` +
      `client_id=${this.config.clientId}&` +
      `redirect_uri=${this.config.redirectUri}&` +
      `response_type=code&` +
      `scope=api.read api.write`
    
    return authUrl
  }
  
  async handleCallback(code: string): Promise<TokenResponse> {
    // 2. 交换授权码获取访问令牌
    const response = await axios.post(
      'https://auth.openai.com/oauth/token',
      {
        grant_type: 'authorization_code',
        code,
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret,
        redirect_uri: this.config.redirectUri
      }
    )
    
    return {
      accessToken: response.data.access_token,
      refreshToken: response.data.refresh_token,
      expiresIn: response.data.expires_in
    }
  }
  
  async refreshToken(refreshToken: string): Promise<TokenResponse> {
    const response = await axios.post(
      'https://auth.openai.com/oauth/token',
      {
        grant_type: 'refresh_token',
        refresh_token: refreshToken,
        client_id: this.config.clientId,
        client_secret: this.config.clientSecret
      }
    )
    
    return {
      accessToken: response.data.access_token,
      refreshToken: response.data.refresh_token,
      expiresIn: response.data.expires_in
    }
  }
}
```

### 3.2 图像生成

```typescript
class OpenAIImageGenerator {
  async generateImage(params: ImageGenerationParams): Promise<GeneratedImage> {
    const response = await this.client.images.generate({
      model: params.model || 'dall-e-3',
      prompt: params.prompt,
      n: params.count || 1,
      size: params.size || '1024x1024',
      quality: params.quality || 'standard',
      style: params.style || 'vivid'
    })
    
    return {
      images: response.data.map(img => ({
        url: img.url,
        revisedPrompt: img.revised_prompt
      })),
      model: 'dall-e-3',
      tokensUsed: this.estimateImageTokens(params)
    }
  }
  
  async editImage(params: ImageEditParams): Promise<GeneratedImage> {
    const response = await this.client.images.edit({
      model: 'dall-e-2',
      image: params.image,
      mask: params.mask,
      prompt: params.prompt,
      n: params.count || 1,
      size: params.size || '1024x1024'
    })
    
    return {
      images: response.data.map(img => ({ url: img.url })),
      model: 'dall-e-2',
      tokensUsed: this.estimateImageTokens(params)
    }
  }
  
  async createVariation(params: ImageVariationParams): Promise<GeneratedImage> {
    const response = await this.client.images.createVariation({
      model: 'dall-e-2',
      image: params.image,
      n: params.count || 1,
      size: params.size || '1024x1024'
    })
    
    return {
      images: response.data.map(img => ({ url: img.url })),
      model: 'dall-e-2',
      tokensUsed: this.estimateImageTokens(params)
    }
  }
}
```

### 3.3 文本生成

```typescript
class OpenAITextGenerator {
  async generateText(params: TextGenerationParams): Promise<GeneratedText> {
    const response = await this.client.chat.completions.create({
      model: params.model || 'gpt-4-turbo-preview',
      messages: params.messages,
      temperature: params.temperature || 0.7,
      max_tokens: params.maxTokens,
      top_p: params.topP || 1,
      frequency_penalty: params.frequencyPenalty || 0,
      presence_penalty: params.presencePenalty || 0,
      stream: params.stream || false
    })
    
    return {
      content: response.choices[0].message.content,
      model: response.model,
      tokensUsed: {
        prompt: response.usage.prompt_tokens,
        completion: response.usage.completion_tokens,
        total: response.usage.total_tokens
      },
      finishReason: response.choices[0].finish_reason
    }
  }
  
  async *generateTextStream(
    params: TextGenerationParams
  ): AsyncGenerator<string> {
    const stream = await this.client.chat.completions.create({
      ...params,
      stream: true
    })
    
    for await (const chunk of stream) {
      const content = chunk.choices[0]?.delta?.content
      if (content) {
        yield content
      }
    }
  }
}
```

### 3.4 模型配置

```typescript
const OPENAI_MODELS = {
  // 文本模型
  'gpt-4-turbo-preview': {
    type: 'text',
    maxTokens: 128000,
    costPerToken: {
      input: 0.01 / 1000,
      output: 0.03 / 1000
    },
    capabilities: ['text-generation', 'chat', 'function-calling']
  },
  'gpt-4': {
    type: 'text',
    maxTokens: 8192,
    costPerToken: {
      input: 0.03 / 1000,
      output: 0.06 / 1000
    },
    capabilities: ['text-generation', 'chat', 'function-calling']
  },
  'gpt-3.5-turbo': {
    type: 'text',
    maxTokens: 16385,
    costPerToken: {
      input: 0.0005 / 1000,
      output: 0.0015 / 1000
    },
    capabilities: ['text-generation', 'chat', 'function-calling']
  },
  
  // 图像模型
  'dall-e-3': {
    type: 'image',
    maxTokens: 0,
    costPerToken: {
      input: 0,
      output: 0
    },
    costPerImage: {
      '1024x1024': 0.04,
      '1024x1792': 0.08,
      '1792x1024': 0.08
    },
    capabilities: ['image-generation']
  },
  'dall-e-2': {
    type: 'image',
    maxTokens: 0,
    costPerToken: {
      input: 0,
      output: 0
    },
    costPerImage: {
      '256x256': 0.016,
      '512x512': 0.018,
      '1024x1024': 0.02
    },
    capabilities: ['image-generation', 'image-edit', 'image-variation']
  }
}
```

---

## 4. Anthropic Claude集成

### 4.1 认证配置

```typescript
class ClaudeProvider implements AIProvider {
  private client: Anthropic
  
  constructor(config: ClaudeConfig) {
    this.client = new Anthropic({
      apiKey: config.apiKey,
      baseURL: config.baseURL || 'https://api.anthropic.com'
    })
  }
}
```

### 4.2 文本生成

```typescript
class ClaudeTextGenerator {
  async generateText(params: TextGenerationParams): Promise<GeneratedText> {
    const response = await this.client.messages.create({
      model: params.model || 'claude-3-opus-20240229',
      max_tokens: params.maxTokens || 4096,
      temperature: params.temperature || 1.0,
      messages: params.messages,
      system: params.systemPrompt
    })
    
    return {
      content: response.content[0].text,
      model: response.model,
      tokensUsed: {
        prompt: response.usage.input_tokens,
        completion: response.usage.output_tokens,
        total: response.usage.input_tokens + response.usage.output_tokens
      },
      stopReason: response.stop_reason
    }
  }
  
  async *generateTextStream(
    params: TextGenerationParams
  ): AsyncGenerator<string> {
    const stream = await this.client.messages.create({
      ...params,
      stream: true
    })
    
    for await (const event of stream) {
      if (event.type === 'content_block_delta' && 
          event.delta.type === 'text_delta') {
        yield event.delta.text
      }
    }
  }
}
```

### 4.3 模型配置

```typescript
const CLAUDE_MODELS = {
  'claude-3-opus-20240229': {
    type: 'text',
    maxTokens: 200000,
    costPerToken: {
      input: 0.015 / 1000,
      output: 0.075 / 1000
    },
    capabilities: ['text-generation', 'chat', 'vision']
  },
  'claude-3-sonnet-20240229': {
    type: 'text',
    maxTokens: 200000,
    costPerToken: {
      input: 0.003 / 1000,
      output: 0.015 / 1000
    },
    capabilities: ['text-generation', 'chat', 'vision']
  },
  'claude-3-haiku-20240307': {
    type: 'text',
    maxTokens: 200000,
    costPerToken: {
      input: 0.00025 / 1000,
      output: 0.00125 / 1000
    },
    capabilities: ['text-generation', 'chat']
  }
}
```

---

## 5. Google Gemini集成

### 5.1 认证配置

```typescript
class GeminiProvider implements AIProvider {
  private client: GoogleGenerativeAI
  
  constructor(config: GeminiConfig) {
    this.client = new GoogleGenerativeAI(config.apiKey)
  }
}
```

### 5.2 文本生成

```typescript
class GeminiTextGenerator {
  async generateText(params: TextGenerationParams): Promise<GeneratedText> {
    const model = this.client.getGenerativeModel({
      model: params.model || 'gemini-pro'
    })
    
    const result = await model.generateContent({
      contents: params.messages.map(msg => ({
        role: msg.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: msg.content }]
      })),
      generationConfig: {
        temperature: params.temperature || 0.9,
        topK: params.topK || 1,
        topP: params.topP || 1,
        maxOutputTokens: params.maxTokens || 2048
      }
    })
    
    const response = result.response
    
    return {
      content: response.text(),
      model: params.model,
      tokensUsed: {
        prompt: response.usageMetadata?.promptTokenCount || 0,
        completion: response.usageMetadata?.candidatesTokenCount || 0,
        total: response.usageMetadata?.totalTokenCount || 0
      }
    }
  }
  
  async *generateTextStream(
    params: TextGenerationParams
  ): AsyncGenerator<string> {
    const model = this.client.getGenerativeModel({
      model: params.model || 'gemini-pro'
    })
    
    const result = await model.generateContentStream({
      contents: params.messages.map(msg => ({
        role: msg.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: msg.content }]
      }))
    })
    
    for await (const chunk of result.stream) {
      yield chunk.text()
    }
  }
}
```

### 5.3 图像生成（Imagen）

```typescript
class GeminiImageGenerator {
  async generateImage(params: ImageGenerationParams): Promise<GeneratedImage> {
    // 注意：Gemini的图像生成功能可能需要单独的API
    const response = await axios.post(
      `${this.config.baseURL}/v1/images:generate`,
      {
        prompt: params.prompt,
        number_of_images: params.count || 1,
        aspect_ratio: params.aspectRatio || '1:1',
        safety_filter_level: 'block_some'
      },
      {
        headers: {
          'Authorization': `Bearer ${this.config.apiKey}`,
          'Content-Type': 'application/json'
        }
      }
    )
    
    return {
      images: response.data.images.map(img => ({
        url: img.imageUrl,
        base64: img.imageBase64
      })),
      model: 'imagen-2',
      tokensUsed: 0
    }
  }
}
```

### 5.4 模型配置

```typescript
const GEMINI_MODELS = {
  'gemini-pro': {
    type: 'text',
    maxTokens: 32760,
    costPerToken: {
      input: 0.00025 / 1000,
      output: 0.0005 / 1000
    },
    capabilities: ['text-generation', 'chat']
  },
  'gemini-pro-vision': {
    type: 'text',
    maxTokens: 16384,
    costPerToken: {
      input: 0.00025 / 1000,
      output: 0.0005 / 1000
    },
    capabilities: ['text-generation', 'chat', 'vision']
  },
  'gemini-ultra': {
    type: 'text',
    maxTokens: 32760,
    costPerToken: {
      input: 0.00125 / 1000,
      output: 0.0025 / 1000
    },
    capabilities: ['text-generation', 'chat', 'vision', 'reasoning']
  }
}
```


---

## 6. 统一服务抽象层

### 6.1 统一接口定义

```typescript
interface AIProvider {
  name: string
  config: AIProviderConfig
  
  // 认证
  authenticate(): Promise<void>
  isAuthenticated(): boolean
  
  // 能力检查
  hasCapability(capability: string): boolean
  getModel(modelId: string): AIModelConfig
  
  // 文本生成
  generateText(params: TextGenerationParams): Promise<GeneratedText>
  generateTextStream(params: TextGenerationParams): AsyncGenerator<string>
  
  // 图像生成
  generateImage(params: ImageGenerationParams): Promise<GeneratedImage>
  editImage(params: ImageEditParams): Promise<GeneratedImage>
  
  // 健康检查
  healthCheck(): Promise<boolean>
}
```

### 6.2 统一AI服务

```typescript
class UnifiedAIService {
  constructor(
    private registry: AIProviderRegistry,
    private selector: ProviderSelector,
    private quotaManager: QuotaManager,
    private cache: CacheService
  ) {}
  
  async generateText(
    params: TextGenerationParams,
    options?: AIServiceOptions
  ): Promise<GeneratedText> {
    // 1. 检查配额
    await this.quotaManager.checkQuota(options?.userId, 'text')
    
    // 2. 检查缓存
    const cacheKey = this.getCacheKey('text', params)
    const cached = await this.cache.get(cacheKey)
    if (cached && !options?.skipCache) {
      return cached
    }
    
    // 3. 选择提供商
    const provider = this.selector.select(
      { type: 'text', capability: 'text-generation' },
      options?.strategy || ProviderSelectionStrategy.PRIORITY,
      options?.preferredProvider
    )
    
    // 4. 执行生成
    let result: GeneratedText
    try {
      result = await provider.generateText(params)
    } catch (error) {
      // 5. 失败时尝试备用提供商
      if (options?.enableFallback) {
        const fallbackProvider = this.selector.selectFallback(provider)
        result = await fallbackProvider.generateText(params)
      } else {
        throw error
      }
    }
    
    // 6. 记录使用量
    await this.quotaManager.recordUsage(
      options?.userId,
      'text',
      result.tokensUsed.total
    )
    
    // 7. 缓存结果
    if (options?.enableCache) {
      await this.cache.set(cacheKey, result, 3600)
    }
    
    // 8. 保存生成记录
    await this.saveGenerationRecord({
      userId: options?.userId,
      provider: provider.name,
      model: result.model,
      type: 'text',
      params,
      result,
      tokensUsed: result.tokensUsed.total,
      cost: this.calculateCost(provider, result)
    })
    
    return result
  }
  
  async generateImage(
    params: ImageGenerationParams,
    options?: AIServiceOptions
  ): Promise<GeneratedImage> {
    // 类似的流程
    await this.quotaManager.checkQuota(options?.userId, 'image')
    
    const provider = this.selector.select(
      { type: 'image', capability: 'image-generation' },
      options?.strategy || ProviderSelectionStrategy.PRIORITY,
      options?.preferredProvider
    )
    
    const result = await provider.generateImage(params)
    
    await this.quotaManager.recordUsage(
      options?.userId,
      'image',
      1 // 图像按数量计费
    )
    
    await this.saveGenerationRecord({
      userId: options?.userId,
      provider: provider.name,
      model: result.model,
      type: 'image',
      params,
      result,
      tokensUsed: 0,
      cost: this.calculateImageCost(provider, params)
    })
    
    return result
  }
  
  private calculateCost(provider: AIProvider, result: GeneratedText): number {
    const model = provider.getModel(result.model)
    const inputCost = result.tokensUsed.prompt * model.costPerToken.input
    const outputCost = result.tokensUsed.completion * model.costPerToken.output
    return inputCost + outputCost
  }
}
```

### 6.3 请求标准化

```typescript
interface TextGenerationParams {
  messages: Array<{
    role: 'system' | 'user' | 'assistant'
    content: string
  }>
  model?: string
  temperature?: number
  maxTokens?: number
  topP?: number
  topK?: number
  frequencyPenalty?: number
  presencePenalty?: number
  stream?: boolean
  systemPrompt?: string
}

interface ImageGenerationParams {
  prompt: string
  model?: string
  count?: number
  size?: string
  quality?: 'standard' | 'hd'
  style?: 'vivid' | 'natural'
  aspectRatio?: string
}

interface GeneratedText {
  content: string
  model: string
  tokensUsed: {
    prompt: number
    completion: number
    total: number
  }
  finishReason?: string
  metadata?: Record<string, any>
}

interface GeneratedImage {
  images: Array<{
    url: string
    base64?: string
    revisedPrompt?: string
  }>
  model: string
  tokensUsed: number
  metadata?: Record<string, any>
}
```

---

## 7. 配额管理

### 7.1 配额系统

```typescript
class QuotaManager {
  async checkQuota(userId: string, type: 'text' | 'image'): Promise<void> {
    const quota = await this.getQuota(userId)
    const usage = await this.getUsage(userId, type)
    
    if (usage >= quota[type]) {
      throw new QuotaExceededError(
        `${type}配额已用完。已使用: ${usage}, 总配额: ${quota[type]}`
      )
    }
  }
  
  async getQuota(userId: string): Promise<UserQuota> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { company: true }
    })
    
    // 根据订阅计划返回配额
    const plan = user.company.subscriptionPlan
    return QUOTA_PLANS[plan]
  }
  
  async getUsage(userId: string, type: string): Promise<number> {
    const startOfMonth = new Date()
    startOfMonth.setDate(1)
    startOfMonth.setHours(0, 0, 0, 0)
    
    const usage = await prisma.aiUsageLog.aggregate({
      where: {
        userId,
        operation: type,
        createdAt: { gte: startOfMonth }
      },
      _sum: {
        tokensUsed: true
      }
    })
    
    return usage._sum.tokensUsed || 0
  }
  
  async recordUsage(
    userId: string,
    type: string,
    tokensUsed: number
  ): Promise<void> {
    await prisma.aiUsageLog.create({
      data: {
        userId,
        operation: type,
        tokensUsed,
        createdAt: new Date()
      }
    })
  }
}

// 配额计划
const QUOTA_PLANS = {
  basic: {
    text: 100000,      // 10万tokens/月
    image: 50          // 50张图片/月
  },
  professional: {
    text: 500000,      // 50万tokens/月
    image: 200         // 200张图片/月
  },
  enterprise: {
    text: 2000000,     // 200万tokens/月
    image: 1000        // 1000张图片/月
  }
}
```

### 7.2 用户自带Key管理

```typescript
class UserAPIKeyManager {
  async saveUserAPIKey(
    userId: string,
    provider: string,
    apiKey: string
  ): Promise<void> {
    // 加密存储
    const encryption = new DataEncryption(process.env.ENCRYPTION_KEY)
    const encrypted = encryption.encrypt(apiKey)
    
    await prisma.userAIKey.upsert({
      where: {
        userId_provider: {
          userId,
          provider
        }
      },
      create: {
        userId,
        provider,
        encryptedKey: JSON.stringify(encrypted),
        isActive: true
      },
      update: {
        encryptedKey: JSON.stringify(encrypted),
        updatedAt: new Date()
      }
    })
  }
  
  async getUserAPIKey(
    userId: string,
    provider: string
  ): Promise<string | null> {
    const record = await prisma.userAIKey.findUnique({
      where: {
        userId_provider: {
          userId,
          provider
        }
      }
    })
    
    if (!record || !record.isActive) {
      return null
    }
    
    // 解密
    const encryption = new DataEncryption(process.env.ENCRYPTION_KEY)
    const encrypted = JSON.parse(record.encryptedKey)
    return encryption.decrypt(encrypted)
  }
  
  async validateUserAPIKey(
    userId: string,
    provider: string
  ): Promise<boolean> {
    const apiKey = await this.getUserAPIKey(userId, provider)
    if (!apiKey) return false
    
    // 测试API Key是否有效
    try {
      const providerInstance = this.createProvider(provider, apiKey)
      return await providerInstance.healthCheck()
    } catch (error) {
      return false
    }
  }
}
```

---

## 8. 异步任务队列

### 8.1 任务队列架构

```typescript
class AITaskQueue {
  private queue: Queue
  
  constructor() {
    this.queue = new Queue('ai-tasks', {
      connection: {
        host: process.env.REDIS_HOST,
        port: parseInt(process.env.REDIS_PORT)
      }
    })
    
    this.setupWorkers()
  }
  
  async addTask(task: AITask): Promise<string> {
    const job = await this.queue.add(
      task.type,
      task,
      {
        priority: task.priority || 5,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 2000
        },
        removeOnComplete: false,
        removeOnFail: false
      }
    )
    
    return job.id
  }
  
  private setupWorkers(): void {
    // 图像生成worker
    this.queue.process('image-generation', 5, async (job) => {
      return await this.processImageGeneration(job.data)
    })
    
    // 文本生成worker
    this.queue.process('text-generation', 10, async (job) => {
      return await this.processTextGeneration(job.data)
    })
    
    // 批量处理worker
    this.queue.process('batch-generation', 2, async (job) => {
      return await this.processBatchGeneration(job.data)
    })
  }
  
  private async processImageGeneration(task: AITask): Promise<any> {
    const service = new UnifiedAIService(
      this.registry,
      this.selector,
      this.quotaManager,
      this.cache
    )
    
    // 更新任务状态
    await this.updateTaskStatus(task.id, 'processing')
    
    try {
      const result = await service.generateImage(task.params, {
        userId: task.userId,
        preferredProvider: task.provider
      })
      
      // 上传图片到OSS
      const uploadedUrls = await this.uploadImages(result.images)
      
      // 更新任务状态
      await this.updateTaskStatus(task.id, 'completed', {
        images: uploadedUrls,
        model: result.model
      })
      
      // 发送通知
      await this.notifyUser(task.userId, {
        type: 'ai_generation_completed',
        taskId: task.id
      })
      
      return result
    } catch (error) {
      await this.updateTaskStatus(task.id, 'failed', {
        error: error.message
      })
      throw error
    }
  }
  
  async getTaskStatus(taskId: string): Promise<TaskStatus> {
    const job = await this.queue.getJob(taskId)
    
    if (!job) {
      throw new Error('Task not found')
    }
    
    const state = await job.getState()
    
    return {
      id: taskId,
      status: state,
      progress: job.progress(),
      result: job.returnvalue,
      error: job.failedReason,
      createdAt: new Date(job.timestamp),
      processedAt: job.processedOn ? new Date(job.processedOn) : null,
      finishedAt: job.finishedOn ? new Date(job.finishedOn) : null
    }
  }
}
```

### 8.2 任务优先级

```typescript
enum TaskPriority {
  URGENT = 1,      // 用户实时请求
  HIGH = 3,        // 重要任务
  NORMAL = 5,      // 普通任务
  LOW = 7,         // 批量处理
  BACKGROUND = 10  // 后台任务
}

interface AITask {
  id: string
  type: 'image-generation' | 'text-generation' | 'batch-generation'
  userId: string
  provider?: string
  params: any
  priority: TaskPriority
  metadata?: Record<string, any>
}
```

---

## 9. 缓存策略

### 9.1 多级缓存

```typescript
class AICacheService {
  private memoryCache: LRUCache
  private redisCache: Redis
  
  constructor() {
    // L1: 内存缓存 (最近使用的结果)
    this.memoryCache = new LRUCache({
      max: 1000,
      maxAge: 5 * 60 * 1000 // 5分钟
    })
    
    // L2: Redis缓存 (共享缓存)
    this.redisCache = new Redis({
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT)
    })
  }
  
  async get(key: string): Promise<any | null> {
    // 先查内存缓存
    const memCached = this.memoryCache.get(key)
    if (memCached) {
      return memCached
    }
    
    // 再查Redis
    const redisCached = await this.redisCache.get(key)
    if (redisCached) {
      const data = JSON.parse(redisCached)
      // 回填内存缓存
      this.memoryCache.set(key, data)
      return data
    }
    
    return null
  }
  
  async set(key: string, value: any, ttl: number): Promise<void> {
    // 写入内存缓存
    this.memoryCache.set(key, value)
    
    // 写入Redis
    await this.redisCache.setex(key, ttl, JSON.stringify(value))
  }
  
  getCacheKey(type: string, params: any): string {
    // 生成稳定的缓存键
    const normalized = this.normalizeParams(params)
    const hash = crypto
      .createHash('sha256')
      .update(JSON.stringify(normalized))
      .digest('hex')
    
    return `ai:${type}:${hash}`
  }
  
  private normalizeParams(params: any): any {
    // 标准化参数，确保相同参数生成相同的key
    const normalized = { ...params }
    
    // 移除不影响结果的参数
    delete normalized.stream
    delete normalized.metadata
    
    // 排序对象键
    return this.sortObjectKeys(normalized)
  }
}
```

### 9.2 缓存策略

```typescript
const CACHE_STRATEGIES = {
  // 文本生成 - 相同prompt缓存
  'text-generation': {
    enabled: true,
    ttl: 3600,        // 1小时
    keyFields: ['messages', 'model', 'temperature']
  },
  
  // 图像生成 - 相同prompt缓存
  'image-generation': {
    enabled: true,
    ttl: 86400,       // 24小时
    keyFields: ['prompt', 'model', 'size', 'style']
  },
  
  // 风格转换 - 不缓存（每次结果可能不同）
  'style-transfer': {
    enabled: false
  },
  
  // 智能建议 - 短期缓存
  'smart-suggestions': {
    enabled: true,
    ttl: 1800,        // 30分钟
    keyFields: ['type', 'context']
  }
}
```

---

## 10. 错误处理

### 10.1 错误分类

```typescript
class AIError extends Error {
  constructor(
    public code: string,
    public message: string,
    public provider: string,
    public retryable: boolean = false,
    public details?: any
  ) {
    super(message)
  }
}

// 具体错误类型
class QuotaExceededError extends AIError {
  constructor(message: string) {
    super('QUOTA_EXCEEDED', message, '', false)
  }
}

class ProviderError extends AIError {
  constructor(provider: string, message: string, retryable: boolean = true) {
    super('PROVIDER_ERROR', message, provider, retryable)
  }
}

class ContentFilterError extends AIError {
  constructor(provider: string, message: string) {
    super('CONTENT_FILTERED', message, provider, false)
  }
}

class RateLimitError extends AIError {
  constructor(provider: string, retryAfter: number) {
    super(
      'RATE_LIMIT',
      `Rate limit exceeded. Retry after ${retryAfter}s`,
      provider,
      true,
      { retryAfter }
    )
  }
}
```

### 10.2 错误处理策略

```typescript
class AIErrorHandler {
  async handle(error: Error, context: AIContext): Promise<any> {
    if (error instanceof QuotaExceededError) {
      return this.handleQuotaExceeded(error, context)
    }
    
    if (error instanceof RateLimitError) {
      return this.handleRateLimit(error, context)
    }
    
    if (error instanceof ContentFilterError) {
      return this.handleContentFilter(error, context)
    }
    
    if (error instanceof ProviderError && error.retryable) {
      return this.handleRetryableError(error, context)
    }
    
    // 未知错误
    return this.handleUnknownError(error, context)
  }
  
  private async handleQuotaExceeded(
    error: QuotaExceededError,
    context: AIContext
  ): Promise<any> {
    // 记录日志
    logger.warn('Quota exceeded', {
      userId: context.userId,
      error: error.message
    })
    
    // 发送通知
    await this.notifyUser(context.userId, {
      type: 'quota_exceeded',
      message: error.message
    })
    
    throw error
  }
  
  private async handleRateLimit(
    error: RateLimitError,
    context: AIContext
  ): Promise<any> {
    // 等待后重试
    await this.sleep(error.details.retryAfter * 1000)
    
    // 重新执行
    return await context.retry()
  }
  
  private async handleRetryableError(
    error: ProviderError,
    context: AIContext
  ): Promise<any> {
    // 尝试备用提供商
    if (context.enableFallback) {
      const fallbackProvider = this.selector.selectFallback(
        context.currentProvider
      )
      
      logger.info('Falling back to alternative provider', {
        from: context.currentProvider.name,
        to: fallbackProvider.name
      })
      
      return await context.retryWithProvider(fallbackProvider)
    }
    
    throw error
  }
}
```

### 10.3 降级策略

```typescript
class AIFallbackStrategy {
  async execute(task: AITask, primaryError: Error): Promise<any> {
    // 策略1: 切换到备用提供商
    try {
      return await this.tryAlternativeProvider(task)
    } catch (error) {
      logger.warn('Alternative provider failed', { error })
    }
    
    // 策略2: 使用更便宜的模型
    try {
      return await this.tryLowerTierModel(task)
    } catch (error) {
      logger.warn('Lower tier model failed', { error })
    }
    
    // 策略3: 返回缓存的相似结果
    try {
      return await this.trySimilarCachedResult(task)
    } catch (error) {
      logger.warn('No similar cached result', { error })
    }
    
    // 所有策略都失败，抛出原始错误
    throw primaryError
  }
  
  private async tryAlternativeProvider(task: AITask): Promise<any> {
    const alternatives = this.registry.getByCapability(task.capability)
      .filter(p => p.name !== task.provider)
    
    for (const provider of alternatives) {
      try {
        return await provider.execute(task)
      } catch (error) {
        continue
      }
    }
    
    throw new Error('No alternative provider available')
  }
}
```

---

## 11. 监控与分析

### 11.1 性能监控

```typescript
class AIPerformanceMonitor {
  async recordMetrics(generation: AIGeneration): Promise<void> {
    // Prometheus指标
    await prometheus.histogram('ai_generation_duration', {
      provider: generation.provider,
      model: generation.model,
      type: generation.type
    }).observe(generation.duration)
    
    await prometheus.counter('ai_generation_total', {
      provider: generation.provider,
      model: generation.model,
      type: generation.type,
      status: generation.status
    }).inc()
    
    await prometheus.gauge('ai_tokens_used', {
      provider: generation.provider,
      model: generation.model
    }).set(generation.tokensUsed)
    
    await prometheus.gauge('ai_cost', {
      provider: generation.provider,
      model: generation.model
    }).set(generation.cost)
  }
  
  async getProviderStats(
    provider: string,
    timeRange: TimeRange
  ): Promise<ProviderStats> {
    const stats = await prisma.aiGeneration.aggregate({
      where: {
        provider,
        createdAt: {
          gte: timeRange.start,
          lte: timeRange.end
        }
      },
      _count: true,
      _sum: {
        tokensUsed: true,
        cost: true,
        duration: true
      },
      _avg: {
        duration: true
      }
    })
    
    return {
      totalRequests: stats._count,
      totalTokens: stats._sum.tokensUsed,
      totalCost: stats._sum.cost,
      averageDuration: stats._avg.duration,
      successRate: await this.calculateSuccessRate(provider, timeRange)
    }
  }
}
```

### 11.2 使用分析

```typescript
class AIUsageAnalytics {
  async getUserUsageReport(
    userId: string,
    period: 'day' | 'week' | 'month'
  ): Promise<UsageReport> {
    const timeRange = this.getTimeRange(period)
    
    const usage = await prisma.aiGeneration.groupBy({
      by: ['type', 'provider', 'model'],
      where: {
        userId,
        createdAt: {
          gte: timeRange.start,
          lte: timeRange.end
        }
      },
      _count: true,
      _sum: {
        tokensUsed: true,
        cost: true
      }
    })
    
    return {
      period,
      totalRequests: usage.reduce((sum, item) => sum + item._count, 0),
      totalTokens: usage.reduce((sum, item) => sum + item._sum.tokensUsed, 0),
      totalCost: usage.reduce((sum, item) => sum + item._sum.cost, 0),
      byType: this.groupByType(usage),
      byProvider: this.groupByProvider(usage),
      byModel: this.groupByModel(usage)
    }
  }
}
```

---

## 附录

### A. 最佳实践

1. **提示词优化**: 使用清晰、具体的提示词
2. **模型选择**: 根据任务复杂度选择合适的模型
3. **成本控制**: 设置合理的token限制
4. **错误处理**: 实现完善的错误处理和重试机制
5. **缓存利用**: 充分利用缓存减少API调用

### B. 故障排查

1. **配额不足**: 检查用户配额和使用情况
2. **API Key无效**: 验证API Key是否正确配置
3. **请求超时**: 检查网络连接和超时设置
4. **内容被过滤**: 调整提示词避免敏感内容
5. **成本过高**: 优化提示词和模型选择

### C. 性能优化建议

1. 使用流式响应提升用户体验
2. 实现请求批处理减少API调用
3. 合理设置缓存策略
4. 使用异步任务处理长时间操作
5. 监控和优化token使用

---

**文档版本**: 1.0  
**最后更新**: 2026年2月4日  
**维护团队**: AI集成组
