-- =====================================================
-- 提案展示系统数据库架构 V3.0
-- 基于PRD V2.0和V4编辑器设计
-- 数据库: PostgreSQL 15+
-- 版本: 3.0
-- 最后更新: 2026-02-04
-- 更新内容（V3.0）：
--   - 支持所有12个模块类型（Hero, Insight, Manifesto, Floorplan, Storage, Rendering, Gallery, Moodboard, Technical, Delivery, Quotation, Ending）
--   - 完整版本控制系统（版本快照、差异对比、回滚）
--   - 自动保存快照表（3-5秒防抖保存）
--   - 作品集导入跟踪（用户自主选择章节）
--   - AI使用历史表（支持所有12个模块的AI功能）
--   - 产品报价管理表
--   - 素材库管理表
--   - ERP集成表
-- =====================================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. 用户与权限管理（保持原有设计）
-- =====================================================

-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    avatar_url TEXT,
    phone VARCHAR(20),
    company_id UUID,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP WITH TIME ZONE,
    last_login_ip INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_status ON users(status);

-- 角色表
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 权限表
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    resource VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 用户角色关联表
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, role_id)
);

-- 角色权限关联表
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(role_id, permission_id)
);

-- =====================================================
-- 2. 公司管理
-- =====================================================

CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    logo_url TEXT,
    website VARCHAR(255),
    industry VARCHAR(50),
    size VARCHAR(20) CHECK (size IN ('1-10', '11-50', '51-200', '201-500', '500+')),
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    country VARCHAR(100) DEFAULT '中国',
    subscription_plan VARCHAR(50) DEFAULT 'basic' CHECK (subscription_plan IN ('basic', 'professional', 'enterprise')),
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    ai_quota_monthly INTEGER DEFAULT 100,
    ai_quota_used INTEGER DEFAULT 0,
    storage_quota_gb INTEGER DEFAULT 10,
    storage_used_gb DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_companies_subscription_plan ON companies(subscription_plan);

-- =====================================================
-- 3. 提案管理（核心表）
-- =====================================================

-- 提案表
CREATE TABLE proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,
    client_name VARCHAR(200),
    client_email VARCHAR(255),
    client_phone VARCHAR(20),
    project_type VARCHAR(50),
    design_style VARCHAR(50),
    keywords TEXT[], -- 关键词数组
    cover_image_url TEXT,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    visibility VARCHAR(20) DEFAULT 'private' CHECK (visibility IN ('private', 'public', 'password_protected')),
    password_hash VARCHAR(255), -- 密码保护
    share_token VARCHAR(100) UNIQUE, -- 分享令牌
    share_expires_at TIMESTAMP WITH TIME ZONE, -- 分享过期时间
    view_count INTEGER DEFAULT 0,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    template_id UUID, -- 基于的模板
    current_version_id UUID, -- 当前版本
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_proposals_owner_id ON proposals(owner_id);
CREATE INDEX idx_proposals_company_id ON proposals(company_id);
CREATE INDEX idx_proposals_status ON proposals(status);
CREATE INDEX idx_proposals_share_token ON proposals(share_token);
CREATE INDEX idx_proposals_slug ON proposals(slug);

-- =====================================================
-- 4. 提案版本管理（新增/更新）
-- =====================================================

-- 提案版本表
CREATE TABLE proposal_versions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    version_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT, -- 版本说明
    content JSONB NOT NULL, -- 完整的提案内容（所有模块）
    content_hash VARCHAR(64), -- 内容哈希，用于去重
    tags TEXT[], -- 版本标签
    is_snapshot BOOLEAN DEFAULT FALSE, -- 是否为自动快照
    snapshot_type VARCHAR(20) CHECK (snapshot_type IN ('auto', 'manual', 'milestone')),
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(proposal_id, version_number)
);

CREATE INDEX idx_proposal_versions_proposal_id ON proposal_versions(proposal_id);
CREATE INDEX idx_proposal_versions_created_at ON proposal_versions(created_at);
CREATE INDEX idx_proposal_versions_is_snapshot ON proposal_versions(is_snapshot);

-- 版本差异表（用于快速对比）
CREATE TABLE proposal_version_diffs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    from_version_id UUID NOT NULL REFERENCES proposal_versions(id) ON DELETE CASCADE,
    to_version_id UUID NOT NULL REFERENCES proposal_versions(id) ON DELETE CASCADE,
    diff_summary JSONB, -- 差异摘要
    changes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(from_version_id, to_version_id)
);

CREATE INDEX idx_version_diffs_proposal_id ON proposal_version_diffs(proposal_id);

-- =====================================================
-- 5. 自动保存快照表（新增）
-- =====================================================

-- 自动保存快照表
CREATE TABLE proposal_autosave_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content JSONB NOT NULL, -- 快照内容
    content_delta JSONB, -- 增量更新（可选）
    session_id VARCHAR(100), -- 编辑会话ID
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_autosave_proposal_id ON proposal_autosave_snapshots(proposal_id);
CREATE INDEX idx_autosave_user_id ON proposal_autosave_snapshots(user_id);
CREATE INDEX idx_autosave_created_at ON proposal_autosave_snapshots(created_at);
CREATE INDEX idx_autosave_session_id ON proposal_autosave_snapshots(session_id);

-- 自动清理旧快照（保留最近24小时）
CREATE OR REPLACE FUNCTION cleanup_old_autosave_snapshots()
RETURNS void AS $$
BEGIN
    DELETE FROM proposal_autosave_snapshots
    WHERE created_at < NOW() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. 提案模块配置表（新增）
-- =====================================================

-- 模块配置表（支持所有12个模块类型）
CREATE TABLE proposal_modules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    module_type VARCHAR(50) NOT NULL CHECK (module_type IN (
        'hero', 'insight', 'manifesto', 'floorplan', 'storage',
        'rendering', 'gallery', 'moodboard', 'technical', 'delivery',
        'quotation', 'ending'
    )),
    module_order INTEGER NOT NULL,
    module_data JSONB NOT NULL, -- 模块具体数据
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_modules_proposal_id ON proposal_modules(proposal_id);
CREATE INDEX idx_modules_type ON proposal_modules(module_type);
CREATE INDEX idx_modules_order ON proposal_modules(proposal_id, module_order);

-- =====================================================
-- 7. 产品报价管理（新增）
-- =====================================================

-- 产品分类表
CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES product_categories(id) ON DELETE CASCADE,
    description TEXT,
    icon VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_categories_parent_id ON product_categories(parent_id);

-- 产品表
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES product_categories(id),
    brand VARCHAR(100),
    model VARCHAR(100),
    specifications JSONB, -- 规格参数
    images TEXT[], -- 产品图片数组
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2), -- 成本价
    currency VARCHAR(10) DEFAULT 'CNY',
    stock_quantity INTEGER DEFAULT 0,
    unit VARCHAR(20) DEFAULT '件',
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'discontinued')),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    erp_product_id VARCHAR(100), -- ERP系统产品ID
    erp_sync_at TIMESTAMP WITH TIME ZONE, -- ERP同步时间
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_company_id ON products(company_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_erp_id ON products(erp_product_id);

-- 报价单表
CREATE TABLE quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    quotation_number VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(255),
    description TEXT,
    subtotal DECIMAL(10,2) DEFAULT 0,
    tax_rate DECIMAL(5,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_rate DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) DEFAULT 0,
    currency VARCHAR(10) DEFAULT 'CNY',
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'accepted', 'rejected')),
    valid_until TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quotations_proposal_id ON quotations(proposal_id);
CREATE INDEX idx_quotations_number ON quotations(quotation_number);
CREATE INDEX idx_quotations_status ON quotations(status);

-- 报价单明细表
CREATE TABLE quotation_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quotation_id UUID NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100),
    description TEXT,
    specifications JSONB,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) DEFAULT '件',
    unit_price DECIMAL(10,2) NOT NULL,
    discount_rate DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    subtotal DECIMAL(10,2) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_quotation_items_quotation_id ON quotation_items(quotation_id);
CREATE INDEX idx_quotation_items_product_id ON quotation_items(product_id);

-- =====================================================
-- 8. AI集成管理（新增）
-- =====================================================

-- AI提供商配置表
CREATE TABLE ai_providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL CHECK (name IN ('openai', 'claude', 'gemini')),
    display_name VARCHAR(100) NOT NULL,
    api_endpoint TEXT,
    is_enabled BOOLEAN DEFAULT TRUE,
    default_model VARCHAR(100),
    supported_features TEXT[], -- ['image_generation', 'text_generation', 'chat']
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- AI模型配置表
CREATE TABLE ai_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID NOT NULL REFERENCES ai_providers(id) ON DELETE CASCADE,
    model_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    model_type VARCHAR(50) NOT NULL CHECK (model_type IN ('text', 'image', 'chat', 'embedding')),
    capabilities JSONB, -- 模型能力描述
    max_tokens INTEGER,
    cost_per_1k_tokens DECIMAL(10,4),
    is_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(provider_id, model_name)
);

CREATE INDEX idx_ai_models_provider_id ON ai_models(provider_id);
CREATE INDEX idx_ai_models_type ON ai_models(model_type);

-- 用户AI配置表
CREATE TABLE user_ai_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    provider_name VARCHAR(50) NOT NULL,
    api_key_encrypted TEXT, -- 加密的API Key
    oauth_token_encrypted TEXT, -- 加密的OAuth Token
    oauth_refresh_token_encrypted TEXT,
    oauth_expires_at TIMESTAMP WITH TIME ZONE,
    preferred_text_model VARCHAR(100),
    preferred_image_model VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, provider_name)
);

CREATE INDEX idx_user_ai_configs_user_id ON user_ai_configs(user_id);
CREATE INDEX idx_user_ai_configs_company_id ON user_ai_configs(company_id);

-- AI生成历史表（核心表 - 支持所有12个模块）
CREATE TABLE ai_generation_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    proposal_id UUID REFERENCES proposals(id) ON DELETE SET NULL,
    module_type VARCHAR(50) CHECK (module_type IN (
        'hero', 'insight', 'manifesto', 'floorplan', 'storage',
        'rendering', 'gallery', 'moodboard', 'technical', 'delivery',
        'quotation', 'ending'
    )), -- 关联的模块类型（如果是上下文感知AI）
    generation_type VARCHAR(50) NOT NULL CHECK (generation_type IN ('image', 'text', 'suggestion', 'layout', 'color_scheme')),
    trigger_source VARCHAR(50) NOT NULL CHECK (trigger_source IN ('module_context', 'global_tool')),
    provider_name VARCHAR(50) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    prompt TEXT NOT NULL,
    prompt_context JSONB, -- 上下文信息（项目信息、模块信息等）
    parameters JSONB, -- 生成参数（风格、尺寸等）
    result_data JSONB, -- 生成结果
    result_urls TEXT[], -- 生成的图片/文件URL
    tokens_used INTEGER,
    cost DECIMAL(10,4),
    duration_ms INTEGER, -- 生成耗时（毫秒）
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    error_message TEXT,
    is_applied BOOLEAN DEFAULT FALSE, -- 是否已应用到提案
    applied_at TIMESTAMP WITH TIME ZONE,
    is_favorite BOOLEAN DEFAULT FALSE, -- 是否收藏
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_ai_history_user_id ON ai_generation_history(user_id);
CREATE INDEX idx_ai_history_company_id ON ai_generation_history(company_id);
CREATE INDEX idx_ai_history_proposal_id ON ai_generation_history(proposal_id);
CREATE INDEX idx_ai_history_type ON ai_generation_history(generation_type);
CREATE INDEX idx_ai_history_source ON ai_generation_history(trigger_source);
CREATE INDEX idx_ai_history_created_at ON ai_generation_history(created_at);
CREATE INDEX idx_ai_history_favorite ON ai_generation_history(is_favorite);

-- AI使用配额记录表
CREATE TABLE ai_usage_quotas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    quota_limit INTEGER NOT NULL,
    quota_used INTEGER DEFAULT 0,
    image_generations INTEGER DEFAULT 0,
    text_generations INTEGER DEFAULT 0,
    total_tokens_used BIGINT DEFAULT 0,
    total_cost DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, period_start)
);

CREATE INDEX idx_ai_quotas_company_id ON ai_usage_quotas(company_id);
CREATE INDEX idx_ai_quotas_period ON ai_usage_quotas(period_start, period_end);

-- =====================================================
-- 9. 素材库管理（新增）
-- =====================================================

-- 素材库分类表
CREATE TABLE asset_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES asset_categories(id) ON DELETE CASCADE,
    category_type VARCHAR(50) CHECK (category_type IN ('image', 'video', 'document', 'other')),
    icon VARCHAR(50),
    sort_order INTEGER DEFAULT 0,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_asset_categories_parent_id ON asset_categories(parent_id);
CREATE INDEX idx_asset_categories_company_id ON asset_categories(company_id);

-- 素材库表
CREATE TABLE assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    file_type VARCHAR(50) NOT NULL, -- image, video, document, etc.
    mime_type VARCHAR(100),
    file_url TEXT NOT NULL,
    thumbnail_url TEXT,
    file_size BIGINT, -- 文件大小（字节）
    width INTEGER, -- 图片/视频宽度
    height INTEGER, -- 图片/视频高度
    duration INTEGER, -- 视频时长（秒）
    category_id UUID REFERENCES asset_categories(id),
    tags TEXT[], -- 标签数组
    source VARCHAR(50) CHECK (source IN ('upload', 'ai_generated', 'imported')),
    ai_generation_id UUID REFERENCES ai_generation_history(id), -- 如果是AI生成
    uploaded_by UUID NOT NULL REFERENCES users(id),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    usage_count INTEGER DEFAULT 0, -- 使用次数
    last_used_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_assets_category_id ON assets(category_id);
CREATE INDEX idx_assets_company_id ON assets(company_id);
CREATE INDEX idx_assets_uploaded_by ON assets(uploaded_by);
CREATE INDEX idx_assets_file_type ON assets(file_type);
CREATE INDEX idx_assets_source ON assets(source);
CREATE INDEX idx_assets_tags ON assets USING GIN(tags);

-- 素材使用记录表
CREATE TABLE asset_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    proposal_id UUID REFERENCES proposals(id) ON DELETE CASCADE,
    module_type VARCHAR(50),
    used_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_asset_usage_asset_id ON asset_usage(asset_id);
CREATE INDEX idx_asset_usage_proposal_id ON asset_usage(proposal_id);

-- =====================================================
-- 10. 模板管理
-- =====================================================

CREATE TABLE templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    category VARCHAR(50),
    industry VARCHAR(50),
    design_style VARCHAR(50),
    template_data JSONB NOT NULL, -- 模板内容
    is_public BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    usage_count INTEGER DEFAULT 0,
    rating DECIMAL(3,2) DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(id),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_templates_category ON templates(category);
CREATE INDEX idx_templates_company_id ON templates(company_id);
CREATE INDEX idx_templates_is_public ON templates(is_public);

-- =====================================================
-- 11. 作品集管理
-- =====================================================

CREATE TABLE portfolios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    description TEXT,
    cover_image_url TEXT,
    custom_domain VARCHAR(255),
    seo_title VARCHAR(255),
    seo_description TEXT,
    seo_keywords TEXT[],
    is_public BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_portfolios_owner_id ON portfolios(owner_id);
CREATE INDEX idx_portfolios_slug ON portfolios(slug);
CREATE INDEX idx_portfolios_is_public ON portfolios(is_public);
CREATE INDEX idx_portfolios_is_featured ON portfolios(is_featured);

-- 作品集提案关联表（支持章节选择导入）
CREATE TABLE portfolio_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    portfolio_id UUID NOT NULL REFERENCES portfolios(id) ON DELETE CASCADE,
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    selected_modules TEXT[], -- 用户选择保留的模块类型数组
    sort_order INTEGER DEFAULT 0,
    project_type VARCHAR(50),
    completion_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(portfolio_id, proposal_id)
);

CREATE INDEX idx_portfolio_proposals_portfolio_id ON portfolio_proposals(portfolio_id);
CREATE INDEX idx_portfolio_proposals_proposal_id ON portfolio_proposals(proposal_id);

-- 作品集导入历史表
CREATE TABLE portfolio_import_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    portfolio_id UUID NOT NULL REFERENCES portfolios(id) ON DELETE CASCADE,
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    original_modules TEXT[], -- 原始提案的所有模块
    selected_modules TEXT[], -- 用户选择保留的模块
    removed_modules TEXT[], -- 被移除的模块
    import_config JSONB, -- 导入配置（推荐配置、快速选择等）
    imported_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_portfolio_import_history_portfolio_id ON portfolio_import_history(portfolio_id);
CREATE INDEX idx_portfolio_import_history_proposal_id ON portfolio_import_history(proposal_id);

-- =====================================================
-- 12. 预约管理
-- =====================================================

CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    appointment_type VARCHAR(50) CHECK (appointment_type IN ('consultation', 'presentation', 'site_visit', 'other')),
    client_name VARCHAR(200) NOT NULL,
    client_email VARCHAR(255),
    client_phone VARCHAR(20),
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER,
    location TEXT,
    meeting_url TEXT, -- 线上会议链接
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    reminder_sent BOOLEAN DEFAULT FALSE,
    notes TEXT,
    assigned_to UUID REFERENCES users(id),
    proposal_id UUID REFERENCES proposals(id),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_appointments_assigned_to ON appointments(assigned_to);
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_company_id ON appointments(company_id);

-- =====================================================
-- 13. ERP集成管理
-- =====================================================

-- ERP系统配置表
CREATE TABLE erp_integrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    erp_system VARCHAR(50) NOT NULL CHECK (erp_system IN ('yonyou', 'kingdee', 'sap', 'custom')),
    erp_name VARCHAR(100),
    api_endpoint TEXT NOT NULL,
    api_key_encrypted TEXT,
    auth_type VARCHAR(50) CHECK (auth_type IN ('api_key', 'oauth2', 'basic_auth')),
    oauth_config JSONB,
    sync_enabled BOOLEAN DEFAULT TRUE,
    sync_frequency VARCHAR(50) DEFAULT 'manual' CHECK (sync_frequency IN ('realtime', 'hourly', 'daily', 'manual')),
    last_sync_at TIMESTAMP WITH TIME ZONE,
    sync_status VARCHAR(20) CHECK (sync_status IN ('success', 'failed', 'in_progress')),
    sync_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, erp_system)
);

CREATE INDEX idx_erp_integrations_company_id ON erp_integrations(company_id);

-- ERP同步日志表
CREATE TABLE erp_sync_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    integration_id UUID NOT NULL REFERENCES erp_integrations(id) ON DELETE CASCADE,
    sync_type VARCHAR(50) NOT NULL CHECK (sync_type IN ('customer', 'product', 'proposal', 'appointment')),
    sync_direction VARCHAR(20) CHECK (sync_direction IN ('import', 'export', 'bidirectional')),
    records_total INTEGER DEFAULT 0,
    records_success INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    duration_ms INTEGER,
    status VARCHAR(20) CHECK (status IN ('success', 'partial', 'failed')),
    error_details JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_erp_sync_logs_integration_id ON erp_sync_logs(integration_id);
CREATE INDEX idx_erp_sync_logs_created_at ON erp_sync_logs(created_at);

-- ERP客户数据映射表
CREATE TABLE erp_customer_mappings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    integration_id UUID NOT NULL REFERENCES erp_integrations(id) ON DELETE CASCADE,
    local_customer_id UUID, -- 本地客户ID（如果有）
    erp_customer_id VARCHAR(100) NOT NULL,
    customer_data JSONB NOT NULL, -- ERP客户数据
    last_synced_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(integration_id, erp_customer_id)
);

CREATE INDEX idx_erp_customer_mappings_integration_id ON erp_customer_mappings(integration_id);

-- =====================================================
-- 14. 分析统计
-- =====================================================

-- 提案访问记录表
CREATE TABLE proposal_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    visitor_ip INET,
    visitor_country VARCHAR(100),
    visitor_city VARCHAR(100),
    user_agent TEXT,
    referrer TEXT,
    session_id VARCHAR(100),
    view_duration INTEGER, -- 浏览时长（秒）
    pages_viewed INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_proposal_views_proposal_id ON proposal_views(proposal_id);
CREATE INDEX idx_proposal_views_created_at ON proposal_views(created_at);
CREATE INDEX idx_proposal_views_session_id ON proposal_views(session_id);

-- 提案交互记录表
CREATE TABLE proposal_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(id) ON DELETE CASCADE,
    session_id VARCHAR(100),
    interaction_type VARCHAR(50) CHECK (interaction_type IN ('click', 'scroll', 'zoom', 'download')),
    element_type VARCHAR(50),
    element_id VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_proposal_interactions_proposal_id ON proposal_interactions(proposal_id);
CREATE INDEX idx_proposal_interactions_session_id ON proposal_interactions(session_id);

-- =====================================================
-- 15. 系统配置
-- =====================================================

CREATE TABLE system_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 16. 触发器和函数
-- =====================================================

-- 更新 updated_at 时间戳的函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为所有需要的表添加触发器
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_proposals_updated_at BEFORE UPDATE ON proposals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quotations_updated_at BEFORE UPDATE ON quotations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON assets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 自动更新提案浏览次数
CREATE OR REPLACE FUNCTION increment_proposal_view_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE proposals SET view_count = view_count + 1 WHERE id = NEW.proposal_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_proposal_views AFTER INSERT ON proposal_views
    FOR EACH ROW EXECUTE FUNCTION increment_proposal_view_count();

-- 自动更新素材使用次数
CREATE OR REPLACE FUNCTION increment_asset_usage_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE assets 
    SET usage_count = usage_count + 1, last_used_at = CURRENT_TIMESTAMP 
    WHERE id = NEW.asset_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_asset_usage AFTER INSERT ON asset_usage
    FOR EACH ROW EXECUTE FUNCTION increment_asset_usage_count();

-- =====================================================
-- 17. 初始化数据
-- =====================================================

-- 插入默认角色
INSERT INTO roles (name, display_name, description, is_system) VALUES
('admin', '管理员', '系统管理员，拥有所有权限', TRUE),
('editor', '编辑者', '可以创建和编辑提案', TRUE),
('viewer', '查看者', '只能查看提案', TRUE);

-- 插入AI提供商
INSERT INTO ai_providers (name, display_name, api_endpoint, supported_features, default_model) VALUES
('openai', 'OpenAI', 'https://api.openai.com/v1', ARRAY['image_generation', 'text_generation', 'chat'], 'gpt-4'),
('claude', 'Anthropic Claude', 'https://api.anthropic.com/v1', ARRAY['text_generation', 'chat'], 'claude-3-opus'),
('gemini', 'Google Gemini', 'https://generativelanguage.googleapis.com/v1', ARRAY['text_generation', 'image_generation', 'chat'], 'gemini-pro');

-- 插入AI模型
INSERT INTO ai_models (provider_id, model_name, display_name, model_type, max_tokens, cost_per_1k_tokens) VALUES
((SELECT id FROM ai_providers WHERE name = 'openai'), 'gpt-4', 'GPT-4', 'text', 8192, 0.03),
((SELECT id FROM ai_providers WHERE name = 'openai'), 'gpt-4-turbo', 'GPT-4 Turbo', 'text', 128000, 0.01),
((SELECT id FROM ai_providers WHERE name = 'openai'), 'dall-e-3', 'DALL-E 3', 'image', NULL, 0.04),
((SELECT id FROM ai_providers WHERE name = 'claude'), 'claude-3-opus', 'Claude 3 Opus', 'text', 200000, 0.015),
((SELECT id FROM ai_providers WHERE name = 'claude'), 'claude-3-sonnet', 'Claude 3 Sonnet', 'text', 200000, 0.003),
((SELECT id FROM ai_providers WHERE name = 'gemini'), 'gemini-pro', 'Gemini Pro', 'text', 32768, 0.0005),
((SELECT id FROM ai_providers WHERE name = 'gemini'), 'gemini-pro-vision', 'Gemini Pro Vision', 'image', 16384, 0.0025);

-- =====================================================
-- 完成
-- =====================================================

COMMENT ON DATABASE postgres IS '提案展示系统数据库 V2.0';
