# API规范文档 V2.0
## 提案展示系统 RESTful API

**版本**: 2.0
**基础URL**: `https://api.proposal-system.com/v1`
**更新日期**: 2026-02-04

---

## 📋 目录

1. [认证授权](#1-认证授权)
2. [提案管理](#2-提案管理)
3. [自动保存与版本管理](#3-自动保存与版本管理)
4. [产品报价管理](#4-产品报价管理)
5. [AI集成](#5-ai集成)
6. [素材库管理](#6-素材库管理)
7. [模板管理](#7-模板管理)
8. [作品集管理](#8-作品集管理)
9. [预约管理](#9-预约管理)
10. [ERP集成](#10-erp集成)
11. [分析统计](#11-分析统计)
12. [错误处理](#12-错误处理)

---

## 1. 认证授权

### 1.1 用户注册
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "张三",
  "company_name": "设计公司"
}

Response 201:
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "张三"
    },
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

### 1.2 用户登录
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}

Response 200:
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "张三",
      "company_id": "uuid",
      "roles": ["editor"]
    },
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

### 1.3 刷新令牌
```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "eyJhbGc..."
}

Response 200:
{
  "success": true,
  "data": {
    "access_token": "eyJhbGc...",
    "expires_in": 3600
  }
}
```

---

## 2. 提案管理

### 2.1 创建提案
```http
POST /proposals
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "春江花园别墅设计方案",
  "description": "现代简约风格别墅设计",
  "client_name": "李先生",
  "client_email": "li@example.com",
  "project_type": "residential",
  "design_style": "modern_minimalist",
  "keywords": ["现代", "简约", "温馨"],
  "template_id": "uuid" // 可选，基于模板创建
}

Response 201:
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "春江花园别墅设计方案",
    "slug": "spring-garden-villa-design",
    "status": "draft",
    "share_token": "abc123xyz",
    "current_version_id": "uuid",
    "created_at": "2026-02-04T10:00:00Z"
  }
}
```

### 2.2 获取提案列表
```http
GET /proposals?page=1&limit=20&status=draft&sort=-created_at
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "proposals": [
      {
        "id": "uuid",
        "title": "春江花园别墅设计方案",
        "cover_image_url": "https://...",
        "status": "draft",
        "client_name": "李先生",
        "view_count": 0,
        "created_at": "2026-02-04T10:00:00Z",
        "updated_at": "2026-02-04T10:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "total_pages": 5
    }
  }
}
```

### 2.3 获取提案详情
```http
GET /proposals/{proposal_id}
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "春江花园别墅设计方案",
    "description": "现代简约风格别墅设计",
    "client_name": "李先生",
    "status": "draft",
    "modules": [
      {
        "id": "uuid",
        "module_type": "hero",
        "module_order": 1,
        "module_data": {
          "title": "春江花园别墅",
          "subtitle": "现代简约 · 温馨雅致",
          "background_image": "https://..."
        }
      }
    ],
    "current_version": {
      "id": "uuid",
      "version_number": 5,
      "created_at": "2026-02-04T15:00:00Z"
    }
  }
}
```

### 2.4 更新提案
```http
PATCH /proposals/{proposal_id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "春江花园别墅设计方案（修订版）",
  "status": "published"
}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "春江花园别墅设计方案（修订版）",
    "status": "published",
    "updated_at": "2026-02-04T16:00:00Z"
  }
}
```

### 2.5 删除提案（软删除）
```http
DELETE /proposals/{proposal_id}
Authorization: Bearer {access_token}

Response 204: No Content
```

### 2.6 发布提案
```http
POST /proposals/{proposal_id}/publish
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "visibility": "password_protected",
  "password": "client123",
  "share_expires_at": "2026-03-04T00:00:00Z"
}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "published",
    "share_url": "https://proposal-system.com/p/abc123xyz",
    "share_token": "abc123xyz",
    "published_at": "2026-02-04T16:00:00Z"
  }
}
```

### 2.7 获取分享提案（公开访问）
```http
GET /public/proposals/{share_token}?password=client123

Response 200:
{
  "success": true,
  "data": {
    "title": "春江花园别墅设计方案",
    "client_name": "李先生",
    "modules": [...],
    "company": {
      "name": "XX设计公司",
      "logo_url": "https://..."
    }
  }
}
```

---

## 3. 自动保存与版本管理

### 3.1 自动保存快照（增量保存）
```http
POST /proposals/{proposal_id}/autosave
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "session_id": "session-abc123",
  "content_delta": {
    "modules": {
      "hero": {
        "title": "春江花园别墅（新标题）"
      }
    }
  },
  "full_content": null // 可选，完整内容
}

Response 200:
{
  "success": true,
  "data": {
    "snapshot_id": "uuid",
    "created_at": "2026-02-04T16:05:30Z",
    "next_autosave_in": 3 // 秒
  }
}
```

### 3.2 获取最新自动保存快照
```http
GET /proposals/{proposal_id}/autosave/latest?session_id=session-abc123
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "snapshot_id": "uuid",
    "content": {...},
    "created_at": "2026-02-04T16:05:30Z"
  }
}
```

### 3.3 创建版本（手动保存）
```http
POST /proposals/{proposal_id}/versions
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "description": "完成初稿，添加了产品报价模块",
  "tags": ["初稿", "待审核"],
  "snapshot_type": "manual"
}

Response 201:
{
  "success": true,
  "data": {
    "id": "uuid",
    "version_number": 6,
    "description": "完成初稿，添加了产品报价模块",
    "created_at": "2026-02-04T16:10:00Z"
  }
}
```

### 3.4 获取版本历史列表
```http
GET /proposals/{proposal_id}/versions?page=1&limit=20
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "versions": [
      {
        "id": "uuid",
        "version_number": 6,
        "description": "完成初稿，添加了产品报价模块",
        "tags": ["初稿", "待审核"],
        "is_snapshot": false,
        "created_by": {
          "id": "uuid",
          "name": "张三"
        },
        "created_at": "2026-02-04T16:10:00Z"
      },
      {
        "id": "uuid",
        "version_number": 5,
        "description": "更新了效果图",
        "created_at": "2026-02-04T15:00:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

### 3.5 获取版本详情
```http
GET /proposals/{proposal_id}/versions/{version_id}
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "version_number": 6,
    "content": {...}, // 完整内容
    "description": "完成初稿",
    "created_at": "2026-02-04T16:10:00Z"
  }
}
```

### 3.6 对比两个版本
```http
GET /proposals/{proposal_id}/versions/compare?from={version_id_1}&to={version_id_2}
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "from_version": {
      "id": "uuid",
      "version_number": 5
    },
    "to_version": {
      "id": "uuid",
      "version_number": 6
    },
    "diff_summary": {
      "modules_added": ["quotation"],
      "modules_removed": [],
      "modules_modified": ["hero", "rendering"],
      "changes_count": 5
    },
    "detailed_diff": {
      "hero": {
        "title": {
          "old": "春江花园别墅",
          "new": "春江花园别墅设计方案"
        }
      },
      "quotation": {
        "status": "added",
        "data": {...}
      }
    }
  }
}
```

### 3.7 恢复到指定版本
```http
POST /proposals/{proposal_id}/versions/{version_id}/restore
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "create_backup": true // 是否创建当前版本的备份
}

Response 200:
{
  "success": true,
  "data": {
    "new_version_id": "uuid",
    "new_version_number": 7,
    "restored_from_version": 5,
    "message": "已恢复到版本 5，并创建了新版本 7"
  }
}
```

---

## 4. 产品报价管理

### 4.1 获取产品列表
```http
GET /products?category_id={uuid}&search=沙发&page=1&limit=20
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "uuid",
        "sku": "SOFA-001",
        "name": "现代沙发",
        "description": "3人位现代简约沙发",
        "category": {
          "id": "uuid",
          "name": "沙发"
        },
        "price": 5999.00,
        "stock_quantity": 50,
        "images": ["https://..."],
        "specifications": {
          "尺寸": "220x90x85cm",
          "材质": "布艺+实木"
        }
      }
    ],
    "pagination": {...}
  }
}
```

### 4.2 创建报价单
```http
POST /proposals/{proposal_id}/quotations
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "春江花园别墅产品报价",
  "description": "客厅和餐厅家具报价",
  "items": [
    {
      "product_id": "uuid",
      "quantity": 1,
      "unit_price": 5999.00,
      "discount_rate": 0
    },
    {
      "product_id": "uuid",
      "quantity": 6,
      "unit_price": 899.00,
      "discount_rate": 10
    }
  ],
  "tax_rate": 6,
  "valid_until": "2026-03-04T00:00:00Z"
}

Response 201:
{
  "success": true,
  "data": {
    "id": "uuid",
    "quotation_number": "QT-20260204-001",
    "subtotal": 10843.00,
    "tax_amount": 650.58,
    "total_amount": 11493.58,
    "items": [...]
  }
}
```

### 4.3 更新报价单
```http
PATCH /quotations/{quotation_id}
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "items": [
    {
      "id": "uuid",
      "quantity": 2 // 修改数量
    }
  ],
  "discount_rate": 5 // 整单折扣
}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "subtotal": 12842.00,
    "discount_amount": 642.10,
    "total_amount": 12199.90
  }
}
```

### 4.4 获取报价单详情
```http
GET /quotations/{quotation_id}
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "quotation_number": "QT-20260204-001",
    "proposal": {
      "id": "uuid",
      "title": "春江花园别墅设计方案"
    },
    "items": [
      {
        "id": "uuid",
        "product": {
          "id": "uuid",
          "name": "现代沙发",
          "sku": "SOFA-001",
          "images": ["https://..."]
        },
        "quantity": 1,
        "unit_price": 5999.00,
        "subtotal": 5999.00
      }
    ],
    "subtotal": 10843.00,
    "tax_amount": 650.58,
    "total_amount": 11493.58,
    "status": "draft"
  }
}
```

---

## 5. AI集成

### 5.1 配置AI提供商
```http
POST /ai/providers/config
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "provider_name": "openai",
  "api_key": "sk-...",
  "preferred_text_model": "gpt-4-turbo",
  "preferred_image_model": "dall-e-3"
}

Response 200:
{
  "success": true,
  "data": {
    "provider_name": "openai",
    "is_active": true,
    "available_models": [
      {
        "model_name": "gpt-4-turbo",
        "model_type": "text",
        "display_name": "GPT-4 Turbo"
      },
      {
        "model_name": "dall-e-3",
        "model_type": "image",
        "display_name": "DALL-E 3"
      }
    ]
  }
}
```

### 5.2 上下文感知AI生成（模块内）
```http
POST /ai/generate/context
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "proposal_id": "uuid",
  "module_type": "hero",
  "generation_type": "image",
  "prompt": "现代别墅外观，黄昏时分，暖色灯光",
  "context": {
    "project_name": "春江花园别墅",
    "design_style": "modern_minimalist",
    "keywords": ["现代", "简约", "温馨"]
  },
  "parameters": {
    "style": "modern_minimalist",
    "size": "1920x1080",
    "count": 4
  },
  "provider": "openai", // 可选，默认使用用户配置的首选提供商
  "model": "dall-e-3" // 可选
}

Response 202: Accepted
{
  "success": true,
  "data": {
    "generation_id": "uuid",
    "status": "processing",
    "estimated_duration": 30 // 秒
  }
}
```

### 5.3 全局AI工具生成
```http
POST /ai/generate/global
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "generation_type": "text",
  "prompt": "为现代简约风格的别墅设计撰写设计理念",
  "parameters": {
    "tone": "professional",
    "length": "200-300",
    "language": "zh-CN"
  },
  "provider": "claude",
  "model": "claude-3-opus"
}

Response 202: Accepted
{
  "success": true,
  "data": {
    "generation_id": "uuid",
    "status": "processing"
  }
}
```

### 5.4 获取AI生成结果
```http
GET /ai/generations/{generation_id}
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "completed",
    "generation_type": "image",
    "trigger_source": "module_context",
    "module_type": "hero",
    "result_urls": [
      "https://cdn.../image1.jpg",
      "https://cdn.../image2.jpg",
      "https://cdn.../image3.jpg",
      "https://cdn.../image4.jpg"
    ],
    "result_data": {
      "images": [
        {
          "url": "https://cdn.../image1.jpg",
          "width": 1920,
          "height": 1080
        }
      ]
    },
    "tokens_used": 1000,
    "cost": 0.04,
    "duration_ms": 28500,
    "created_at": "2026-02-04T16:20:00Z"
  }
}
```

### 5.5 应用AI生成结果到提案
```http
POST /ai/generations/{generation_id}/apply
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "proposal_id": "uuid",
  "module_type": "hero",
  "selected_result_index": 0 // 选择第几个结果
}

Response 200:
{
  "success": true,
  "data": {
    "message": "AI生成结果已应用到提案",
    "proposal_id": "uuid",
    "module_type": "hero"
  }
}
```

### 5.6 保存AI生成结果到素材库
```http
POST /ai/generations/{generation_id}/save-to-assets
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "selected_indices": [0, 2], // 选择保存哪些结果
  "category_id": "uuid",
  "tags": ["AI生成", "别墅外观"]
}

Response 200:
{
  "success": true,
  "data": {
    "assets": [
      {
        "id": "uuid",
        "name": "AI生成-别墅外观-1",
        "file_url": "https://...",
        "source": "ai_generated"
      }
    ]
  }
}
```

### 5.7 获取AI生成历史
```http
GET /ai/generations?page=1&limit=20&type=image&favorite=true
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "generations": [
      {
        "id": "uuid",
        "generation_type": "image",
        "trigger_source": "module_context",
        "result_urls": ["https://..."],
        "is_favorite": true,
        "created_at": "2026-02-04T16:20:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

### 5.8 获取AI使用配额
```http
GET /ai/quota
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "period_start": "2026-02-01",
    "period_end": "2026-02-28",
    "quota_limit": 1000,
    "quota_used": 245,
    "quota_remaining": 755,
    "image_generations": 50,
    "text_generations": 195,
    "total_cost": 12.50
  }
}
```

---

## 6. 素材库管理

### 6.1 上传素材
```http
POST /assets/upload
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

file: [binary]
name: "别墅外观图"
description: "春江花园别墅外观效果图"
category_id: "uuid"
tags: ["别墅", "外观", "现代"]

Response 201:
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "别墅外观图",
    "file_url": "https://cdn.../image.jpg",
    "thumbnail_url": "https://cdn.../thumb.jpg",
    "file_type": "image",
    "file_size": 2048576,
    "width": 1920,
    "height": 1080,
    "source": "upload"
  }
}
```

### 6.2 获取素材列表
```http
GET /assets?category_id={uuid}&tags=别墅,外观&source=ai_generated&page=1&limit=20
Authorization: Bearer {access_token}

Response 200:
{
  "success": true,
  "data": {
    "assets": [
      {
        "id": "uuid",
        "name": "别墅外观图",
        "file_url": "https://...",
        "thumbnail_url": "https://...",
        "file_type": "image",
        "tags": ["别墅", "外观"],
        "source": "ai_generated",
        "usage_count": 3,
        "created_at": "2026-02-04T16:30:00Z"
      }
    ],
    "pagination": {...}
  }
}
```

### 6.3 删除素材
```http
DELETE /assets/{asset_id}
Authorization: Bearer {access_token}

Response 204: No Content
```

---

## 7-11. 其他模块API

（模板管理、作品集管理、预约管理、ERP集成、分析统计的API端点省略，结构类似）

---

## 12. 错误处理

### 标准错误响应格式
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "请求参数验证失败",
    "details": [
      {
        "field": "email",
        "message": "邮箱格式不正确"
      }
    ]
  }
}
```

### 错误代码列表
| 错误代码 | HTTP状态码 | 说明 |
|---------|-----------|------|
| VALIDATION_ERROR | 400 | 请求参数验证失败 |
| UNAUTHORIZED | 401 | 未授权，需要登录 |
| FORBIDDEN | 403 | 无权限访问 |
| NOT_FOUND | 404 | 资源不存在 |
| CONFLICT | 409 | 资源冲突 |
| QUOTA_EXCEEDED | 429 | 配额超限 |
| INTERNAL_ERROR | 500 | 服务器内部错误 |
| AI_GENERATION_FAILED | 500 | AI生成失败 |
| ERP_SYNC_FAILED | 500 | ERP同步失败 |

---

## 附录：请求头规范

所有需要认证的请求必须包含：
```
Authorization: Bearer {access_token}
Content-Type: application/json
X-Request-ID: {unique_request_id} // 可选，用于追踪
```

## 附录：分页参数
```
?page=1          // 页码，从1开始
&limit=20        // 每页数量，默认20，最大100
&sort=-created_at // 排序，-表示降序
```

## 附录：速率限制
- 认证端点：10次/分钟
- 一般API：100次/分钟
- AI生成：20次/小时
- 文件上传：50次/小时
