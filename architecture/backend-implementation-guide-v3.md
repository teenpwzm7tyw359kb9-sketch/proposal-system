# 后端实现指南 V3.0

**版本**: 3.0
**更新日期**: 2026-02-04
**适用于**: 提案展示系统 PRD V2.0 + V4编辑器设计

---

## 📋 目录

1. [架构概览](#1-架构概览)
2. [自动保存服务](#2-自动保存服务)
3. [版本控制系统](#3-版本控制系统)
4. [AI服务抽象层](#4-ai服务抽象层)
5. [模块渲染引擎](#5-模块渲染引擎)
6. [ERP适配器架构](#6-erp适配器架构)
7. [实时协作架构](#7-实时协作架构)
8. [性能优化策略](#8-性能优化策略)

---

## 1. 架构概览

### 1.1 技术栈

**后端框架**:
- Node.js 18 LTS
- Express.js 4.x
- TypeScript 5.x

**数据库**:
- PostgreSQL 15+ (主数据库)
- Redis 7+ (缓存 + 会话 + 实时协作)

**消息队列**:
- RabbitMQ 3.x (异步任务处理)

**文件存储**:
- 阿里云OSS (符合中国数据合规)

**搜索引擎**:
- Elasticsearch 8.x (全文搜索)

### 1.2 微服务架构

```
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway (Nginx)                    │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────────┐  ┌────────▼────────┐  ┌────────▼────────┐
│  Auth Service  │  │ Proposal Service│  │   AI Service    │
│                │  │                 │  │                 │
│ - JWT验证      │  │ - 提案CRUD      │  │ - 多供应商集成  │
│ - 权限控制     │  │ - 模块管理      │  │ - 图像生成      │
│ - 用户管理     │  │ - 版本控制      │  │ - 文案生成      │
└────────────────┘  └─────────────────┘  └─────────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
┌───────▼────────┐  ┌────────▼────────┐  ┌────────▼────────┐
│ Asset Service  │  │  ERP Service    │  │ Realtime Service│
│                │  │                 │  │                 │
│ - 素材管理     │  │ - ERP集成       │  │ - WebSocket     │
│ - 文件上传     │  │ - 数据同步      │  │ - 协作编辑      │
│ - CDN分发      │  │ - Webhook处理   │  │ - 在线状态      │
└────────────────┘  └─────────────────┘  └─────────────────┘
```

### 1.3 数据流架构

```
用户请求 → API Gateway → 服务路由 → 业务逻辑 → 数据库
                                    ↓
                              消息队列 → 异步任务
                                    ↓
                              Redis缓存 → 快速响应
```

---

## 2. 自动保存服务

### 2.1 防抖保存机制

**目标**: 3-5秒防抖，减少数据库写入压力

**实现方案**:

```typescript
// autosave.service.ts
import { debounce } from 'lodash';
import Redis from 'ioredis';

class AutosaveService {
  private redis: Redis;
  private debouncedSave: Map<string, Function>;

  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT || '6379'),
    });
    this.debouncedSave = new Map();
  }

  /**
   * 自动保存提案内容（防抖）
   * @param proposalId 提案ID
   * @param userId 用户ID
   * @param sessionId 会话ID
   * @param contentDelta 增量更新内容
   */
  async autosave(
    proposalId: string,
    userId: string,
    sessionId: string,
    contentDelta: any
  ): Promise<void> {
    const key = `autosave:${proposalId}:${sessionId}`;

    // 获取或创建防抖函数
    if (!this.debouncedSave.has(key)) {
      this.debouncedSave.set(
        key,
        debounce(
          async (data: any) => {
            await this.saveToDatabase(proposalId, userId, sessionId, data);
          },
          3000, // 3秒防抖
          { maxWait: 5000 } // 最多等待5秒
        )
      );
    }

    // 合并增量更新到Redis
    await this.mergeContentDelta(key, contentDelta);

    // 触发防抖保存
    const debouncedFn = this.debouncedSave.get(key);
    const currentContent = await this.redis.get(key);
    debouncedFn!(JSON.parse(currentContent || '{}'));
  }

  /**
   * 合并增量更新
   */
  private async mergeContentDelta(key: string, delta: any): Promise<void> {
    const existing = await this.redis.get(key);
    const current = existing ? JSON.parse(existing) : {};

    // 深度合并
    const merged = this.deepMerge(current, delta);

    await this.redis.setex(key, 3600, JSON.stringify(merged)); // 1小时过期
  }

  /**
   * 保存到数据库
   */
  private async saveToDatabase(
    proposalId: string,
    userId: string,
    sessionId: string,
    content: any
  ): Promise<void> {
    await db.query(
      `INSERT INTO proposal_autosave_snapshots
       (proposal_id, user_id, session_id, content, created_at)
       VALUES ($1, $2, $3, $4, NOW())`,
      [proposalId, userId, sessionId, JSON.stringify(content)]
    );

    // 清理旧快照（保留最近24小时）
    await this.cleanupOldSnapshots(proposalId);
  }

  /**
   * 深度合并对象
   */
  private deepMerge(target: any, source: any): any {
    const output = { ...target };

    if (this.isObject(target) && this.isObject(source)) {
      Object.keys(source).forEach(key => {
        if (this.isObject(source[key])) {
          if (!(key in target)) {
            Object.assign(output, { [key]: source[key] });
          } else {
            output[key] = this.deepMerge(target[key], source[key]);
          }
        } else {
          Object.assign(output, { [key]: source[key] });
        }
      });
    }

    return output;
  }

  private isObject(item: any): boolean {
    return item && typeof item === 'object' && !Array.isArray(item);
  }
}

export default new AutosaveService();
```

### 2.2 增量更新策略

**前端发送增量数据**:

```json
{
  "session_id": "session-abc123",
  "content_delta": {
    "modules": {
      "hero": {
        "title_zh": "新标题"
      }
    }
  }
}
```

**后端合并策略**:
1. 从Redis获取当前完整内容
2. 深度合并增量更新
3. 存回Redis
4. 触发防抖保存到PostgreSQL

### 2.3 自动清理机制

**定时任务** (使用node-cron):

```typescript
import cron from 'node-cron';

// 每小时清理一次旧快照
cron.schedule('0 * * * *', async () => {
  await db.query(`
    DELETE FROM proposal_autosave_snapshots
    WHERE created_at < NOW() - INTERVAL '24 hours'
  `);
  console.log('Cleaned up old autosave snapshots');
});
```

---

## 3. 版本控制系统

### 3.1 版本快照创建

**手动保存版本**:

```typescript
// version.service.ts
class VersionService {
  /**
   * 创建版本快照
   */
  async createVersion(
    proposalId: string,
    userId: string,
    description: string,
    tags: string[] = [],
    snapshotType: 'auto' | 'manual' | 'milestone' = 'manual'
  ): Promise<Version> {
    // 1. 获取当前提案完整内容
    const proposal = await this.getProposalWithModules(proposalId);

    // 2. 计算内容哈希（用于去重）
    const contentHash = this.calculateHash(proposal.content);

    // 3. 检查是否与上一版本相同
    const lastVersion = await this.getLastVersion(proposalId);
    if (lastVersion && lastVersion.content_hash === contentHash) {
      throw new Error('内容未变更，无需创建新版本');
    }

    // 4. 获取下一个版本号
    const versionNumber = lastVersion ? lastVersion.version_number + 1 : 1;

    // 5. 创建版本记录
    const version = await db.query(
      `INSERT INTO proposal_versions
       (proposal_id, version_number, title, description, content,
        content_hash, tags, is_snapshot, snapshot_type, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
       RETURNING *`,
      [
        proposalId,
        versionNumber,
        proposal.title,
        description,
        JSON.stringify(proposal.content),
        contentHash,
        tags,
        snapshotType !== 'manual',
        snapshotType,
        userId
      ]
    );

    // 6. 更新提案的当前版本ID
    await db.query(
      `UPDATE proposals SET current_version_id = $1 WHERE id = $2`,
      [version.rows[0].id, proposalId]
    );

    return version.rows[0];
  }

  /**
   * 计算内容哈希
   */
  private calculateHash(content: any): string {
    const crypto = require('crypto');
    const str = JSON.stringify(content);
    return crypto.createHash('sha256').update(str).digest('hex');
  }
}
```

