# ERP集成补充说明 - 自研ERP系统

**版本**: 1.0
**更新日期**: 2026-02-04

---

## 自研ERP系统集成方案

由于ERP系统是自研的，我们需要根据实际的ERP API设计来实现适配器。以下提供通用的集成方案和示例代码。

---

## 1. 自研ERP Adapter实现

### 1.1 自定义ERP Adapter

```typescript
// modules/erp/adapters/custom-erp.adapter.ts
import { Injectable, Logger } from '@nestjs/common'
import axios, { AxiosInstance } from 'axios'
import { IERPAdapter, ERPCustomer, ERPProduct } from './erp-adapter.interface'

@Injectable()
export class CustomERPAdapter implements IERPAdapter {
  private readonly logger = new Logger(CustomERPAdapter.name)
  readonly name = 'custom'
  private client: AxiosInstance

  constructor(
    private readonly apiEndpoint: string,
    private readonly apiKey: string,
    private readonly authType: 'api_key' | 'oauth2' | 'basic_auth' = 'api_key',
  ) {
    this.client = axios.create({
      baseURL: apiEndpoint,
      timeout: 30000,
    })

    // 根据认证类型配置请求头
    this.setupAuthentication()
  }

  private setupAuthentication() {
    switch (this.authType) {
      case 'api_key':
        this.client.defaults.headers.common['X-API-Key'] = this.apiKey
        break
      case 'oauth2':
        this.client.defaults.headers.common['Authorization'] = `Bearer ${this.apiKey}`
        break
      case 'basic_auth':
        this.client.defaults.headers.common['Authorization'] = `Basic ${this.apiKey}`
        break
    }
    this.client.defaults.headers.common['Content-Type'] = 'application/json'
  }

  // ==================== 客户数据同步 ====================

  async syncCustomers(): Promise<ERPCustomer[]> {
    try {
      this.logger.log('Syncing customers from custom ERP')

      // 根据实际ERP API调整端点和参数
      const response = await this.client.get('/customers', {
        params: {
          page: 1,
          limit: 1000,
          status: 'active',
        },
      })

      // 根据实际返回数据结构调整映射
      const customers = response.data.data || response.data
      return customers.map((customer: any) => this.mapCustomer(customer))
    } catch (error) {
      this.logger.error(`Failed to sync customers: ${error.message}`, error.stack)
      throw error
    }
  }

  async getCustomer(erpCustomerId: string): Promise<ERPCustomer> {
    const response = await this.client.get(`/customers/${erpCustomerId}`)
    return this.mapCustomer(response.data.data || response.data)
  }

  async createCustomer(customer: Partial<ERPCustomer>): Promise<ERPCustomer> {
    const payload = this.mapCustomerToERP(customer)
    const response = await this.client.post('/customers', payload)
    return this.mapCustomer(response.data.data || response.data)
  }

  async updateCustomer(
    erpCustomerId: string,
    customer: Partial<ERPCustomer>,
  ): Promise<ERPCustomer> {
    const payload = this.mapCustomerToERP(customer)
    const response = await this.client.put(`/customers/${erpCustomerId}`, payload)
    return this.mapCustomer(response.data.data || response.data)
  }

  // ==================== 产品数据同步 ====================

  async syncProducts(): Promise<ERPProduct[]> {
    try {
      this.logger.log('Syncing products from custom ERP')

      const response = await this.client.get('/products', {
        params: {
          page: 1,
          limit: 1000,
          status: 'active',
        },
      })

      const products = response.data.data || response.data
      return products.map((product: any) => this.mapProduct(product))
    } catch (error) {
      this.logger.error(`Failed to sync products: ${error.message}`, error.stack)
      throw error
    }
  }

  async getProduct(erpProductId: string): Promise<ERPProduct> {
    const response = await this.client.get(`/products/${erpProductId}`)
    return this.mapProduct(response.data.data || response.data)
  }

  async updateProductStock(erpProductId: string, quantity: number): Promise<void> {
    await this.client.patch(`/products/${erpProductId}/stock`, {
      quantity,
      updated_at: new Date().toISOString(),
    })
  }

  // ==================== 提案数据推送 ====================

  async pushProposal(proposalData: any): Promise<{ erpProposalId: string }> {
    try {
      this.logger.log(`Pushing proposal to custom ERP: ${proposalData.id}`)

      // 将提案数据转换为ERP格式
      const erpPayload = {
        proposal_id: proposalData.id,
        title: proposalData.title,
        client_name: proposalData.clientName,
        client_email: proposalData.clientEmail,
        total_amount: proposalData.quotation?.totalAmount || 0,
        status: proposalData.status,
        created_at: proposalData.createdAt,
        items: proposalData.quotation?.items?.map((item: any) => ({
          product_id: item.productId,
          product_name: item.productName,
          quantity: item.quantity,
          unit_price: item.unitPrice,
          subtotal: item.subtotal,
        })) || [],
      }

      const response = await this.client.post('/proposals', erpPayload)

      return {
        erpProposalId: response.data.data?.id || response.data.id,
      }
    } catch (error) {
      this.logger.error(`Failed to push proposal: ${error.message}`, error.stack)
      throw error
    }
  }

  // ==================== 预约数据同步 ====================

  async syncAppointments(): Promise<any[]> {
    try {
      const response = await this.client.get('/appointments', {
        params: {
          start_date: new Date().toISOString(),
          limit: 100,
        },
      })

      return response.data.data || response.data
    } catch (error) {
      this.logger.error(`Failed to sync appointments: ${error.message}`, error.stack)
      throw error
    }
  }

  async createAppointment(appointment: any): Promise<{ erpAppointmentId: string }> {
    const payload = {
      title: appointment.title,
      client_name: appointment.clientName,
      client_email: appointment.clientEmail,
      client_phone: appointment.clientPhone,
      start_time: appointment.startTime,
      end_time: appointment.endTime,
      location: appointment.location,
      notes: appointment.notes,
    }

    const response = await this.client.post('/appointments', payload)

    return {
      erpAppointmentId: response.data.data?.id || response.data.id,
    }
  }

  // ==================== 连接测试 ====================

  async testConnection(): Promise<boolean> {
    try {
      // 尝试调用一个简单的端点来测试连接
      await this.client.get('/health')
      return true
    } catch (error) {
      this.logger.error(`Connection test failed: ${error.message}`)
      return false
    }
  }

  // ==================== 数据映射方法 ====================

  private mapCustomer(erpData: any): ERPCustomer {
    // 根据实际ERP数据结构调整映射
    return {
      erpCustomerId: erpData.id || erpData.customer_id,
      name: erpData.name || erpData.customer_name,
      email: erpData.email,
      phone: erpData.phone || erpData.mobile,
      address: erpData.address,
      // 保留原始数据以备后用
      ...erpData,
    }
  }

  private mapCustomerToERP(customer: Partial<ERPCustomer>): any {
    // 将标准格式转换为ERP格式
    return {
      name: customer.name,
      email: customer.email,
      phone: customer.phone,
      address: customer.address,
    }
  }

  private mapProduct(erpData: any): ERPProduct {
    return {
      erpProductId: erpData.id || erpData.product_id,
      sku: erpData.sku || erpData.product_code,
      name: erpData.name || erpData.product_name,
      price: parseFloat(erpData.price || erpData.unit_price || 0),
      stock: parseInt(erpData.stock || erpData.inventory || 0),
      // 保留原始数据
      ...erpData,
    }
  }
}
```

---

## 2. ERP Service（统一服务层）

```typescript
// modules/erp/erp.service.ts
import { Injectable, Logger, BadRequestException } from '@nestjs/common'
import { InjectRepository } from '@nestjs/typeorm'
import { Repository } from 'typeorm'
import { Cron, CronExpression } from '@nestjs/schedule'
import { ERPIntegration } from './entities/erp-integration.entity'
import { ERPSyncLog } from './entities/erp-sync-log.entity'
import { ERPCustomerMapping } from './entities/erp-customer-mapping.entity'
import { CustomERPAdapter } from './adapters/custom-erp.adapter'
import { IERPAdapter } from './adapters/erp-adapter.interface'

@Injectable()
export class ERPService {
  private readonly logger = new Logger(ERPService.name)
  private adapters: Map<string, IERPAdapter> = new Map()

  constructor(
    @InjectRepository(ERPIntegration)
    private readonly integrationRepository: Repository<ERPIntegration>,
    @InjectRepository(ERPSyncLog)
    private readonly syncLogRepository: Repository<ERPSyncLog>,
    @InjectRepository(ERPCustomerMapping)
    private readonly customerMappingRepository: Repository<ERPCustomerMapping>,
  ) {}

  // ==================== 配置管理 ====================

  async configureIntegration(
    companyId: string,
    config: {
      erpSystem: string
      erpName: string
      apiEndpoint: string
      apiKey: string
      authType: 'api_key' | 'oauth2' | 'basic_auth'
      syncEnabled: boolean
      syncFrequency: 'realtime' | 'hourly' | 'daily' | 'manual'
    },
  ): Promise<ERPIntegration> {
    this.logger.log(`Configuring ERP integration for company ${companyId}`)

    let integration = await this.integrationRepository.findOne({
      where: { companyId, erpSystem: config.erpSystem },
    })

    if (integration) {
      // 更新现有配置
      Object.assign(integration, config)
    } else {
      // 创建新配置
      integration = this.integrationRepository.create({
        companyId,
        ...config,
      })
    }

    // 测试连接
    const adapter = this.createAdapter(integration)
    const isConnected = await adapter.testConnection()

    if (!isConnected) {
      throw new BadRequestException('Failed to connect to ERP system')
    }

    integration.syncStatus = 'success'
    return this.integrationRepository.save(integration)
  }

  // ==================== 数据同步 ====================

  async syncCustomers(companyId: string): Promise<void> {
    const integration = await this.getActiveIntegration(companyId)
    const adapter = this.getAdapter(integration)

    const syncLog = this.syncLogRepository.create({
      integrationId: integration.id,
      syncType: 'customer',
      syncDirection: 'import',
      status: 'in_progress',
    })
    await this.syncLogRepository.save(syncLog)

    const startTime = Date.now()

    try {
      const customers = await adapter.syncCustomers()

      let successCount = 0
      let failedCount = 0

      for (const customer of customers) {
        try {
          await this.saveCustomerMapping(integration.id, customer)
          successCount++
        } catch (error) {
          this.logger.error(`Failed to save customer ${customer.erpCustomerId}`, error.stack)
          failedCount++
        }
      }

      syncLog.recordsTotal = customers.length
      syncLog.recordsSuccess = successCount
      syncLog.recordsFailed = failedCount
      syncLog.status = failedCount === 0 ? 'success' : 'partial'
      syncLog.durationMs = Date.now() - startTime

      await this.syncLogRepository.save(syncLog)

      // 更新集成状态
      integration.lastSyncAt = new Date()
      integration.syncStatus = 'success'
      await this.integrationRepository.save(integration)

      this.logger.log(
        `Customer sync completed: ${successCount} success, ${failedCount} failed`,
      )
    } catch (error) {
      syncLog.status = 'failed'
      syncLog.errorDetails = { message: error.message, stack: error.stack }
      await this.syncLogRepository.save(syncLog)

      integration.syncStatus = 'failed'
      integration.syncError = error.message
      await this.integrationRepository.save(integration)

      throw error
    }
  }

  async syncProducts(companyId: string): Promise<void> {
    // 类似实现
    this.logger.log(`Syncing products for company ${companyId}`)
    // ... 实现逻辑
  }

  async pushProposal(companyId: string, proposalData: any): Promise<string> {
    const integration = await this.getActiveIntegration(companyId)
    const adapter = this.getAdapter(integration)

    try {
      const result = await adapter.pushProposal(proposalData)
      this.logger.log(`Proposal pushed to ERP: ${result.erpProposalId}`)
      return result.erpProposalId
    } catch (error) {
      this.logger.error(`Failed to push proposal: ${error.message}`, error.stack)
      throw error
    }
  }

  // ==================== 定时同步任务 ====================

  @Cron(CronExpression.EVERY_HOUR)
  async autoSyncHourly() {
    const integrations = await this.integrationRepository.find({
      where: { syncEnabled: true, syncFrequency: 'hourly' },
    })

    for (const integration of integrations) {
      try {
        await this.syncCustomers(integration.companyId)
        await this.syncProducts(integration.companyId)
      } catch (error) {
        this.logger.error(
          `Auto sync failed for company ${integration.companyId}`,
          error.stack,
        )
      }
    }
  }

  // ==================== 辅助方法 ====================

  private async getActiveIntegration(companyId: string): Promise<ERPIntegration> {
    const integration = await this.integrationRepository.findOne({
      where: { companyId, syncEnabled: true },
    })

    if (!integration) {
      throw new BadRequestException('No active ERP integration found')
    }

    return integration
  }

  private getAdapter(integration: ERPIntegration): IERPAdapter {
    const key = `${integration.companyId}:${integration.erpSystem}`

    if (this.adapters.has(key)) {
      return this.adapters.get(key)
    }

    const adapter = this.createAdapter(integration)
    this.adapters.set(key, adapter)

    return adapter
  }

  private createAdapter(integration: ERPIntegration): IERPAdapter {
    // 目前只支持自研ERP
    return new CustomERPAdapter(
      integration.apiEndpoint,
      this.decryptApiKey(integration.apiKeyEncrypted),
      integration.authType as any,
    )
  }

  private async saveCustomerMapping(
    integrationId: string,
    customer: any,
  ): Promise<void> {
    let mapping = await this.customerMappingRepository.findOne({
      where: { integrationId, erpCustomerId: customer.erpCustomerId },
    })

    if (mapping) {
      mapping.customerData = customer
      mapping.lastSyncedAt = new Date()
    } else {
      mapping = this.customerMappingRepository.create({
        integrationId,
        erpCustomerId: customer.erpCustomerId,
        customerData: customer,
        lastSyncedAt: new Date(),
      })
    }

    await this.customerMappingRepository.save(mapping)
  }

  private decryptApiKey(encrypted: string): string {
    // 实现解密逻辑
    const crypto = require('crypto')
    // 简化示例，实际应使用环境变量中的密钥
    return encrypted
  }
}
```

---

## 3. ERP Controller

```typescript
// modules/erp/erp.controller.ts
import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common'
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger'
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'
import { RolesGuard } from '../auth/guards/roles.guard'
import { Roles } from '../../common/decorators/roles.decorator'
import { CurrentUser } from '../../common/decorators/current-user.decorator'
import { ERPService } from './erp.service'
import { User } from '../auth/entities/user.entity'

@ApiTags('erp')
@ApiBearerAuth()
@Controller('erp')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ERPController {
  constructor(private readonly erpService: ERPService) {}

  @Post('configure')
  @Roles('admin')
  @ApiOperation({ summary: '配置ERP集成' })
  async configure(
    @Body() configDto: {
      erpSystem: string
      erpName: string
      apiEndpoint: string
      apiKey: string
      authType: 'api_key' | 'oauth2' | 'basic_auth'
      syncEnabled: boolean
      syncFrequency: 'realtime' | 'hourly' | 'daily' | 'manual'
    },
    @CurrentUser() user: User,
  ) {
    const integration = await this.erpService.configureIntegration(
      user.companyId,
      configDto,
    )

    return {
      success: true,
      data: integration,
    }
  }

  @Post('sync/customers')
  @Roles('admin')
  @ApiOperation({ summary: '同步客户数据' })
  async syncCustomers(@CurrentUser() user: User) {
    await this.erpService.syncCustomers(user.companyId)

    return {
      success: true,
      message: '客户数据同步已启动',
    }
  }

  @Post('sync/products')
  @Roles('admin')
  @ApiOperation({ summary: '同步产品数据' })
  async syncProducts(@CurrentUser() user: User) {
    await this.erpService.syncProducts(user.companyId)

    return {
      success: true,
      message: '产品数据同步已启动',
    }
  }

  @Post('proposals/:proposalId/push')
  @Roles('admin', 'editor')
  @ApiOperation({ summary: '推送提案到ERP' })
  async pushProposal(
    @Param('proposalId') proposalId: string,
    @CurrentUser() user: User,
  ) {
    // 获取提案数据
    // const proposalData = await this.proposalsService.findOne(proposalId, user.id)

    // 推送到ERP
    // const erpProposalId = await this.erpService.pushProposal(user.companyId, proposalData)

    return {
      success: true,
      data: {
        // erpProposalId,
        message: '提案已成功推送到ERP系统',
      },
    }
  }
}
```

---

## 4. 使用说明

### 4.1 配置ERP集成

```bash
# API请求示例
POST /api/v1/erp/configure
Authorization: Bearer {token}
Content-Type: application/json

{
  "erpSystem": "custom",
  "erpName": "公司自研ERP系统",
  "apiEndpoint": "https://erp.company.com/api",
  "apiKey": "your-api-key",
  "authType": "api_key",
  "syncEnabled": true,
  "syncFrequency": "hourly"
}
```

### 4.2 手动同步数据

```bash
# 同步客户数据
POST /api/v1/erp/sync/customers

# 同步产品数据
POST /api/v1/erp/sync/products
```

### 4.3 推送提案到ERP

```bash
POST /api/v1/erp/proposals/{proposalId}/push
```

---

## 5. 注意事项

1. **API端点适配**：根据实际ERP系统的API端点调整代码中的路径
2. **数据格式映射**：根据ERP返回的数据结构调整`mapCustomer`和`mapProduct`方法
3. **认证方式**：根据ERP支持的认证方式配置`authType`
4. **错误处理**：完善错误处理逻辑，记录详细的错误信息
5. **性能优化**：对于大量数据同步，考虑分批处理和异步队列
6. **数据一致性**：实现双向同步时注意数据冲突处理

---

## 6. 扩展建议

如果未来需要支持其他ERP系统，只需：

1. 实现`IERPAdapter`接口
2. 在`ERPService.createAdapter`中添加新的case
3. 更新数据库中的`erp_system`枚举值

这样可以保持代码的可扩展性和维护性。
