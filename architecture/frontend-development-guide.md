# 前端开发规范文档
## 提案展示系统前端开发指南

**版本**: 1.0
**技术栈**: Next.js 14+ | React 18+ | TypeScript | Tailwind CSS
**更新日期**: 2026-02-04

---

## 📋 目录

1. [项目结构](#1-项目结构)
2. [技术栈详解](#2-技术栈详解)
3. [组件规范](#3-组件规范)
4. [状态管理](#4-状态管理)
5. [样式规范](#5-样式规范)
6. [AI集成规范](#6-ai集成规范)
7. [性能优化](#7-性能优化)
8. [测试规范](#8-测试规范)

---

## 1. 项目结构

```
proposal-system-frontend/
├── src/
│   ├── app/                          # Next.js 14 App Router
│   │   ├── (auth)/                   # 认证路由组
│   │   │   ├── login/
│   │   │   └── register/
│   │   ├── (dashboard)/              # 仪表板路由组
│   │   │   ├── proposals/
│   │   │   ├── templates/
│   │   │   ├── portfolio/
│   │   │   └── settings/
│   │   ├── editor/                   # 提案编辑器
│   │   │   └── [proposalId]/
│   │   ├── public/                   # 公开访问路由
│   │   │   └── p/[shareToken]/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   │
│   ├── components/                   # 组件目录
│   │   ├── editor/                   # 编辑器组件
│   │   │   ├── Canvas.tsx
│   │   │   ├── Toolbar.tsx
│   │   │   ├── PageNav.tsx
│   │   │   ├── EditPanel.tsx
│   │   │   └── ProgressBar.tsx
│   │   ├── modules/                  # 提案模块组件
│   │   │   ├── HeroModule.tsx
│   │   │   ├── InsightModule.tsx
│   │   │   ├── RenderingModule.tsx
│   │   │   ├── QuotationModule.tsx
│   │   │   └── index.ts
│   │   ├── ai/                       # AI组件
│   │   │   ├── AIPanel.tsx
│   │   │   ├── ContextAIButton.tsx
│   │   │   ├── ImageGenerator.tsx
│   │   │   └── TextGenerator.tsx
│   │   ├── version/                  # 版本管理组件
│   │   │   ├── VersionPanel.tsx
│   │   │   ├── VersionTimeline.tsx
│   │   │   └── VersionCompare.tsx
│   │   ├── quotation/                # 报价组件
│   │   │   ├── QuotationEditor.tsx
│   │   │   ├── ProductSelector.tsx
│   │   │   └── PriceCalculator.tsx
│   │   ├── ui/                       # 通用UI组件
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Modal.tsx
│   │   │   ├── Toast.tsx
│   │   │   └── ...
│   │   └── layout/                   # 布局组件
│   │       ├── Header.tsx
│   │       ├── Sidebar.tsx
│   │       └── Footer.tsx
│   │
│   ├── hooks/                        # 自定义Hooks
│   │   ├── useAutoSave.ts
│   │   ├── useVersionControl.ts
│   │   ├── useAI.ts
│   │   ├── useQuotation.ts
│   │   ├── useDebounce.ts
│   │   └── useKeyboardShortcuts.ts
│   │
│   ├── stores/                       # Zustand状态管理
│   │   ├── editorStore.ts
│   │   ├── versionStore.ts
│   │   ├── aiStore.ts
│   │   ├── quotationStore.ts
│   │   └── authStore.ts
│   │
│   ├── lib/                          # 工具库
│   │   ├── api/                      # API客户端
│   │   │   ├── client.ts
│   │   │   ├── proposals.ts
│   │   │   ├── ai.ts
│   │   │   ├── quotations.ts
│   │   │   └── versions.ts
│   │   ├── utils/                    # 工具函数
│   │   │   ├── cn.ts                 # classnames工具
│   │   │   ├── format.ts
│   │   │   └── validation.ts
│   │   └── constants.ts
│   │
│   ├── types/                        # TypeScript类型定义
│   │   ├── proposal.ts
│   │   ├── module.ts
│   │   ├── ai.ts
│   │   ├── quotation.ts
│   │   └── api.ts
│   │
│   └── styles/                       # 全局样式
│       ├── globals.css
│       └── animations.css
│
├── public/                           # 静态资源
│   ├── fonts/
│   └── images/
│
├── tests/                            # 测试文件
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── .env.local                        # 环境变量
├── next.config.js                    # Next.js配置
├── tailwind.config.ts                # Tailwind配置
├── tsconfig.json                     # TypeScript配置
└── package.json
```

---

## 2. 技术栈详解

### 2.1 核心框架

**Next.js 14+ (App Router)**
```typescript
// app/layout.tsx
import { Inter, Playfair_Display } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter'
})

const playfair = Playfair_Display({
  subsets: ['latin'],
  variable: '--font-playfair'
})

export default function RootLayout({ children }) {
  return (
    <html lang="zh-CN" className={`${inter.variable} ${playfair.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

**React 18+**
- 使用函数组件和Hooks
- 避免使用类组件
- 合理使用React.memo优化性能

**TypeScript**
- 严格模式：`"strict": true`
- 所有组件必须有类型定义
- 避免使用`any`类型

### 2.2 样式方案

**Tailwind CSS**
```typescript
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        background: '#faf9f6',
        foreground: '#1a1a1a',
        primary: '#D4AF37',
        secondary: '#f1f1f1',
      },
      fontFamily: {
        sans: ['var(--font-inter)'],
        serif: ['var(--font-playfair)'],
      },
      animation: {
        'fade-in-up': 'fadeInUp 0.8s ease-out',
        'slide-in-right': 'slideInRight 0.3s ease-out',
      },
      keyframes: {
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(30px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideInRight: {
          '0%': { transform: 'translateX(100%)' },
          '100%': { transform: 'translateX(0)' },
        },
      },
    },
  },
  plugins: [],
}

export default config
```

**Framer Motion（动画）**
```typescript
import { motion } from 'framer-motion'

export function FadeInUp({ children }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8, ease: 'easeOut' }}
    >
      {children}
    </motion.div>
  )
}
```

---

## 3. 组件规范

### 3.1 组件分类

**1. 展示组件（Presentational Components）**
- 只负责UI渲染
- 通过props接收数据
- 无状态或只有UI状态
- 可复用性高

```typescript
// components/ui/Button.tsx
import { ButtonHTMLAttributes, forwardRef } from 'react'
import { cn } from '@/lib/utils/cn'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  loading?: boolean
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', loading, children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={cn(
          'inline-flex items-center justify-center rounded-md font-medium transition-colors',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2',
          'disabled:pointer-events-none disabled:opacity-50',
          {
            'bg-primary text-white hover:bg-primary/90': variant === 'primary',
            'bg-secondary text-foreground hover:bg-secondary/80': variant === 'secondary',
            'hover:bg-secondary/50': variant === 'ghost',
            'h-9 px-4 text-sm': size === 'sm',
            'h-11 px-6 text-base': size === 'md',
            'h-13 px-8 text-lg': size === 'lg',
          },
          className
        )}
        disabled={loading}
        {...props}
      >
        {loading && <Spinner className="mr-2" />}
        {children}
      </button>
    )
  }
)

Button.displayName = 'Button'
```

**2. 容器组件（Container Components）**
- 处理业务逻辑
- 管理状态
- 调用API
- 将数据传递给展示组件

```typescript
// components/editor/Canvas.tsx
'use client'

import { useEffect } from 'react'
import { useEditorStore } from '@/stores/editorStore'
import { useAutoSave } from '@/hooks/useAutoSave'
import { ModuleRenderer } from './ModuleRenderer'

interface CanvasProps {
  proposalId: string
}

export function Canvas({ proposalId }: CanvasProps) {
  const { modules, loadProposal, updateModule } = useEditorStore()
  const { saveStatus } = useAutoSave(proposalId)

  useEffect(() => {
    loadProposal(proposalId)
  }, [proposalId, loadProposal])

  return (
    <div className="relative h-full overflow-y-auto bg-background">
      {/* 保存状态指示器 */}
      <div className="fixed top-4 right-4 z-50">
        <SaveStatusIndicator status={saveStatus} />
      </div>

      {/* 渲染所有模块 */}
      <div className="mx-auto max-w-7xl space-y-0">
        {modules.map((module) => (
          <ModuleRenderer
            key={module.id}
            module={module}
            onUpdate={(data) => updateModule(module.id, data)}
          />
        ))}
      </div>
    </div>
  )
}
```

### 3.2 组件命名规范

- 使用PascalCase：`Button`, `EditPanel`, `AIPanel`
- 文件名与组件名一致：`Button.tsx`
- 索引文件导出：`index.ts`

```typescript
// components/editor/index.ts
export { Canvas } from './Canvas'
export { Toolbar } from './Toolbar'
export { PageNav } from './PageNav'
export { EditPanel } from './EditPanel'
```

### 3.3 Props类型定义

```typescript
// types/module.ts
export type ModuleType =
  | 'hero'
  | 'insight'
  | 'manifesto'
  | 'floorplan'
  | 'rendering'
  | 'gallery'
  | 'moodboard'
  | 'quotation'
  | 'delivery'

export interface BaseModule {
  id: string
  type: ModuleType
  order: number
  isVisible: boolean
  createdAt: string
  updatedAt: string
}

export interface HeroModuleData {
  title: string
  subtitle: string
  backgroundImage: string
  overlayOpacity: number
}

export interface HeroModule extends BaseModule {
  type: 'hero'
  data: HeroModuleData
}

// ... 其他模块类型定义

export type Module = HeroModule | InsightModule | RenderingModule | QuotationModule | ...
```

---

## 4. 状态管理

### 4.1 Zustand Store设计

**编辑器状态**
```typescript
// stores/editorStore.ts
import { create } from 'zustand'
import { devtools, persist } from 'zustand/middleware'
import type { Module } from '@/types/module'

interface EditorState {
  // 状态
  proposalId: string | null
  modules: Module[]
  selectedModuleId: string | null
  isEditPanelOpen: boolean
  isSaving: boolean
  lastSavedAt: Date | null

  // 操作
  loadProposal: (proposalId: string) => Promise<void>
  addModule: (type: ModuleType, position?: number) => void
  updateModule: (moduleId: string, data: Partial<Module['data']>) => void
  deleteModule: (moduleId: string) => void
  reorderModules: (fromIndex: number, toIndex: number) => void
  selectModule: (moduleId: string | null) => void
  toggleEditPanel: (open?: boolean) => void
  setSaving: (saving: boolean) => void
}

export const useEditorStore = create<EditorState>()(
  devtools(
    persist(
      (set, get) => ({
        // 初始状态
        proposalId: null,
        modules: [],
        selectedModuleId: null,
        isEditPanelOpen: false,
        isSaving: false,
        lastSavedAt: null,

        // 加载提案
        loadProposal: async (proposalId) => {
          try {
            const response = await api.proposals.getById(proposalId)
            set({
              proposalId,
              modules: response.data.modules,
            })
          } catch (error) {
            console.error('Failed to load proposal:', error)
          }
        },

        // 添加模块
        addModule: (type, position) => {
          const { modules } = get()
          const newModule: Module = {
            id: crypto.randomUUID(),
            type,
            order: position ?? modules.length,
            isVisible: true,
            data: getDefaultModuleData(type),
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString(),
          }

          set({
            modules: [...modules, newModule].sort((a, b) => a.order - b.order),
          })
        },

        // 更新模块
        updateModule: (moduleId, data) => {
          set((state) => ({
            modules: state.modules.map((module) =>
              module.id === moduleId
                ? { ...module, data: { ...module.data, ...data }, updatedAt: new Date().toISOString() }
                : module
            ),
          }))
        },

        // 删除模块
        deleteModule: (moduleId) => {
          set((state) => ({
            modules: state.modules.filter((m) => m.id !== moduleId),
            selectedModuleId: state.selectedModuleId === moduleId ? null : state.selectedModuleId,
          }))
        },

        // 重新排序
        reorderModules: (fromIndex, toIndex) => {
          set((state) => {
            const modules = [...state.modules]
            const [removed] = modules.splice(fromIndex, 1)
            modules.splice(toIndex, 0, removed)
            return {
              modules: modules.map((m, i) => ({ ...m, order: i })),
            }
          })
        },

        // 选择模块
        selectModule: (moduleId) => {
          set({ selectedModuleId: moduleId, isEditPanelOpen: !!moduleId })
        },

        // 切换编辑面板
        toggleEditPanel: (open) => {
          set((state) => ({
            isEditPanelOpen: open ?? !state.isEditPanelOpen,
          }))
        },

        // 设置保存状态
        setSaving: (saving) => {
          set({ isSaving: saving, lastSavedAt: saving ? null : new Date() })
        },
      }),
      {
        name: 'editor-storage',
        partialize: (state) => ({ proposalId: state.proposalId }), // 只持久化部分状态
      }
    )
  )
)
```

**AI状态**
```typescript
// stores/aiStore.ts
import { create } from 'zustand'
import type { AIGeneration, AIProvider } from '@/types/ai'

interface AIState {
  // 状态
  providers: AIProvider[]
  activeProvider: string | null
  generations: AIGeneration[]
  isGenerating: boolean
  currentGenerationId: string | null

  // 操作
  loadProviders: () => Promise<void>
  setActiveProvider: (provider: string) => void
  generateWithContext: (params: ContextAIParams) => Promise<string>
  generateGlobal: (params: GlobalAIParams) => Promise<string>
  getGenerationResult: (generationId: string) => Promise<AIGeneration>
  applyToProposal: (generationId: string, proposalId: string, moduleType: string) => Promise<void>
  saveToAssets: (generationId: string, selectedIndices: number[]) => Promise<void>
}

export const useAIStore = create<AIState>()((set, get) => ({
  providers: [],
  activeProvider: null,
  generations: [],
  isGenerating: false,
  currentGenerationId: null,

  loadProviders: async () => {
    const response = await api.ai.getProviders()
    set({ providers: response.data })
  },

  setActiveProvider: (provider) => {
    set({ activeProvider: provider })
  },

  generateWithContext: async (params) => {
    set({ isGenerating: true })
    try {
      const response = await api.ai.generateContext(params)
      set({ currentGenerationId: response.data.generation_id })
      return response.data.generation_id
    } finally {
      set({ isGenerating: false })
    }
  },

  // ... 其他操作
}))
```

---

## 5. 样式规范

### 5.1 Tailwind使用规范

**颜色使用**
```typescript
// 使用配置的颜色变量
<div className="bg-background text-foreground">
<button className="bg-primary text-white hover:bg-primary/90">
```

**响应式设计**
```typescript
<div className="
  w-full                    // Mobile
  md:w-1/2                  // Tablet
  lg:w-1/3                  // Desktop
  xl:w-1/4                  // Large Desktop
">
```

**动画使用**
```typescript
<div className="animate-fade-in-up">
<div className="transition-all duration-300 hover:scale-105">
```

### 5.2 自定义样式

```css
/* styles/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: #faf9f6;
    --foreground: #1a1a1a;
    --primary: #D4AF37;
  }

  body {
    @apply bg-background text-foreground font-sans antialiased;
  }

  h1, h2, h3, h4, h5, h6 {
    @apply font-serif;
  }
}

@layer components {
  .btn-primary {
    @apply bg-primary text-white px-6 py-3 rounded-md hover:bg-primary/90 transition-colors;
  }

  .panel-slide-in {
    @apply fixed right-0 top-0 h-full w-96 bg-white shadow-2xl transform transition-transform duration-300;
  }

  .panel-slide-in.open {
    @apply translate-x-0;
  }

  .panel-slide-in.closed {
    @apply translate-x-full;
  }
}
```

---

## 6. AI集成规范

### 6.1 上下文感知AI Hook

```typescript
// hooks/useContextAI.ts
import { useState } from 'use'
import { useAIStore } from '@/stores/aiStore'
import type { ModuleType } from '@/types/module'

interface UseContextAIParams {
  proposalId: string
  moduleType: ModuleType
}

export function useContextAI({ proposalId, moduleType }: UseContextAIParams) {
  const { generateWithContext, getGenerationResult, applyToProposal } = useAIStore()
  const [isGenerating, setIsGenerating] = useState(false)
  const [result, setResult] = useState<AIGeneration | null>(null)

  const generateImage = async (prompt: string, parameters?: Record<string, any>) => {
    setIsGenerating(true)
    try {
      const generationId = await generateWithContext({
        proposal_id: proposalId,
        module_type: moduleType,
        generation_type: 'image',
        prompt,
        parameters,
      })

      // 轮询获取结果
      const result = await pollGenerationResult(generationId)
      setResult(result)
      return result
    } finally {
      setIsGenerating(false)
    }
  }

  const generateText = async (prompt: string, parameters?: Record<string, any>) => {
    // 类似实现
  }

  const applyResult = async (selectedIndex: number = 0) => {
    if (!result) return
    await applyToProposal(result.id, proposalId, moduleType)
  }

  return {
    isGenerating,
    result,
    generateImage,
    generateText,
    applyResult,
  }
}

// 轮询辅助函数
async function pollGenerationResult(generationId: string, maxAttempts = 60): Promise<AIGeneration> {
  for (let i = 0; i < maxAttempts; i++) {
    const result = await api.ai.getGeneration(generationId)
    if (result.data.status === 'completed') {
      return result.data
    }
    if (result.data.status === 'failed') {
      throw new Error(result.data.error_message)
    }
    await new Promise(resolve => setTimeout(resolve, 1000))
  }
  throw new Error('Generation timeout')
}
```

### 6.2 上下文AI按钮组件

```typescript
// components/ai/ContextAIButton.tsx
'use client'

import { useState } from 'react'
import { useContextAI } from '@/hooks/useContextAI'
import { Button } from '@/components/ui/Button'
import { AIGenerationModal } from './AIGenerationModal'

interface ContextAIButtonProps {
  proposalId: string
  moduleType: ModuleType
  generationType: 'image' | 'text'
  onApply: (result: any) => void
}

export function ContextAIButton({
  proposalId,
  moduleType,
  generationType,
  onApply
}: ContextAIButtonProps) {
  const [isModalOpen, setIsModalOpen] = useState(false)
  const { isGenerating, result, generateImage, generateText, applyResult } = useContextAI({
    proposalId,
    moduleType,
  })

  const handleGenerate = async (prompt: string, parameters: Record<string, any>) => {
    if (generationType === 'image') {
      await generateImage(prompt, parameters)
    } else {
      await generateText(prompt, parameters)
    }
  }

  const handleApply = async (selectedIndex: number) => {
    await applyResult(selectedIndex)
    onApply(result)
    setIsModalOpen(false)
  }

  return (
    <>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => setIsModalOpen(true)}
        className="gap-2"
      >
        <SparklesIcon className="h-4 w-4" />
        AI生成{generationType === 'image' ? '图片' : '文案'}
      </Button>

      <AIGenerationModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        moduleType={moduleType}
        generationType={generationType}
        isGenerating={isGenerating}
        result={result}
        onGenerate={handleGenerate}
        onApply={handleApply}
      />
    </>
  )
}
```

---

## 7. 性能优化

### 7.1 代码分割

```typescript
// 动态导入大型组件
import dynamic from 'next/dynamic'

const Canvas = dynamic(() => import('@/components/editor/Canvas'), {
  loading: () => <CanvasSkeleton />,
  ssr: false,
})

const AIPanel = dynamic(() => import('@/components/ai/AIPanel'), {
  loading: () => <div>Loading AI Panel...</div>,
})
```

### 7.2 图片优化

```typescript
import Image from 'next/image'

<Image
  src="/hero-bg.jpg"
  alt="Hero Background"
  width={1920}
  height={1080}
  priority // 首屏图片
  placeholder="blur"
  blurDataURL="data:image/..."
/>
```

### 7.3 React优化

```typescript
import { memo, useCallback, useMemo } from 'react'

// 使用memo避免不必要的重渲染
export const ModuleRenderer = memo(({ module, onUpdate }) => {
  // 使用useCallback缓存回调函数
  const handleUpdate = useCallback((data) => {
    onUpdate(module.id, data)
  }, [module.id, onUpdate])

  // 使用useMemo缓存计算结果
  const processedData = useMemo(() => {
    return processModuleData(module.data)
  }, [module.data])

  return <div>{/* ... */}</div>
})
```

---

## 8. 测试规范

### 8.1 单元测试

```typescript
// __tests__/components/ui/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from '@/components/ui/Button'

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('handles click events', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)
    fireEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('shows loading state', () => {
    render(<Button loading>Click me</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

### 8.2 集成测试

```typescript
// __tests__/integration/editor.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import { Canvas } from '@/components/editor/Canvas'
import { useEditorStore } from '@/stores/editorStore'

describe('Editor Integration', () => {
  it('loads and displays proposal modules', async () => {
    render(<Canvas proposalId="test-id" />)

    await waitFor(() => {
      expect(screen.getByText('春江花园别墅')).toBeInTheDocument()
    })
  })
})
```

---

## 附录：常用命令

```bash
# 开发
npm run dev

# 构建
npm run build

# 测试
npm run test
npm run test:watch
npm run test:coverage

# 代码检查
npm run lint
npm run lint:fix

# 类型检查
npm run type-check
```
