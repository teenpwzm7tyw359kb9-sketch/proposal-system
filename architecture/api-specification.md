# 提案展示系统API规范文档

## 文档信息
- **版本**: 1.0
- **最后更新**: 2026年2月4日
- **API基础URL**: `https://api.proposal-system.com/v1`
- **协议**: HTTPS
- **认证方式**: JWT Bearer Token

## 目录
1. [认证与授权](#1-认证与授权)
2. [提案管理](#2-提案管理)
3. [作品集管理](#3-作品集管理)
4. [模板管理](#4-模板管理)
5. [预约管理](#5-预约管理)
6. [日历管理](#6-日历管理)
7. [AI集成](#7-ai集成)
8. [产品报价](#8-产品报价)
9. [客户管理](#9-客户管理)
10. [文件管理](#10-文件管理)
11. [通用规范](#11-通用规范)

---

## 1. 认证与授权

### 1.1 用户注册

**端点**: `POST /auth/register`

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "张三",
  "phone": "13800138000",
  "companyName": "设计公司名称"
}
```

**响应**: `201 Created`
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "张三",
      "status": "active"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 900
  }
}
```

### 1.2 用户登录

**端点**: `POST /auth/login`

**请求体**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "张三",
      "avatar": "https://cdn.example.com/avatar.jpg",
      "roles": ["editor"],
      "company": {
        "id": "uuid",
        "name": "设计公司",
        "subscriptionPlan": "professional"
      }
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 900
  }
}
```

### 1.3 刷新Token

**端点**: `POST /auth/refresh`

**请求体**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 900
  }
}
```

### 1.4 登出

**端点**: `POST /auth/logout`

**请求头**:
```
Authorization: Bearer {accessToken}
```

**请求体**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "message": "登出成功"
}
```

### 1.5 OAuth2认证（微信、企业微信）

**端点**: `GET /auth/oauth/{provider}`

**参数**:
- `provider`: `wechat` | `wework` | `dingtalk`

**响应**: 重定向到OAuth提供商授权页面

**回调端点**: `GET /auth/oauth/{provider}/callback`

---

## 2. 提案管理

### 2.1 获取提案列表

**端点**: `GET /proposals`

**查询参数**:
- `page`: 页码（默认: 1）
- `limit`: 每页数量（默认: 20，最大: 100）
- `status`: 状态筛选 (`draft` | `published` | `archived`)
- `customerId`: 客户ID筛选
- `search`: 搜索关键词
- `sortBy`: 排序字段 (`createdAt` | `updatedAt` | `title`)
- `sortOrder`: 排序方向 (`asc` | `desc`)

**请求头**:
```
Authorization: Bearer {accessToken}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "title": "现代简约住宅设计方案",
        "description": "120平米现代简约风格设计",
        "status": "published",
        "coverImage": "https://cdn.example.com/cover.jpg",
        "customer": {
          "id": "uuid",
          "name": "李四"
        },
        "viewCount": 156,
        "shareCount": 12,
        "createdAt": "2026-02-01T10:00:00Z",
        "updatedAt": "2026-02-04T15:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

### 2.2 获取提案详情

**端点**: `GET /proposals/{id}`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "现代简约住宅设计方案",
    "description": "120平米现代简约风格设计",
    "status": "published",
    "coverImage": "https://cdn.example.com/cover.jpg",
    "projectType": "residential",
    "projectArea": 120.5,
    "budgetMin": 200000,
    "budgetMax": 300000,
    "projectAddress": "北京市朝阳区",
    "customer": {
      "id": "uuid",
      "name": "李四",
      "phone": "13900139000"
    },
    "pages": [
      {
        "id": "uuid",
        "pageNumber": 1,
        "pageType": "cover",
        "title": "封面",
        "content": {}
      }
    ],
    "tags": ["现代简约", "住宅", "120平"],
    "viewCount": 156,
    "shareCount": 12,
    "publishedAt": "2026-02-01T10:00:00Z",
    "createdAt": "2026-02-01T09:00:00Z",
    "updatedAt": "2026-02-04T15:30:00Z"
  }
}
```

### 2.3 创建提案

**端点**: `POST /proposals`

**请求体**:
```json
{
  "title": "新提案标题",
  "description": "提案描述",
  "customerId": "uuid",
  "templateId": "uuid",
  "projectType": "residential",
  "projectArea": 120.5,
  "budgetMin": 200000,
  "budgetMax": 300000,
  "projectAddress": "北京市朝阳区",
  "tags": ["现代简约", "住宅"]
}
```

**响应**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "新提案标题",
    "status": "draft",
    "createdAt": "2026-02-04T16:00:00Z"
  }
}
```

### 2.4 更新提案

**端点**: `PUT /proposals/{id}`

**请求体**:
```json
{
  "title": "更新后的标题",
  "description": "更新后的描述",
  "coverImage": "https://cdn.example.com/new-cover.jpg",
  "status": "published"
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "更新后的标题",
    "updatedAt": "2026-02-04T16:30:00Z"
  }
}
```

### 2.5 删除提案

**端点**: `DELETE /proposals/{id}`

**响应**: `200 OK`
```json
{
  "success": true,
  "message": "提案已删除"
}
```

### 2.6 自动保存提案

**端点**: `POST /proposals/{id}/autosave`

**请求体**:
```json
{
  "content": {
    "pages": []
  }
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "savedAt": "2026-02-04T16:35:00Z"
  }
}
```

### 2.7 创建提案分享链接

**端点**: `POST /proposals/{id}/share`

**请求体**:
```json
{
  "password": "optional-password",
  "expiryDays": 7,
  "allowDownload": false,
  "allowComment": true,
  "watermark": "公司名称",
  "trackViews": true
}
```

**响应**: `201 Created`
```json
{
  "success": true,
  "data": {
    "shareUrl": "https://proposal-system.com/share/abc123xyz",
    "shareCode": "abc123xyz",
    "expiresAt": "2026-02-11T16:00:00Z"
  }
}
```

### 2.8 获取提案访问统计

**端点**: `GET /proposals/{id}/analytics`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "totalViews": 156,
    "uniqueVisitors": 89,
    "averageDuration": 245,
    "completionRate": 0.67,
    "viewsByDate": [
      {
        "date": "2026-02-01",
        "views": 23
      }
    ],
    "viewsByPage": [
      {
        "pageNumber": 1,
        "views": 156,
        "averageDuration": 45
      }
    ],
    "deviceStats": {
      "desktop": 89,
      "mobile": 56,
      "tablet": 11
    }
  }
}
```

### 2.9 获取提案版本历史

**端点**: `GET /proposals/{id}/versions`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "versions": [
      {
        "id": "uuid",
        "versionNumber": 3,
        "title": "版本3",
        "changeSummary": "更新了封面图和预算",
        "createdBy": {
          "id": "uuid",
          "name": "张三"
        },
        "createdAt": "2026-02-04T15:00:00Z"
      }
    ]
  }
}
```

### 2.10 恢复提案版本

**端点**: `POST /proposals/{id}/versions/{versionId}/restore`

**响应**: `200 OK`
```json
{
  "success": true,
  "message": "版本已恢复"
}
```

---

## 3. 作品集管理

### 3.1 获取作品集列表

**端点**: `GET /portfolios`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "title": "我的作品集",
        "slug": "my-portfolio",
        "isPublic": true,
        "itemCount": 24,
        "viewCount": 1234,
        "createdAt": "2026-01-01T00:00:00Z"
      }
    ]
  }
}
```

### 3.2 创建作品集

**端点**: `POST /portfolios`

**请求体**:
```json
{
  "title": "新作品集",
  "description": "作品集描述",
  "slug": "new-portfolio",
  "isPublic": true,
  "seoTitle": "SEO标题",
  "seoDescription": "SEO描述",
  "seoKeywords": ["关键词1", "关键词2"]
}
```

**响应**: `201 Created`

### 3.3 添加作品集项目

**端点**: `POST /portfolios/{id}/items`

**请求体**:
```json
{
  "title": "项目名称",
  "description": "项目描述",
  "projectType": "residential",
  "style": "modern",
  "area": 120.5,
  "budgetRange": "20-30万",
  "location": "北京",
  "completionDate": "2026-01-15",
  "coverImage": "https://cdn.example.com/cover.jpg",
  "images": [
    "https://cdn.example.com/img1.jpg",
    "https://cdn.example.com/img2.jpg"
  ],
  "tags": ["现代", "住宅"]
}
```

**响应**: `201 Created`

---

## 4. 模板管理

### 4.1 获取模板列表

**端点**: `GET /templates`

**查询参数**:
- `category`: 分类筛选
- `style`: 风格筛选
- `isPublic`: 是否公开

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "现代简约住宅模板",
        "description": "适合现代简约风格住宅设计",
        "category": "residential",
        "style": "modern",
        "thumbnail": "https://cdn.example.com/template-thumb.jpg",
        "usageCount": 156,
        "rating": 4.8
      }
    ]
  }
}
```

### 4.2 获取模板详情

**端点**: `GET /templates/{id}`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "现代简约住宅模板",
    "description": "适合现代简约风格住宅设计",
    "category": "residential",
    "content": {
      "pages": []
    },
    "settings": {},
    "previewImages": []
  }
}
```

### 4.3 创建自定义模板

**端点**: `POST /templates`

**请求体**:
```json
{
  "name": "我的自定义模板",
  "description": "模板描述",
  "category": "residential",
  "content": {},
  "isPublic": false
}
```

**响应**: `201 Created`

---

## 5. 预约管理

### 5.1 获取预约列表

**端点**: `GET /appointments`

**查询参数**:
- `startDate`: 开始日期
- `endDate`: 结束日期
- `status`: 状态筛选
- `designerId`: 设计师ID

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "title": "客户咨询",
        "appointmentType": {
          "id": "uuid",
          "name": "初次咨询",
          "duration": 60
        },
        "designer": {
          "id": "uuid",
          "name": "张设计师"
        },
        "customer": {
          "id": "uuid",
          "name": "李四"
        },
        "startTime": "2026-02-05T14:00:00Z",
        "endTime": "2026-02-05T15:00:00Z",
        "status": "confirmed",
        "location": "公司会议室"
      }
    ]
  }
}
```

### 5.2 创建预约

**端点**: `POST /appointments`

**请求体**:
```json
{
  "appointmentTypeId": "uuid",
  "designerId": "uuid",
  "customerId": "uuid",
  "title": "客户咨询",
  "description": "讨论设计方案",
  "startTime": "2026-02-05T14:00:00Z",
  "endTime": "2026-02-05T15:00:00Z",
  "location": "公司会议室"
}
```

**响应**: `201 Created`

### 5.3 更新预约状态

**端点**: `PATCH /appointments/{id}/status`

**请求体**:
```json
{
  "status": "confirmed"
}
```

**响应**: `200 OK`

### 5.4 取消预约

**端点**: `POST /appointments/{id}/cancel`

**请求体**:
```json
{
  "reason": "客户时间冲突"
}
```

**响应**: `200 OK`

---

## 6. 日历管理

### 6.1 获取日历事件

**端点**: `GET /calendar/events`

**查询参数**:
- `startDate`: 开始日期（必需）
- `endDate`: 结束日期（必需）
- `userId`: 用户ID（可选，查看他人日历）

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "events": [
      {
        "id": "uuid",
        "title": "团队会议",
        "description": "周例会",
        "startTime": "2026-02-05T10:00:00Z",
        "endTime": "2026-02-05T11:00:00Z",
        "allDay": false,
        "location": "会议室A",
        "color": "#4CAF50",
        "status": "confirmed"
      }
    ]
  }
}
```

### 6.2 创建日历事件

**端点**: `POST /calendar/events`

**请求体**:
```json
{
  "title": "客户会议",
  "description": "讨论项目进度",
  "startTime": "2026-02-05T14:00:00Z",
  "endTime": "2026-02-05T15:00:00Z",
  "allDay": false,
  "location": "客户办公室",
  "color": "#2196F3",
  "reminderMinutes": [15, 60]
}
```

**响应**: `201 Created`

### 6.3 更新日历事件

**端点**: `PUT /calendar/events/{id}`

**响应**: `200 OK`

### 6.4 删除日历事件

**端点**: `DELETE /calendar/events/{id}`

**响应**: `200 OK`

---

## 7. AI集成

### 7.1 AI图像生成

**端点**: `POST /ai/generate/image`

**请求体**:
```json
{
  "prompt": "现代简约风格的客厅，大落地窗，米白色沙发",
  "spaceType": "living_room",
  "style": "modern",
  "colorTone": "warm",
  "lighting": "natural",
  "size": "1024x1024",
  "count": 1,
  "provider": "openai",
  "model": "dall-e-3"
}
```

**响应**: `202 Accepted`
```json
{
  "success": true,
  "data": {
    "generationId": "uuid",
    "status": "processing",
    "estimatedTime": 30
  }
}
```

### 7.2 获取AI生成结果

**端点**: `GET /ai/generations/{id}`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "completed",
    "generationType": "image",
    "result": {
      "images": [
        {
          "url": "https://cdn.example.com/ai-generated.jpg",
          "width": 1024,
          "height": 1024
        }
      ]
    },
    "tokensUsed": 1000,
    "cost": 0.04,
    "duration": 28000,
    "createdAt": "2026-02-04T16:00:00Z",
    "completedAt": "2026-02-04T16:00:28Z"
  }
}
```

### 7.3 AI文案生成

**端点**: `POST /ai/generate/text`

**请求体**:
```json
{
  "type": "proposal",
  "projectInfo": {
    "name": "现代简约住宅",
    "type": "residential",
    "area": 120,
    "budget": 250000,
    "requirements": "客户需求描述"
  },
  "style": "professional",
  "length": "detailed",
  "keywords": ["现代", "简约", "舒适"],
  "provider": "openai",
  "model": "gpt-4"
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "generationId": "uuid",
    "content": "生成的文案内容...",
    "tokensUsed": 500,
    "cost": 0.01
  }
}
```

### 7.4 AI风格转换

**端点**: `POST /ai/style-transfer`

**请求体**:
```json
{
  "imageUrl": "https://cdn.example.com/original.jpg",
  "targetStyle": "modern",
  "strength": 0.8,
  "preserveLayout": true,
  "provider": "openai"
}
```

**响应**: `202 Accepted`

### 7.5 获取AI使用统计

**端点**: `GET /ai/usage/stats`

**查询参数**:
- `startDate`: 开始日期
- `endDate`: 结束日期

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "totalRequests": 156,
    "totalTokens": 45000,
    "totalCost": 12.50,
    "byProvider": {
      "openai": {
        "requests": 100,
        "tokens": 30000,
        "cost": 8.00
      },
      "anthropic": {
        "requests": 56,
        "tokens": 15000,
        "cost": 4.50
      }
    },
    "byType": {
      "image": 80,
      "text": 76
    }
  }
}
```


---

## 8. 产品报价

### 8.1 获取产品列表

**端点**: `GET /products`

**查询参数**:
- `categoryId`: 分类ID
- `search`: 搜索关键词
- `isActive`: 是否启用
- `page`: 页码
- `limit`: 每页数量

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "sku": "PROD-001",
        "name": "现代沙发",
        "description": "三人位现代简约沙发",
        "category": {
          "id": "uuid",
          "name": "家具"
        },
        "unit": "件",
        "price": 5999.00,
        "images": ["https://cdn.example.com/sofa.jpg"],
        "stockQuantity": 50,
        "isActive": true
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150
    }
  }
}
```

### 8.2 创建产品

**端点**: `POST /products`

**请求体**:
```json
{
  "categoryId": "uuid",
  "sku": "PROD-001",
  "name": "现代沙发",
  "description": "三人位现代简约沙发",
  "specifications": {
    "尺寸": "220x90x85cm",
    "材质": "布艺",
    "颜色": "米白色"
  },
  "unit": "件",
  "price": 5999.00,
  "cost": 3500.00,
  "images": ["https://cdn.example.com/sofa.jpg"],
  "supplier": "家具供应商A",
  "stockQuantity": 50,
  "tags": ["沙发", "现代", "布艺"]
}
```

**响应**: `201 Created`

### 8.3 获取报价单列表

**端点**: `GET /quotations`

**查询参数**:
- `customerId`: 客户ID
- `status`: 状态筛选
- `startDate`: 开始日期
- `endDate`: 结束日期

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "quotationNumber": "QT-2026020001",
        "customer": {
          "id": "uuid",
          "name": "李四"
        },
        "title": "住宅装修报价",
        "subtotal": 250000.00,
        "taxAmount": 15000.00,
        "discountAmount": 5000.00,
        "totalAmount": 260000.00,
        "status": "sent",
        "validUntil": "2026-03-01",
        "createdAt": "2026-02-04T10:00:00Z"
      }
    ]
  }
}
```

### 8.4 创建报价单

**端点**: `POST /quotations`

**请求体**:
```json
{
  "customerId": "uuid",
  "proposalId": "uuid",
  "title": "住宅装修报价",
  "description": "120平米现代简约风格装修",
  "items": [
    {
      "productId": "uuid",
      "name": "现代沙发",
      "description": "三人位布艺沙发",
      "quantity": 1,
      "unit": "件",
      "unitPrice": 5999.00,
      "discountRate": 0,
      "notes": ""
    }
  ],
  "taxRate": 6.0,
  "discountRate": 2.0,
  "validUntil": "2026-03-01",
  "notes": "备注信息",
  "termsAndConditions": "条款和条件"
}
```

**响应**: `201 Created`

### 8.5 更新报价单状态

**端点**: `PATCH /quotations/{id}/status`

**请求体**:
```json
{
  "status": "accepted"
}
```

**响应**: `200 OK`

### 8.6 导出报价单PDF

**端点**: `GET /quotations/{id}/export/pdf`

**响应**: `200 OK`
- Content-Type: `application/pdf`
- 返回PDF文件流

---

## 9. 客户管理

### 9.1 获取客户列表

**端点**: `GET /customers`

**查询参数**:
- `status`: 状态筛选
- `search`: 搜索关键词
- `assignedTo`: 负责人ID
- `page`: 页码
- `limit`: 每页数量

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "uuid",
        "name": "李四",
        "email": "lisi@example.com",
        "phone": "13900139000",
        "companyName": "某科技公司",
        "status": "customer",
        "assignedTo": {
          "id": "uuid",
          "name": "张三"
        },
        "tags": ["VIP", "住宅"],
        "createdAt": "2026-01-15T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 89
    }
  }
}
```

### 9.2 创建客户

**端点**: `POST /customers`

**请求体**:
```json
{
  "name": "李四",
  "email": "lisi@example.com",
  "phone": "13900139000",
  "companyName": "某科技公司",
  "industry": "科技",
  "source": "网站咨询",
  "address": "北京市朝阳区",
  "city": "北京",
  "province": "北京",
  "notes": "客户备注",
  "tags": ["VIP"],
  "customFields": {
    "预算范围": "20-30万",
    "项目类型": "住宅"
  }
}
```

**响应**: `201 Created`

### 9.3 更新客户信息

**端点**: `PUT /customers/{id}`

**响应**: `200 OK`

### 9.4 获取客户详情

**端点**: `GET /customers/{id}`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "李四",
    "email": "lisi@example.com",
    "phone": "13900139000",
    "companyName": "某科技公司",
    "status": "customer",
    "contacts": [
      {
        "id": "uuid",
        "name": "王五",
        "title": "项目经理",
        "email": "wangwu@example.com",
        "phone": "13800138000",
        "isPrimary": true
      }
    ],
    "proposals": [
      {
        "id": "uuid",
        "title": "设计方案A",
        "status": "published"
      }
    ],
    "quotations": [
      {
        "id": "uuid",
        "quotationNumber": "QT-2026020001",
        "totalAmount": 260000.00,
        "status": "accepted"
      }
    ],
    "appointments": [
      {
        "id": "uuid",
        "title": "初次咨询",
        "startTime": "2026-02-05T14:00:00Z"
      }
    ]
  }
}
```

### 9.5 添加客户联系人

**端点**: `POST /customers/{id}/contacts`

**请求体**:
```json
{
  "name": "王五",
  "title": "项目经理",
  "email": "wangwu@example.com",
  "phone": "13800138000",
  "isPrimary": true,
  "notes": "主要联系人"
}
```

**响应**: `201 Created`

---

## 10. 文件管理

### 10.1 上传文件

**端点**: `POST /files/upload`

**请求头**:
```
Content-Type: multipart/form-data
```

**请求体**:
```
file: [文件二进制数据]
folder: "proposals" (可选)
tags: ["标签1", "标签2"] (可选)
isPublic: false (可选)
```

**响应**: `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "filename": "20260204_image.jpg",
    "originalFilename": "image.jpg",
    "mimeType": "image/jpeg",
    "sizeBytes": 1024000,
    "url": "https://cdn.example.com/files/20260204_image.jpg",
    "thumbnailUrl": "https://cdn.example.com/thumbnails/20260204_image.jpg",
    "width": 1920,
    "height": 1080,
    "createdAt": "2026-02-04T16:00:00Z"
  }
}
```

### 10.2 批量上传文件

**端点**: `POST /files/upload/batch`

**请求头**:
```
Content-Type: multipart/form-data
```

**请求体**:
```
files: [多个文件]
folder: "proposals"
```

**响应**: `201 Created`
```json
{
  "success": true,
  "data": {
    "files": [
      {
        "id": "uuid",
        "url": "https://cdn.example.com/file1.jpg"
      }
    ],
    "failed": []
  }
}
```

### 10.3 获取文件列表

**端点**: `GET /files`

**查询参数**:
- `folder`: 文件夹筛选
- `mimeType`: 文件类型筛选
- `tags`: 标签筛选
- `page`: 页码
- `limit`: 每页数量

**响应**: `200 OK`

### 10.4 删除文件

**端点**: `DELETE /files/{id}`

**响应**: `200 OK`

### 10.5 获取文件签名URL

**端点**: `GET /files/{id}/signed-url`

**查询参数**:
- `expires`: 过期时间（秒，默认3600）

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "url": "https://cdn.example.com/file.jpg?signature=...",
    "expiresAt": "2026-02-04T17:00:00Z"
  }
}
```

---

## 11. 通用规范

### 11.1 请求格式

#### 请求头
```
Content-Type: application/json
Authorization: Bearer {accessToken}
Accept-Language: zh-CN
X-Request-ID: {唯一请求ID}
```

#### 分页参数
所有列表接口支持以下分页参数：
- `page`: 页码（从1开始，默认1）
- `limit`: 每页数量（默认20，最大100）

#### 排序参数
- `sortBy`: 排序字段
- `sortOrder`: 排序方向（`asc` | `desc`）

#### 搜索参数
- `search`: 搜索关键词（支持模糊搜索）

### 11.2 响应格式

#### 成功响应
```json
{
  "success": true,
  "data": {},
  "message": "操作成功"
}
```

#### 错误响应
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": {}
  }
}
```

### 11.3 HTTP状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 请求成功 |
| 201 | 创建成功 |
| 202 | 已接受（异步处理） |
| 204 | 无内容（删除成功） |
| 400 | 请求参数错误 |
| 401 | 未认证 |
| 403 | 无权限 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 422 | 验证失败 |
| 429 | 请求过于频繁 |
| 500 | 服务器错误 |
| 503 | 服务不可用 |

### 11.4 错误码

| 错误码 | 说明 |
|--------|------|
| `AUTH_INVALID_CREDENTIALS` | 用户名或密码错误 |
| `AUTH_TOKEN_EXPIRED` | Token已过期 |
| `AUTH_TOKEN_INVALID` | Token无效 |
| `AUTH_INSUFFICIENT_PERMISSIONS` | 权限不足 |
| `VALIDATION_ERROR` | 验证失败 |
| `RESOURCE_NOT_FOUND` | 资源不存在 |
| `RESOURCE_ALREADY_EXISTS` | 资源已存在 |
| `RATE_LIMIT_EXCEEDED` | 超过速率限制 |
| `QUOTA_EXCEEDED` | 超过配额限制 |
| `FILE_TOO_LARGE` | 文件过大 |
| `UNSUPPORTED_FILE_TYPE` | 不支持的文件类型 |
| `EXTERNAL_SERVICE_ERROR` | 外部服务错误 |
| `DATABASE_ERROR` | 数据库错误 |
| `INTERNAL_SERVER_ERROR` | 内部服务器错误 |

### 11.5 限流规则

| 端点类型 | 限制 |
|---------|------|
| 认证端点 | 10次/分钟/IP |
| 读取端点 | 100次/分钟/用户 |
| 写入端点 | 30次/分钟/用户 |
| 文件上传 | 10次/分钟/用户 |
| AI生成 | 20次/小时/用户 |

### 11.6 数据验证

#### 字符串验证
- `email`: 有效的邮箱格式
- `phone`: 中国手机号格式（11位）
- `url`: 有效的URL格式
- `uuid`: UUID v4格式

#### 数值验证
- `min`: 最小值
- `max`: 最大值
- `positive`: 正数
- `integer`: 整数

#### 日期验证
- `date`: ISO 8601格式
- `dateRange`: 日期范围验证

### 11.7 国际化

#### 支持的语言
- `zh-CN`: 简体中文（默认）
- `en-US`: 英语
- `zh-TW`: 繁体中文

#### 请求头
```
Accept-Language: zh-CN
```

### 11.8 版本控制

API版本通过URL路径指定：
- 当前版本: `/v1`
- 未来版本: `/v2`

版本策略：
- 向后兼容的更改不增加版本号
- 破坏性更改增加主版本号
- 旧版本至少维护12个月

### 11.9 Webhook

#### 配置Webhook

**端点**: `POST /webhooks`

**请求体**:
```json
{
  "url": "https://your-server.com/webhook",
  "events": [
    "proposal.created",
    "proposal.updated",
    "proposal.shared",
    "appointment.created",
    "quotation.accepted"
  ],
  "secret": "webhook-secret-key"
}
```

#### Webhook事件格式

```json
{
  "id": "uuid",
  "event": "proposal.created",
  "timestamp": "2026-02-04T16:00:00Z",
  "data": {
    "proposalId": "uuid",
    "title": "新提案"
  }
}
```

#### Webhook签名验证

请求头包含签名：
```
X-Webhook-Signature: sha256=...
```

验证方法：
```javascript
const crypto = require('crypto')
const signature = crypto
  .createHmac('sha256', webhookSecret)
  .update(JSON.stringify(payload))
  .digest('hex')
```

### 11.10 批量操作

#### 批量删除

**端点**: `POST /batch/delete`

**请求体**:
```json
{
  "resource": "proposals",
  "ids": ["uuid1", "uuid2", "uuid3"]
}
```

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "deleted": 3,
    "failed": 0
  }
}
```

#### 批量更新

**端点**: `POST /batch/update`

**请求体**:
```json
{
  "resource": "proposals",
  "ids": ["uuid1", "uuid2"],
  "updates": {
    "status": "archived"
  }
}
```

**响应**: `200 OK`

### 11.11 导出功能

#### 导出数据

**端点**: `POST /export/{resource}`

**请求体**:
```json
{
  "format": "csv",
  "filters": {},
  "fields": ["id", "title", "status", "createdAt"]
}
```

**响应**: `202 Accepted`
```json
{
  "success": true,
  "data": {
    "exportId": "uuid",
    "status": "processing",
    "estimatedTime": 60
  }
}
```

#### 获取导出结果

**端点**: `GET /export/{exportId}`

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "exportId": "uuid",
    "status": "completed",
    "downloadUrl": "https://cdn.example.com/exports/data.csv",
    "expiresAt": "2026-02-05T16:00:00Z"
  }
}
```

### 11.12 搜索功能

#### 全局搜索

**端点**: `GET /search`

**查询参数**:
- `q`: 搜索关键词（必需）
- `type`: 资源类型筛选（`proposals` | `portfolios` | `customers` | `products`）
- `page`: 页码
- `limit`: 每页数量

**响应**: `200 OK`
```json
{
  "success": true,
  "data": {
    "results": [
      {
        "type": "proposal",
        "id": "uuid",
        "title": "现代简约住宅设计",
        "highlight": "...现代简约...",
        "score": 0.95
      }
    ],
    "aggregations": {
      "byType": {
        "proposals": 12,
        "customers": 5,
        "products": 8
      }
    },
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 25
    }
  }
}
```

### 11.13 实时通知

#### WebSocket连接

**端点**: `wss://api.proposal-system.com/v1/ws`

**连接参数**:
```
?token={accessToken}
```

#### 订阅事件

```json
{
  "action": "subscribe",
  "channels": ["notifications", "proposals"]
}
```

#### 接收消息

```json
{
  "channel": "notifications",
  "event": "new_notification",
  "data": {
    "id": "uuid",
    "type": "proposal_shared",
    "title": "新的提案分享",
    "content": "张三分享了提案给您"
  }
}
```

---

## 12. SDK与代码示例

### 12.1 JavaScript/TypeScript SDK

```typescript
import { ProposalSystemClient } from '@proposal-system/sdk'

const client = new ProposalSystemClient({
  apiKey: 'your-api-key',
  baseURL: 'https://api.proposal-system.com/v1'
})

// 获取提案列表
const proposals = await client.proposals.list({
  status: 'published',
  page: 1,
  limit: 20
})

// 创建提案
const newProposal = await client.proposals.create({
  title: '新提案',
  customerId: 'uuid'
})

// 上传文件
const file = await client.files.upload(fileBlob, {
  folder: 'proposals'
})
```

### 12.2 Python SDK

```python
from proposal_system import ProposalSystemClient

client = ProposalSystemClient(
    api_key='your-api-key',
    base_url='https://api.proposal-system.com/v1'
)

# 获取提案列表
proposals = client.proposals.list(
    status='published',
    page=1,
    limit=20
)

# 创建提案
new_proposal = client.proposals.create(
    title='新提案',
    customer_id='uuid'
)
```

### 12.3 cURL示例

```bash
# 登录
curl -X POST https://api.proposal-system.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password"
  }'

# 获取提案列表
curl -X GET "https://api.proposal-system.com/v1/proposals?page=1&limit=20" \
  -H "Authorization: Bearer {accessToken}"

# 创建提案
curl -X POST https://api.proposal-system.com/v1/proposals \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "新提案",
    "customerId": "uuid"
  }'
```

---

## 附录

### A. 变更日志

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| 1.0 | 2026-02-04 | 初始版本发布 |

### B. 支持与反馈

- **技术文档**: https://docs.proposal-system.com
- **API状态**: https://status.proposal-system.com
- **技术支持**: support@proposal-system.com
- **问题反馈**: https://github.com/proposal-system/issues

### C. 许可与使用条款

API使用需遵守服务条款和隐私政策。详见：
- 服务条款: https://proposal-system.com/terms
- 隐私政策: https://proposal-system.com/privacy

---

**文档版本**: 1.0  
**最后更新**: 2026年2月4日  
**维护团队**: API架构组
