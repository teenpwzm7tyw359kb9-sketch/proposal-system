# ERP集成规范文档

## 文档信息
- **版本**: 1.0
- **最后更新**: 2026年2月4日
- **适用范围**: 提案展示系统与主流ERP系统集成

## 目录
1. [集成架构概述](#1-集成架构概述)
2. [标准化接口设计](#2-标准化接口设计)
3. [用友ERP集成](#3-用友erp集成)
4. [金蝶ERP集成](#4-金蝶erp集成)
5. [SAP集成](#5-sap集成)
6. [自定义ERP集成](#6-自定义erp集成)
7. [数据同步策略](#7-数据同步策略)
8. [错误处理与重试](#8-错误处理与重试)
9. [安全与认证](#9-安全与认证)

---

## 1. 集成架构概述

### 1.1 架构设计原则

```
┌─────────────────────────────────────────────────────────────┐
│                    提案展示系统                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           ERP集成服务层                               │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐     │   │
│  │  │ 统一接口层  │  │ 数据映射层  │  │ 同步调度器  │     │   │
│  │  └────────────┘  └────────────┘  └────────────┘     │   │
│  └──────────────────────────────────────────────────────┘   │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           ERP适配器层                                 │   │
│  │  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────────┐        │   │
│  │  │用友适配│  │金蝶适配│  │SAP适配│  │自定义适配│        │   │
│  │  └──────┘  └──────┘  └──────┘  └──────────┘        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                    外部ERP系统                               │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────────┐              │
│  │用友ERP│  │金蝶ERP│  │  SAP  │  │自定义ERP │              │
│  └──────┘  └──────┘  └──────┘  └──────────┘              │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 集成模式

#### 1.2.1 实时同步
- 适用场景：关键业务数据（订单、客户）
- 触发方式：事件驱动
- 延迟：< 5秒

#### 1.2.2 定时同步
- 适用场景：非关键数据（产品库存、价格）
- 触发方式：定时任务
- 频率：可配置（每小时/每天）

#### 1.2.3 手动同步
- 适用场景：历史数据导入
- 触发方式：用户手动触发
- 场景：初始化、数据修复

### 1.3 数据流向

```
提案系统 → ERP系统:
- 客户信息
- 提案数据
- 报价单
- 预约信息

ERP系统 → 提案系统:
- 客户主数据
- 产品信息
- 库存数据
- 订单状态
- 发票信息
```

---

## 2. 标准化接口设计

### 2.1 统一数据模型

#### 2.1.1 客户数据模型
```typescript
interface CustomerData {
  // 基础信息
  externalId: string          // ERP系统中的客户ID
  name: string                // 客户名称
  code?: string               // 客户编码
  type: 'individual' | 'company'
  
  // 联系信息
  contacts: {
    name: string
    title?: string
    phone?: string
    email?: string
    isPrimary: boolean
  }[]
  
  // 公司信息
  companyInfo?: {
    legalName: string
    taxNumber: string
    industry: string
    registeredAddress: string
  }
  
  // 财务信息
  financialInfo?: {
    creditLimit: number
    paymentTerms: string
    currency: string
  }
  
  // 地址信息
  addresses: {
    type: 'billing' | 'shipping' | 'office'
    address: string
    city: string
    province: string
    postalCode: string
    country: string
    isDefault: boolean
  }[]
  
  // 元数据
  metadata: {
    createdAt: string
    updatedAt: string
    status: string
    tags?: string[]
    customFields?: Record<string, any>
  }
}
```

#### 2.1.2 产品数据模型
```typescript
interface ProductData {
  // 基础信息
  externalId: string          // ERP系统中的产品ID
  sku: string                 // 产品编码
  name: string                // 产品名称
  description?: string
  
  // 分类信息
  category: {
    id: string
    name: string
    path: string[]
  }
  
  // 规格信息
  specifications: {
    key: string
    value: string
    unit?: string
  }[]
  
  // 价格信息
  pricing: {
    standardPrice: number
    costPrice?: number
    currency: string
    priceUnit: string
    taxRate?: number
  }
  
  // 库存信息
  inventory?: {
    quantity: number
    unit: string
    warehouse?: string
    minOrderQuantity?: number
    maxOrderQuantity?: number
  }
  
  // 供应商信息
  supplier?: {
    id: string
    name: string
    leadTime?: number
  }
  
  // 媒体资源
  media?: {
    images: string[]
    videos?: string[]
    documents?: string[]
  }
  
  // 元数据
  metadata: {
    createdAt: string
    updatedAt: string
    status: 'active' | 'inactive' | 'discontinued'
    tags?: string[]
  }
}
```

#### 2.1.3 订单数据模型
```typescript
interface OrderData {
  // 基础信息
  externalId: string          // ERP系统中的订单ID
  orderNumber: string         // 订单编号
  orderType: 'sales' | 'purchase'
  
  // 客户信息
  customer: {
    id: string
    name: string
    code?: string
  }
  
  // 订单项
  items: {
    lineNumber: number
    product: {
      id: string
      sku: string
      name: string
    }
    quantity: number
    unit: string
    unitPrice: number
    discount?: number
    taxRate?: number
    subtotal: number
    notes?: string
  }[]
  
  // 金额信息
  amounts: {
    subtotal: number
    taxAmount: number
    discountAmount: number
    shippingAmount?: number
    totalAmount: number
    currency: string
  }
  
  // 交付信息
  delivery?: {
    address: string
    city: string
    province: string
    postalCode: string
    expectedDate?: string
    actualDate?: string
    trackingNumber?: string
  }
  
  // 支付信息
  payment?: {
    method: string
    terms: string
    dueDate?: string
    paidAmount?: number
    paidDate?: string
  }
  
  // 状态信息
  status: {
    code: string
    name: string
    updatedAt: string
  }
  
  // 关联信息
  references?: {
    proposalId?: string
    quotationId?: string
    contractId?: string
  }
  
  // 元数据
  metadata: {
    createdAt: string
    updatedAt: string
    createdBy?: string
    notes?: string
  }
}
```

### 2.2 标准化API接口

#### 2.2.1 客户数据接口

**获取客户列表**
```http
GET /erp/customers
Query Parameters:
  - page: number
  - limit: number
  - updatedSince: ISO8601 datetime
  - status: string

Response:
{
  "success": true,
  "data": {
    "items": CustomerData[],
    "pagination": {
      "page": 1,
      "limit": 50,
      "total": 150,
      "hasMore": true
    }
  }
}
```

**获取单个客户**
```http
GET /erp/customers/{externalId}

Response:
{
  "success": true,
  "data": CustomerData
}
```

**创建客户**
```http
POST /erp/customers
Body: CustomerData

Response:
{
  "success": true,
  "data": {
    "externalId": "string",
    "code": "string"
  }
}
```

**更新客户**
```http
PUT /erp/customers/{externalId}
Body: Partial<CustomerData>

Response:
{
  "success": true,
  "data": {
    "externalId": "string",
    "updatedAt": "ISO8601"
  }
}
```

#### 2.2.2 产品数据接口

**获取产品列表**
```http
GET /erp/products
Query Parameters:
  - page: number
  - limit: number
  - category: string
  - updatedSince: ISO8601 datetime
  - status: string

Response:
{
  "success": true,
  "data": {
    "items": ProductData[],
    "pagination": {...}
  }
}
```

**获取产品库存**
```http
GET /erp/products/{externalId}/inventory

Response:
{
  "success": true,
  "data": {
    "quantity": number,
    "unit": string,
    "warehouses": [
      {
        "id": "string",
        "name": "string",
        "quantity": number
      }
    ],
    "updatedAt": "ISO8601"
  }
}
```

#### 2.2.3 订单数据接口

**创建订单**
```http
POST /erp/orders
Body: OrderData

Response:
{
  "success": true,
  "data": {
    "externalId": "string",
    "orderNumber": "string",
    "status": "string"
  }
}
```

**获取订单状态**
```http
GET /erp/orders/{externalId}/status

Response:
{
  "success": true,
  "data": {
    "status": {
      "code": "string",
      "name": "string",
      "updatedAt": "ISO8601"
    },
    "timeline": [
      {
        "status": "string",
        "timestamp": "ISO8601",
        "notes": "string"
      }
    ]
  }
}
```

### 2.3 Webhook回调机制

#### 2.3.1 Webhook配置
```typescript
interface WebhookConfig {
  url: string                 // 回调URL
  events: string[]            // 订阅的事件
  secret: string              // 签名密钥
  retryPolicy: {
    maxRetries: number
    retryDelay: number        // 毫秒
    backoffMultiplier: number
  }
}
```

#### 2.3.2 Webhook事件格式
```json
{
  "id": "uuid",
  "event": "customer.updated",
  "timestamp": "2026-02-04T16:00:00Z",
  "source": "yonyou_erp",
  "data": {
    "externalId": "CUST-001",
    "changes": {
      "name": {
        "old": "旧名称",
        "new": "新名称"
      }
    }
  },
  "signature": "sha256=..."
}
```

#### 2.3.3 支持的事件类型
```
客户事件:
- customer.created
- customer.updated
- customer.deleted

产品事件:
- product.created
- product.updated
- product.deleted
- product.inventory.changed

订单事件:
- order.created
- order.updated
- order.status.changed
- order.shipped
- order.delivered
- order.cancelled

发票事件:
- invoice.created
- invoice.paid
- invoice.overdue
```

---

## 3. 用友ERP集成

### 3.1 用友U8集成

#### 3.1.1 认证方式
```typescript
interface YonyouU8Auth {
  apiUrl: string              // API基础URL
  accountNumber: string       // 账套号
  username: string            // 用户名
  password: string            // 密码
  appKey: string              // 应用密钥
  appSecret: string           // 应用密钥
}
```

#### 3.1.2 客户数据映射
```typescript
// 用友U8客户表 (Customer)
const customerMapping = {
  // 提案系统 → 用友U8
  'externalId': 'cCusCode',           // 客户编码
  'name': 'cCusName',                 // 客户名称
  'contacts[0].name': 'cCusDefine1',  // 联系人
  'contacts[0].phone': 'cCusDefine2', // 联系电话
  'addresses[0].address': 'cCusAddress', // 地址
  'companyInfo.taxNumber': 'cTaxNumber', // 税号
  'financialInfo.creditLimit': 'iCreditLimit', // 信用额度
  'metadata.status': 'bCusState'      // 客户状态
}
```

#### 3.1.3 API调用示例
```typescript
class YonyouU8Adapter {
  async getCustomers(params: QueryParams): Promise<CustomerData[]> {
    // 1. 获取访问令牌
    const token = await this.authenticate()
    
    // 2. 调用用友API
    const response = await axios.post(
      `${this.config.apiUrl}/api/customer/query`,
      {
        accountNumber: this.config.accountNumber,
        page: params.page,
        pageSize: params.limit,
        condition: params.filters
      },
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    )
    
    // 3. 数据映射转换
    return response.data.data.map(item => 
      this.mapToStandardCustomer(item)
    )
  }
  
  private mapToStandardCustomer(u8Customer: any): CustomerData {
    return {
      externalId: u8Customer.cCusCode,
      name: u8Customer.cCusName,
      code: u8Customer.cCusCode,
      type: 'company',
      contacts: [{
        name: u8Customer.cCusDefine1 || '',
        phone: u8Customer.cCusDefine2 || '',
        email: u8Customer.cCusDefine3 || '',
        isPrimary: true
      }],
      addresses: [{
        type: 'office',
        address: u8Customer.cCusAddress || '',
        city: u8Customer.cCusCity || '',
        province: u8Customer.cCusProvince || '',
        postalCode: u8Customer.cCusPostCode || '',
        country: '中国',
        isDefault: true
      }],
      companyInfo: {
        legalName: u8Customer.cCusName,
        taxNumber: u8Customer.cTaxNumber || '',
        industry: u8Customer.cIndustry || '',
        registeredAddress: u8Customer.cCusAddress || ''
      },
      financialInfo: {
        creditLimit: u8Customer.iCreditLimit || 0,
        paymentTerms: u8Customer.cPaymentTerms || '',
        currency: 'CNY'
      },
      metadata: {
        createdAt: u8Customer.dCreateDate,
        updatedAt: u8Customer.dModifyDate,
        status: u8Customer.bCusState ? 'active' : 'inactive'
      }
    }
  }
}
```

### 3.2 用友NC集成

#### 3.2.1 认证方式（OAuth2）
```typescript
interface YonyouNCAuth {
  apiUrl: string
  clientId: string
  clientSecret: string
  tenantId: string
}

async function authenticateNC(config: YonyouNCAuth): Promise<string> {
  const response = await axios.post(
    `${config.apiUrl}/oauth/token`,
    {
      grant_type: 'client_credentials',
      client_id: config.clientId,
      client_secret: config.clientSecret,
      tenant_id: config.tenantId
    }
  )
  
  return response.data.access_token
}
```

#### 3.2.2 产品数据同步
```typescript
async function syncProductsFromNC(adapter: YonyouNCAdapter) {
  const products = await adapter.getProducts({
    updatedSince: getLastSyncTime(),
    limit: 100
  })
  
  for (const product of products) {
    await upsertProduct({
      externalId: product.externalId,
      sku: product.sku,
      name: product.name,
      // ... 其他字段
    })
  }
  
  updateLastSyncTime()
}
```

---

## 4. 金蝶ERP集成

### 4.1 金蝶K3集成

#### 4.1.1 认证方式
```typescript
interface KingdeeK3Auth {
  apiUrl: string
  dbId: string                // 账套ID
  username: string
  password: string
  language: 'zh-CN' | 'en-US'
}
```

#### 4.1.2 客户数据映射
```typescript
const k3CustomerMapping = {
  'externalId': 'FNumber',            // 客户编码
  'name': 'FName',                    // 客户名称
  'contacts[0].name': 'FContact',     // 联系人
  'contacts[0].phone': 'FPhone',      // 电话
  'addresses[0].address': 'FAddress', // 地址
  'companyInfo.taxNumber': 'FTaxNo',  // 税号
  'metadata.status': 'FStatus'        // 状态
}
```

#### 4.1.3 API调用示例
```typescript
class KingdeeK3Adapter {
  async createCustomer(customer: CustomerData): Promise<string> {
    const token = await this.authenticate()
    
    const k3Customer = {
      FNumber: customer.code,
      FName: customer.name,
      FContact: customer.contacts[0]?.name,
      FPhone: customer.contacts[0]?.phone,
      FAddress: customer.addresses[0]?.address,
      FTaxNo: customer.companyInfo?.taxNumber
    }
    
    const response = await axios.post(
      `${this.config.apiUrl}/K3Cloud/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc`,
      {
        formid: 'BD_Customer',
        data: {
          Model: k3Customer
        }
      },
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    )
    
    return response.data.Result.Id
  }
}
```

### 4.2 金蝶云星空集成

#### 4.2.1 OAuth2认证
```typescript
async function authenticateKingdeeCloud(config: KingdeeCloudAuth) {
  const response = await axios.post(
    `${config.apiUrl}/auth/token`,
    {
      acct_id: config.accountId,
      username: config.username,
      password: config.password,
      app_id: config.appId,
      app_secret: config.appSecret
    }
  )
  
  return response.data.access_token
}
```

#### 4.2.2 订单推送
```typescript
async function pushOrderToKingdee(order: OrderData) {
  const adapter = new KingdeeCloudAdapter(config)
  
  const k3Order = {
    FBillNo: order.orderNumber,
    FCustomerId: order.customer.id,
    FDate: order.metadata.createdAt,
    FEntity: order.items.map(item => ({
      FMaterialId: item.product.id,
      FQty: item.quantity,
      FPrice: item.unitPrice,
      FAmount: item.subtotal
    }))
  }
  
  const result = await adapter.createSalesOrder(k3Order)
  
  // 保存ERP订单ID
  await updateOrderERPReference(order.externalId, result.orderId)
}
```


---

## 5. SAP集成

### 5.1 SAP Business One集成

#### 5.1.1 Service Layer认证
```typescript
interface SAPB1Auth {
  serviceLayerUrl: string
  companyDB: string
  username: string
  password: string
}

async function authenticateSAPB1(config: SAPB1Auth) {
  const response = await axios.post(
    `${config.serviceLayerUrl}/Login`,
    {
      CompanyDB: config.companyDB,
      UserName: config.username,
      Password: config.password
    }
  )
  
  return {
    sessionId: response.data.SessionId,
    cookies: response.headers['set-cookie']
  }
}
```

#### 5.1.2 客户数据操作
```typescript
class SAPB1Adapter {
  async getBusinessPartners(params: QueryParams): Promise<CustomerData[]> {
    const auth = await this.authenticate()
    
    const response = await axios.get(
      `${this.config.serviceLayerUrl}/BusinessPartners`,
      {
        params: {
          $select: 'CardCode,CardName,Phone1,EmailAddress,Address',
          $filter: params.filters,
          $skip: (params.page - 1) * params.limit,
          $top: params.limit
        },
        headers: {
          'Cookie': auth.cookies.join('; ')
        }
      }
    )
    
    return response.data.value.map(bp => this.mapToStandardCustomer(bp))
  }
  
  async createBusinessPartner(customer: CustomerData): Promise<string> {
    const auth = await this.authenticate()
    
    const sapCustomer = {
      CardCode: customer.code,
      CardName: customer.name,
      CardType: 'cCustomer',
      Phone1: customer.contacts[0]?.phone,
      EmailAddress: customer.contacts[0]?.email,
      Address: customer.addresses[0]?.address,
      FederalTaxID: customer.companyInfo?.taxNumber
    }
    
    const response = await axios.post(
      `${this.config.serviceLayerUrl}/BusinessPartners`,
      sapCustomer,
      {
        headers: {
          'Cookie': auth.cookies.join('; '),
          'Content-Type': 'application/json'
        }
      }
    )
    
    return response.data.CardCode
  }
}
```

#### 5.1.3 订单创建
```typescript
async function createSalesOrder(order: OrderData, adapter: SAPB1Adapter) {
  const sapOrder = {
    CardCode: order.customer.code,
    DocDate: order.metadata.createdAt,
    DocDueDate: order.payment?.dueDate,
    DocumentLines: order.items.map((item, index) => ({
      LineNum: index,
      ItemCode: item.product.sku,
      Quantity: item.quantity,
      Price: item.unitPrice,
      DiscountPercent: item.discount || 0,
      TaxCode: 'VAT'
    }))
  }
  
  const result = await adapter.createOrder(sapOrder)
  return result.DocEntry
}
```

### 5.2 SAP S/4HANA集成

#### 5.2.1 OData API认证
```typescript
interface SAPS4Auth {
  apiUrl: string
  clientId: string
  clientSecret: string
  tokenUrl: string
}

async function authenticateSAPS4(config: SAPS4Auth) {
  const response = await axios.post(
    config.tokenUrl,
    new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: config.clientId,
      client_secret: config.clientSecret
    }),
    {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }
  )
  
  return response.data.access_token
}
```

#### 5.2.2 客户主数据同步
```typescript
async function syncCustomersFromS4(adapter: SAPS4Adapter) {
  const token = await adapter.authenticate()
  
  const response = await axios.get(
    `${adapter.config.apiUrl}/sap/opu/odata/sap/API_BUSINESS_PARTNER/A_BusinessPartner`,
    {
      params: {
        $select: 'BusinessPartner,BusinessPartnerName,BusinessPartnerCategory',
        $filter: "BusinessPartnerCategory eq '2'", // 客户
        $top: 100
      },
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json'
      }
    }
  )
  
  for (const bp of response.data.d.results) {
    await upsertCustomer(adapter.mapToStandardCustomer(bp))
  }
}
```

---

## 6. 自定义ERP集成

### 6.1 适配器接口定义

```typescript
interface ERPAdapter {
  // 认证
  authenticate(): Promise<AuthToken>
  
  // 客户管理
  getCustomers(params: QueryParams): Promise<CustomerData[]>
  getCustomer(id: string): Promise<CustomerData>
  createCustomer(customer: CustomerData): Promise<string>
  updateCustomer(id: string, customer: Partial<CustomerData>): Promise<void>
  
  // 产品管理
  getProducts(params: QueryParams): Promise<ProductData[]>
  getProduct(id: string): Promise<ProductData>
  getProductInventory(id: string): Promise<InventoryData>
  
  // 订单管理
  createOrder(order: OrderData): Promise<string>
  getOrder(id: string): Promise<OrderData>
  updateOrderStatus(id: string, status: string): Promise<void>
  
  // Webhook支持
  registerWebhook(config: WebhookConfig): Promise<string>
  unregisterWebhook(id: string): Promise<void>
  
  // 健康检查
  healthCheck(): Promise<boolean>
}
```

### 6.2 自定义适配器实现示例

```typescript
class CustomERPAdapter implements ERPAdapter {
  private config: CustomERPConfig
  private httpClient: AxiosInstance
  
  constructor(config: CustomERPConfig) {
    this.config = config
    this.httpClient = axios.create({
      baseURL: config.apiUrl,
      timeout: 30000
    })
  }
  
  async authenticate(): Promise<AuthToken> {
    const response = await this.httpClient.post('/auth/login', {
      username: this.config.username,
      password: this.config.password
    })
    
    return {
      token: response.data.token,
      expiresAt: new Date(response.data.expiresAt)
    }
  }
  
  async getCustomers(params: QueryParams): Promise<CustomerData[]> {
    const token = await this.authenticate()
    
    const response = await this.httpClient.get('/customers', {
      params: {
        page: params.page,
        limit: params.limit,
        updated_since: params.updatedSince
      },
      headers: {
        'Authorization': `Bearer ${token.token}`
      }
    })
    
    return response.data.customers.map(c => this.mapCustomer(c))
  }
  
  private mapCustomer(erpCustomer: any): CustomerData {
    // 实现自定义映射逻辑
    return {
      externalId: erpCustomer.id,
      name: erpCustomer.name,
      // ... 其他字段映射
    }
  }
  
  async createOrder(order: OrderData): Promise<string> {
    const token = await this.authenticate()
    
    const erpOrder = this.mapOrderToERP(order)
    
    const response = await this.httpClient.post('/orders', erpOrder, {
      headers: {
        'Authorization': `Bearer ${token.token}`
      }
    })
    
    return response.data.orderId
  }
  
  async healthCheck(): Promise<boolean> {
    try {
      const response = await this.httpClient.get('/health')
      return response.status === 200
    } catch (error) {
      return false
    }
  }
}
```

### 6.3 适配器注册

```typescript
class ERPAdapterRegistry {
  private adapters: Map<string, ERPAdapter> = new Map()
  
  register(name: string, adapter: ERPAdapter): void {
    this.adapters.set(name, adapter)
  }
  
  get(name: string): ERPAdapter | undefined {
    return this.adapters.get(name)
  }
  
  list(): string[] {
    return Array.from(this.adapters.keys())
  }
}

// 使用示例
const registry = new ERPAdapterRegistry()

registry.register('yonyou_u8', new YonyouU8Adapter(config))
registry.register('kingdee_k3', new KingdeeK3Adapter(config))
registry.register('sap_b1', new SAPB1Adapter(config))
registry.register('custom', new CustomERPAdapter(config))
```

---

## 7. 数据同步策略

### 7.1 同步调度器

```typescript
class SyncScheduler {
  private jobs: Map<string, SyncJob> = new Map()
  
  async scheduleSync(config: SyncConfig): Promise<string> {
    const job: SyncJob = {
      id: uuid(),
      connectionId: config.connectionId,
      syncType: config.syncType,
      direction: config.direction,
      schedule: config.schedule,
      enabled: true
    }
    
    this.jobs.set(job.id, job)
    
    // 注册定时任务
    if (config.schedule.type === 'cron') {
      cron.schedule(config.schedule.expression, () => {
        this.executeSyncJob(job.id)
      })
    }
    
    return job.id
  }
  
  async executeSyncJob(jobId: string): Promise<void> {
    const job = this.jobs.get(jobId)
    if (!job || !job.enabled) return
    
    const log = await this.createSyncLog(job)
    
    try {
      const adapter = this.getAdapter(job.connectionId)
      
      switch (job.syncType) {
        case 'customer':
          await this.syncCustomers(adapter, job, log)
          break
        case 'product':
          await this.syncProducts(adapter, job, log)
          break
        case 'order':
          await this.syncOrders(adapter, job, log)
          break
      }
      
      await this.updateSyncLog(log.id, {
        status: 'completed',
        completedAt: new Date()
      })
    } catch (error) {
      await this.updateSyncLog(log.id, {
        status: 'failed',
        errorDetails: error.message,
        completedAt: new Date()
      })
      
      // 发送告警
      await this.sendAlert(job, error)
    }
  }
  
  private async syncCustomers(
    adapter: ERPAdapter,
    job: SyncJob,
    log: SyncLog
  ): Promise<void> {
    const lastSyncTime = await this.getLastSyncTime(job.id)
    let page = 1
    let hasMore = true
    
    while (hasMore) {
      const customers = await adapter.getCustomers({
        page,
        limit: 100,
        updatedSince: lastSyncTime
      })
      
      for (const customer of customers) {
        try {
          if (job.direction === 'import') {
            await this.importCustomer(customer)
            log.recordsSuccess++
          } else if (job.direction === 'export') {
            await this.exportCustomer(customer, adapter)
            log.recordsSuccess++
          }
        } catch (error) {
          log.recordsFailed++
          log.errorDetails.push({
            customerId: customer.externalId,
            error: error.message
          })
        }
      }
      
      log.recordsTotal += customers.length
      await this.updateSyncLog(log.id, log)
      
      hasMore = customers.length === 100
      page++
    }
    
    await this.updateLastSyncTime(job.id, new Date())
  }
}
```

### 7.2 增量同步

```typescript
interface IncrementalSyncConfig {
  connectionId: string
  syncType: 'customer' | 'product' | 'order'
  lastSyncTime: Date
  batchSize: number
}

async function performIncrementalSync(config: IncrementalSyncConfig) {
  const adapter = getAdapter(config.connectionId)
  
  // 获取增量数据
  const changes = await adapter.getChanges({
    type: config.syncType,
    since: config.lastSyncTime,
    limit: config.batchSize
  })
  
  // 处理变更
  for (const change of changes) {
    switch (change.operation) {
      case 'create':
      case 'update':
        await upsertRecord(change.data)
        break
      case 'delete':
        await deleteRecord(change.id)
        break
    }
  }
  
  // 更新同步时间戳
  await updateSyncTimestamp(config.connectionId, new Date())
}
```

### 7.3 冲突解决策略

```typescript
enum ConflictResolutionStrategy {
  SOURCE_WINS = 'source_wins',      // 源系统优先
  TARGET_WINS = 'target_wins',      // 目标系统优先
  LATEST_WINS = 'latest_wins',      // 最新修改优先
  MANUAL = 'manual'                 // 手动解决
}

class ConflictResolver {
  async resolveConflict(
    conflict: DataConflict,
    strategy: ConflictResolutionStrategy
  ): Promise<ResolvedData> {
    switch (strategy) {
      case ConflictResolutionStrategy.SOURCE_WINS:
        return conflict.sourceData
        
      case ConflictResolutionStrategy.TARGET_WINS:
        return conflict.targetData
        
      case ConflictResolutionStrategy.LATEST_WINS:
        return conflict.sourceUpdatedAt > conflict.targetUpdatedAt
          ? conflict.sourceData
          : conflict.targetData
          
      case ConflictResolutionStrategy.MANUAL:
        // 创建冲突记录，等待人工处理
        await this.createConflictRecord(conflict)
        throw new ConflictRequiresManualResolution()
    }
  }
}
```

---

## 8. 错误处理与重试

### 8.1 错误分类

```typescript
enum ERPErrorType {
  AUTHENTICATION_ERROR = 'authentication_error',
  AUTHORIZATION_ERROR = 'authorization_error',
  NETWORK_ERROR = 'network_error',
  TIMEOUT_ERROR = 'timeout_error',
  VALIDATION_ERROR = 'validation_error',
  BUSINESS_LOGIC_ERROR = 'business_logic_error',
  RATE_LIMIT_ERROR = 'rate_limit_error',
  UNKNOWN_ERROR = 'unknown_error'
}

class ERPError extends Error {
  constructor(
    public type: ERPErrorType,
    public message: string,
    public details?: any,
    public retryable: boolean = false
  ) {
    super(message)
  }
}
```

### 8.2 重试机制

```typescript
class RetryPolicy {
  constructor(
    public maxRetries: number = 3,
    public initialDelay: number = 1000,
    public maxDelay: number = 30000,
    public backoffMultiplier: number = 2
  ) {}
  
  async execute<T>(
    operation: () => Promise<T>,
    errorHandler?: (error: Error) => boolean
  ): Promise<T> {
    let lastError: Error
    let delay = this.initialDelay
    
    for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
      try {
        return await operation()
      } catch (error) {
        lastError = error
        
        // 检查是否应该重试
        if (attempt === this.maxRetries) {
          break
        }
        
        if (error instanceof ERPError && !error.retryable) {
          throw error
        }
        
        if (errorHandler && !errorHandler(error)) {
          throw error
        }
        
        // 等待后重试
        await this.sleep(delay)
        delay = Math.min(delay * this.backoffMultiplier, this.maxDelay)
        
        console.log(`Retry attempt ${attempt + 1}/${this.maxRetries}`)
      }
    }
    
    throw lastError
  }
  
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}

// 使用示例
const retryPolicy = new RetryPolicy(3, 1000, 30000, 2)

const result = await retryPolicy.execute(
  async () => {
    return await adapter.getCustomers({ page: 1, limit: 100 })
  },
  (error) => {
    // 只重试网络错误和超时错误
    return error instanceof ERPError && 
           (error.type === ERPErrorType.NETWORK_ERROR ||
            error.type === ERPErrorType.TIMEOUT_ERROR)
  }
)
```

### 8.3 断点续传

```typescript
class ResumableSync {
  async syncWithCheckpoint(
    adapter: ERPAdapter,
    syncType: string,
    checkpointKey: string
  ): Promise<void> {
    // 获取上次中断的位置
    const checkpoint = await this.getCheckpoint(checkpointKey)
    
    let page = checkpoint?.page || 1
    let processedCount = checkpoint?.processedCount || 0
    
    try {
      while (true) {
        const items = await adapter.getItems({
          type: syncType,
          page,
          limit: 100
        })
        
        if (items.length === 0) break
        
        for (const item of items) {
          await this.processItem(item)
          processedCount++
          
          // 定期保存检查点
          if (processedCount % 10 === 0) {
            await this.saveCheckpoint(checkpointKey, {
              page,
              processedCount,
              lastItemId: item.id,
              timestamp: new Date()
            })
          }
        }
        
        page++
      }
      
      // 同步完成，清除检查点
      await this.clearCheckpoint(checkpointKey)
    } catch (error) {
      // 保存当前进度
      await this.saveCheckpoint(checkpointKey, {
        page,
        processedCount,
        error: error.message,
        timestamp: new Date()
      })
      
      throw error
    }
  }
}
```

---

## 9. 安全与认证

### 9.1 API密钥管理

```typescript
class APIKeyManager {
  async createAPIKey(connectionId: string): Promise<APIKey> {
    const key = this.generateSecureKey()
    const hashedKey = await bcrypt.hash(key, 10)
    
    const apiKey = await prisma.erpAPIKey.create({
      data: {
        connectionId,
        keyHash: hashedKey,
        expiresAt: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
        permissions: ['read', 'write']
      }
    })
    
    return {
      id: apiKey.id,
      key: key, // 只返回一次
      expiresAt: apiKey.expiresAt
    }
  }
  
  async validateAPIKey(key: string): Promise<boolean> {
    const apiKeys = await prisma.erpAPIKey.findMany({
      where: {
        expiresAt: { gt: new Date() },
        revoked: false
      }
    })
    
    for (const apiKey of apiKeys) {
      const isValid = await bcrypt.compare(key, apiKey.keyHash)
      if (isValid) {
        // 更新最后使用时间
        await prisma.erpAPIKey.update({
          where: { id: apiKey.id },
          data: { lastUsedAt: new Date() }
        })
        return true
      }
    }
    
    return false
  }
  
  private generateSecureKey(): string {
    return crypto.randomBytes(32).toString('base64')
  }
}
```

### 9.2 数据加密

```typescript
class DataEncryption {
  private algorithm = 'aes-256-gcm'
  private key: Buffer
  
  constructor(encryptionKey: string) {
    this.key = Buffer.from(encryptionKey, 'hex')
  }
  
  encrypt(data: string): EncryptedData {
    const iv = crypto.randomBytes(16)
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv)
    
    let encrypted = cipher.update(data, 'utf8', 'hex')
    encrypted += cipher.final('hex')
    
    const authTag = cipher.getAuthTag()
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    }
  }
  
  decrypt(encryptedData: EncryptedData): string {
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(encryptedData.iv, 'hex')
    )
    
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'))
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8')
    decrypted += decipher.final('utf8')
    
    return decrypted
  }
}

// 存储敏感配置
async function storeERPCredentials(connectionId: string, credentials: any) {
  const encryption = new DataEncryption(process.env.ENCRYPTION_KEY)
  
  const encryptedPassword = encryption.encrypt(credentials.password)
  const encryptedApiSecret = encryption.encrypt(credentials.apiSecret)
  
  await prisma.erpConnection.update({
    where: { id: connectionId },
    data: {
      passwordEncrypted: JSON.stringify(encryptedPassword),
      apiSecretEncrypted: JSON.stringify(encryptedApiSecret)
    }
  })
}
```

### 9.3 审计日志

```typescript
async function logERPOperation(operation: ERPOperation) {
  await prisma.erpAuditLog.create({
    data: {
      connectionId: operation.connectionId,
      operationType: operation.type,
      resourceType: operation.resourceType,
      resourceId: operation.resourceId,
      action: operation.action,
      userId: operation.userId,
      ipAddress: operation.ipAddress,
      requestData: operation.requestData,
      responseData: operation.responseData,
      status: operation.status,
      errorMessage: operation.errorMessage,
      duration: operation.duration,
      timestamp: new Date()
    }
  })
}
```

---

## 10. 监控与告警

### 10.1 健康检查

```typescript
class ERPHealthMonitor {
  async checkHealth(connectionId: string): Promise<HealthStatus> {
    const connection = await this.getConnection(connectionId)
    const adapter = this.getAdapter(connection)
    
    const startTime = Date.now()
    
    try {
      const isHealthy = await adapter.healthCheck()
      const responseTime = Date.now() - startTime
      
      return {
        status: isHealthy ? 'healthy' : 'unhealthy',
        responseTime,
        lastChecked: new Date()
      }
    } catch (error) {
      return {
        status: 'error',
        responseTime: Date.now() - startTime,
        error: error.message,
        lastChecked: new Date()
      }
    }
  }
  
  async monitorAllConnections(): Promise<void> {
    const connections = await prisma.erpConnection.findMany({
      where: { isActive: true }
    })
    
    for (const connection of connections) {
      const health = await this.checkHealth(connection.id)
      
      await prisma.erpConnection.update({
        where: { id: connection.id },
        data: {
          healthStatus: health.status,
          lastHealthCheck: health.lastChecked
        }
      })
      
      // 如果不健康，发送告警
      if (health.status !== 'healthy') {
        await this.sendAlert(connection, health)
      }
    }
  }
}
```

### 10.2 性能监控

```typescript
class ERPPerformanceMonitor {
  async recordMetrics(operation: ERPOperation, duration: number) {
    await prometheus.histogram('erp_operation_duration', {
      connection: operation.connectionId,
      operation: operation.type,
      status: operation.status
    }).observe(duration)
    
    await prometheus.counter('erp_operation_total', {
      connection: operation.connectionId,
      operation: operation.type,
      status: operation.status
    }).inc()
  }
}
```

---

## 附录

### A. 测试清单

- [ ] 认证测试
- [ ] 客户数据同步测试
- [ ] 产品数据同步测试
- [ ] 订单创建测试
- [ ] 错误处理测试
- [ ] 重试机制测试
- [ ] 性能测试
- [ ] 安全测试

### B. 故障排查指南

1. **认证失败**: 检查API密钥、用户名密码是否正确
2. **同步失败**: 查看同步日志，检查数据映射
3. **性能问题**: 调整批次大小，优化查询
4. **数据不一致**: 检查冲突解决策略

---

**文档版本**: 1.0  
**最后更新**: 2026年2月4日  
**维护团队**: ERP集成组
