# Frontend Component Library V3.0

**Version**: 3.0
**Last Updated**: 2026-02-04
**Status**: Complete
**Design System**: Based on V4 Editor Design

---

## Table of Contents

1. [Design System Components](#1-design-system-components)
2. [Module-Specific Components](#2-module-specific-components)
3. [AI Integration Components](#3-ai-integration-components)
4. [Version Control Components](#4-version-control-components)
5. [Portfolio Import Components](#5-portfolio-import-components)
6. [Shared UI Components](#6-shared-ui-components)

---

## 1. Design System Components

### 1.1 Button Component

```tsx
// components/ui/Button.tsx
import { forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50',
  {
    variants: {
      variant: {
        primary: 'bg-blue-600 text-white hover:bg-blue-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        outline: 'border border-gray-300 bg-white hover:bg-gray-50',
        ghost: 'hover:bg-gray-100',
        danger: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        sm: 'h-8 px-3 text-sm',
        md: 'h-10 px-4 text-sm',
        lg: 'h-12 px-6 text-base',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  isLoading?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, isLoading, children, ...props }, ref) => {
    return (
      <button
        className={buttonVariants({ variant, size, className })}
        ref={ref}
        disabled={isLoading}
        {...props}
      >
        {isLoading && <Spinner className="mr-2 h-4 w-4" />}
        {children}
      </button>
    );
  }
);
```

### 1.2 Input Component

```tsx
// components/ui/Input.tsx
import { forwardRef } from 'react';

export interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, helperText, className, ...props }, ref) => {
    return (
      <div className="space-y-1">
        {label && (
          <label className="block text-sm font-medium text-gray-700">
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 ${
            error ? 'border-red-500' : 'border-gray-300'
          } ${className}`}
          {...props}
        />
        {error && <p className="text-sm text-red-600">{error}</p>}
        {helperText && !error && (
          <p className="text-sm text-gray-500">{helperText}</p>
        )}
      </div>
    );
  }
);
```

### 1.3 Modal Component

```tsx
// components/ui/Modal.tsx
import { Fragment } from 'react';
import { Dialog, Transition } from '@headlessui/react';
import { X } from 'lucide-react';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'xl' | 'full';
}

export function Modal({ isOpen, onClose, title, children, size = 'md' }: ModalProps) {
  const sizeClasses = {
    sm: 'max-w-md',
    md: 'max-w-lg',
    lg: 'max-w-2xl',
    xl: 'max-w-4xl',
    full: 'max-w-7xl',
  };

  return (
    <Transition appear show={isOpen} as={Fragment}>
      <Dialog as="div" className="relative z-50" onClose={onClose}>
        <Transition.Child
          as={Fragment}
          enter="ease-out duration-300"
          enterFrom="opacity-0"
          enterTo="opacity-100"
          leave="ease-in duration-200"
          leaveFrom="opacity-100"
          leaveTo="opacity-0"
        >
          <div className="fixed inset-0 bg-black bg-opacity-25" />
        </Transition.Child>

        <div className="fixed inset-0 overflow-y-auto">
          <div className="flex min-h-full items-center justify-center p-4">
            <Transition.Child
              as={Fragment}
              enter="ease-out duration-300"
              enterFrom="opacity-0 scale-95"
              enterTo="opacity-100 scale-100"
              leave="ease-in duration-200"
              leaveFrom="opacity-100 scale-100"
              leaveTo="opacity-0 scale-95"
            >
              <Dialog.Panel
                className={`w-full ${sizeClasses[size]} transform overflow-hidden rounded-lg bg-white shadow-xl transition-all`}
              >
                {title && (
                  <div className="flex items-center justify-between border-b border-gray-200 px-6 py-4">
                    <Dialog.Title className="text-lg font-semibold text-gray-900">
                      {title}
                    </Dialog.Title>
                    <button
                      onClick={onClose}
                      className="rounded-md p-1 hover:bg-gray-100"
                    >
                      <X className="h-5 w-5" />
                    </button>
                  </div>
                )}
                <div className="px-6 py-4">{children}</div>
              </Dialog.Panel>
            </Transition.Child>
          </div>
        </div>
      </Dialog>
    </Transition>
  );
}
```

---

## 2. Module-Specific Components

### 2.1 Module Thumbnail

```tsx
// components/editor/ModuleThumbnail.tsx
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import type { ProposalModule } from '@/types/proposal';

export function ModuleThumbnail({
  module,
  isActive,
  onClick,
}: {
  module: ProposalModule;
  isActive: boolean;
  onClick: () => void;
}) {
  const { attributes, listeners, setNodeRef, transform, transition } = useSortable({
    id: module.id,
  });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...attributes}
      {...listeners}
      onClick={onClick}
      className={`w-14 h-14 rounded-lg border-2 cursor-pointer transition-all ${
        isActive
          ? 'border-blue-500 bg-blue-50'
          : 'border-gray-200 bg-white hover:border-gray-300'
      }`}
    >
      <div className="w-full h-full flex items-center justify-center text-xs font-medium text-gray-600">
        {module.type.slice(0, 3)}
      </div>
    </div>
  );
}
```

### 2.2 Add Module Dialog

```tsx
// components/editor/AddModuleDialog.tsx
import { Modal } from '@/components/ui/Modal';
import { useProposalStore } from '@/stores/proposalStore';
import { moduleTemplates } from '@/lib/moduleTemplates';

export function AddModuleDialog({ onClose }: { onClose: () => void }) {
  const { addModule } = useProposalStore();

  const handleAddModule = (type: string) => {
    const template = moduleTemplates[type];
    addModule({
      id: crypto.randomUUID(),
      type,
      data: template.defaultData,
      order: 0,
    });
    onClose();
  };

  const categories = [
    {
      name: '基础模块',
      modules: [
        { type: 'hero', label: 'Hero', description: '英雄封面' },
        { type: 'insight', label: 'Insight', description: '设计理念' },
        { type: 'manifesto', label: 'Manifesto', description: '设计宣言' },
      ],
    },
    {
      name: '设计展示',
      modules: [
        { type: 'floorplan', label: 'Floorplan', description: '平面图对比 ⭐' },
        { type: 'storage', label: 'Storage', description: '收纳方案 ⭐' },
        { type: 'rendering', label: 'Rendering', description: '渲染图+热点 ⭐' },
        { type: 'gallery', label: 'Gallery', description: '效果图画廊 ⭐' },
        { type: 'moodboard', label: 'Moodboard', description: '情绪板 ⭐' },
      ],
    },
    {
      name: '项目信息',
      modules: [
        { type: 'technical', label: 'Technical', description: '技术说明' },
        { type: 'delivery', label: 'Delivery', description: '交付计划' },
        { type: 'quotation', label: 'Quotation', description: '产品报价' },
      ],
    },
    {
      name: '其他',
      modules: [
        { type: 'ending', label: 'Ending', description: '结尾页面' },
      ],
    },
  ];

  return (
    <Modal isOpen={true} onClose={onClose} title="选择要添加的模块" size="lg">
      <div className="space-y-6">
        {categories.map((category) => (
          <div key={category.name}>
            <h3 className="text-sm font-semibold text-gray-700 mb-3">
              {category.name}
            </h3>
            <div className="grid grid-cols-2 gap-3">
              {category.modules.map((module) => (
                <button
                  key={module.type}
                  onClick={() => handleAddModule(module.type)}
                  className="p-4 text-left border border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition-colors"
                >
                  <div className="font-medium text-gray-900">{module.label}</div>
                  <div className="text-sm text-gray-600 mt-1">
                    {module.description}
                  </div>
                </button>
              ))}
            </div>
          </div>
        ))}
      </div>
    </Modal>
  );
}
```

---

## 3. AI Integration Components

### 3.1 AI Generation Dialog

```tsx
// components/editor/ai/AIGenerationDialog.tsx
import { useState } from 'react';
import { Modal } from '@/components/ui/Modal';
import { Button } from '@/components/ui/Button';
import { Sparkles, RefreshCw } from 'lucide-react';
import { useAIGeneration } from '@/hooks/useAIGeneration';

interface AIGenerationDialogProps {
  isOpen: boolean;
  onClose: () => void;
  moduleType: string;
  generationType: 'text' | 'image';
  onApply: (result: any) => void;
}

export function AIGenerationDialog({
  isOpen,
  onClose,
  moduleType,
  generationType,
  onApply,
}: AIGenerationDialogProps) {
  const [prompt, setPrompt] = useState('');
  const { generate, isGenerating, results, error } = useAIGeneration();
  const [selectedResult, setSelectedResult] = useState<number>(0);

  const handleGenerate = async () => {
    await generate({
      moduleType,
      generationType,
      prompt,
    });
  };

  const handleApply = () => {
    if (results && results[selectedResult]) {
      onApply(results[selectedResult]);
      onClose();
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="AI 生成" size="xl">
      <div className="space-y-6">
        {/* Prompt Input */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            生成提示词
          </label>
          <textarea
            value={prompt}
            onChange={(e) => setPrompt(e.target.value)}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            rows={4}
            placeholder="描述您想要生成的内容..."
          />
        </div>

        {/* Generate Button */}
        <Button
          onClick={handleGenerate}
          isLoading={isGenerating}
          className="w-full"
        >
          <Sparkles className="w-4 h-4 mr-2" />
          {isGenerating ? '生成中...' : '开始生成'}
        </Button>

        {/* Results */}
        {results && results.length > 0 && (
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <h3 className="font-medium text-gray-900">生成结果</h3>
              <Button variant="ghost" size="sm" onClick={handleGenerate}>
                <RefreshCw className="w-4 h-4 mr-2" />
                重新生成
              </Button>
            </div>

            {generationType === 'text' ? (
              <div className="space-y-3">
                {results.map((result: string, index: number) => (
                  <div
                    key={index}
                    onClick={() => setSelectedResult(index)}
                    className={`p-4 border rounded-lg cursor-pointer transition-colors ${
                      selectedResult === index
                        ? 'border-blue-500 bg-blue-50'
                        : 'border-gray-200 hover:border-gray-300'
                    }`}
                  >
                    <p className="text-gray-900">{result}</p>
                  </div>
                ))}
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-4">
                {results.map((result: string, index: number) => (
                  <div
                    key={index}
                    onClick={() => setSelectedResult(index)}
                    className={`relative aspect-video rounded-lg overflow-hidden cursor-pointer border-2 transition-colors ${
                      selectedResult === index
                        ? 'border-blue-500'
                        : 'border-transparent'
                    }`}
                  >
                    <img
                      src={result}
                      alt={`Generated ${index + 1}`}
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* Error */}
        {error && (
          <div className="p-4 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-sm text-red-600">{error}</p>
          </div>
        )}

        {/* Actions */}
        {results && results.length > 0 && (
          <div className="flex justify-end gap-3">
            <Button variant="outline" onClick={onClose}>
              取消
            </Button>
            <Button onClick={handleApply}>应用选中项</Button>
          </div>
        )}
      </div>
    </Modal>
  );
}
```

### 3.2 AI Provider Selector

```tsx
// components/editor/ai/AIProviderSelector.tsx
import { Select } from '@/components/ui/Select';
import { useAISettings } from '@/hooks/useAISettings';

export function AIProviderSelector() {
  const { provider, model, setProvider, setModel, availableModels } = useAISettings();

  return (
    <div className="space-y-4">
      <Select
        label="AI 提供商"
        value={provider}
        onChange={(e) => setProvider(e.target.value)}
        options={[
          { value: 'openai', label: 'OpenAI' },
          { value: 'anthropic', label: 'Anthropic Claude' },
          { value: 'google', label: 'Google Gemini' },
        ]}
      />

      <Select
        label="模型"
        value={model}
        onChange={(e) => setModel(e.target.value)}
        options={availableModels.map((m) => ({
          value: m.id,
          label: m.name,
        }))}
      />
    </div>
  );
}
```

---

## 4. Version Control Components

### 4.1 Version Diff Viewer

```tsx
// components/editor/version/VersionDiffViewer.tsx
import { diffLines } from 'diff';
import type { ProposalVersion } from '@/types/version';

export function VersionDiffViewer({
  oldVersion,
  newVersion,
}: {
  oldVersion: ProposalVersion;
  newVersion: ProposalVersion;
}) {
  const oldContent = JSON.stringify(oldVersion.data, null, 2);
  const newContent = JSON.stringify(newVersion.data, null, 2);
  const diff = diffLines(oldContent, newContent);

  return (
    <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
      <div className="bg-gray-50 px-4 py-3 border-b border-gray-200">
        <h3 className="font-semibold text-gray-900">版本对比</h3>
        <p className="text-sm text-gray-600 mt-1">
          {oldVersion.versionNumber} → {newVersion.versionNumber}
        </p>
      </div>

      <div className="p-4 font-mono text-sm overflow-x-auto">
        {diff.map((part, index) => (
          <div
            key={index}
            className={`${
              part.added
                ? 'bg-green-50 text-green-900'
                : part.removed
                ? 'bg-red-50 text-red-900'
                : 'text-gray-700'
            }`}
          >
            {part.value.split('\n').map((line, lineIndex) => (
              <div key={lineIndex} className="px-2">
                <span className="inline-block w-8 text-gray-400">
                  {lineIndex + 1}
                </span>
                <span className="ml-4">{line}</span>
              </div>
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## 5. Portfolio Import Components

### 5.1 Portfolio Import Dialog

```tsx
// components/portfolio/PortfolioImportDialog.tsx
import { useState } from 'react';
import { Modal } from '@/components/ui/Modal';
import { Button } from '@/components/ui/Button';
import { Checkbox } from '@/components/ui/Checkbox';
import type { ProposalModule } from '@/types/proposal';

export function PortfolioImportDialog({
  isOpen,
  onClose,
  modules,
  onImport,
}: {
  isOpen: boolean;
  onClose: () => void;
  modules: ProposalModule[];
  onImport: (selectedModules: string[]) => void;
}) {
  const [selectedModules, setSelectedModules] = useState<Set<string>>(
    new Set(getRecommendedModules(modules))
  );

  const toggleModule = (moduleId: string) => {
    const newSelected = new Set(selectedModules);
    if (newSelected.has(moduleId)) {
      newSelected.delete(moduleId);
    } else {
      newSelected.add(moduleId);
    }
    setSelectedModules(newSelected);
  };

  const handleQuickSelect = (type: 'all' | 'recommended' | 'images' | 'none') => {
    switch (type) {
      case 'all':
        setSelectedModules(new Set(modules.map((m) => m.id)));
        break;
      case 'recommended':
        setSelectedModules(new Set(getRecommendedModules(modules)));
        break;
      case 'images':
        setSelectedModules(
          new Set(
            modules
              .filter((m) =>
                ['hero', 'rendering', 'gallery', 'moodboard'].includes(m.type)
              )
              .map((m) => m.id)
          )
        );
        break;
      case 'none':
        setSelectedModules(new Set());
        break;
    }
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose} title="导入到作品集" size="lg">
      <div className="space-y-6">
        {/* Quick Select */}
        <div className="flex gap-2">
          <Button size="sm" variant="outline" onClick={() => handleQuickSelect('all')}>
            全选
          </Button>
          <Button
            size="sm"
            variant="outline"
            onClick={() => handleQuickSelect('recommended')}
          >
            推荐配置
          </Button>
          <Button
            size="sm"
            variant="outline"
            onClick={() => handleQuickSelect('images')}
          >
            仅图片
          </Button>
          <Button size="sm" variant="outline" onClick={() => handleQuickSelect('none')}>
            清空
          </Button>
        </div>

        {/* Module Selection */}
        <div className="space-y-2 max-h-96 overflow-y-auto">
          {modules.map((module) => {
            const isRecommended = getRecommendedModules(modules).includes(module.id);
            const shouldRemove = ['floorplan', 'storage', 'technical', 'delivery', 'quotation'].includes(module.type);

            return (
              <div
                key={module.id}
                className="flex items-center justify-between p-3 border border-gray-200 rounded-lg"
              >
                <Checkbox
                  checked={selectedModules.has(module.id)}
                  onChange={() => toggleModule(module.id)}
                  label={module.type}
                />
                <span className="text-sm text-gray-500">
                  {isRecommended && '[推荐保留]'}
                  {shouldRemove && '[建议移除]'}
                </span>
              </div>
            );
          })}
        </div>

        {/* Preview */}
        <div className="bg-gray-50 p-4 rounded-lg space-y-2">
          <p className="text-sm font-medium text-gray-700">
            将保留 {selectedModules.size} 个章节
          </p>
          <p className="text-sm text-gray-600">
            将移除 {modules.length - selectedModules.size} 个章节
          </p>
        </div>

        {/* Actions */}
        <div className="flex justify-end gap-3">
          <Button variant="outline" onClick={onClose}>
            取消
          </Button>
          <Button onClick={() => onImport(Array.from(selectedModules))}>
            确认导入
          </Button>
        </div>
      </div>
    </Modal>
  );
}

function getRecommendedModules(modules: ProposalModule[]): string[] {
  return modules
    .filter((m) =>
      ['hero', 'insight', 'manifesto', 'rendering', 'gallery', 'moodboard', 'ending'].includes(
        m.type
      )
    )
    .map((m) => m.id);
}
```

---

## 6. Shared UI Components

### 6.1 Image Upload Component

```tsx
// components/ui/ImageUpload.tsx
import { useState } from 'react';
import { Upload, X } from 'lucide-react';
import { Button } from './Button';

export function ImageUpload({
  value,
  onChange,
  onAIGenerate,
}: {
  value?: string;
  onChange: (url: string) => void;
  onAIGenerate?: () => void;
}) {
  const [isUploading, setIsUploading] = useState(false);

  const handleUpload = async (file: File) => {
    setIsUploading(true);
    // Upload logic here
    const url = await uploadImage(file);
    onChange(url);
    setIsUploading(false);
  };

  return (
    <div className="space-y-3">
      {value ? (
        <div className="relative aspect-video rounded-lg overflow-hidden border border-gray-200">
          <img src={value} alt="Preview" className="w-full h-full object-cover" />
          <button
            onClick={() => onChange('')}
            className="absolute top-2 right-2 p-1 bg-white rounded-full shadow-md hover:bg-gray-100"
          >
            <X className="w-4 h-4" />
          </button>
        </div>
      ) : (
        <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
          <Upload className="w-8 h-8 mx-auto text-gray-400 mb-2" />
          <p className="text-sm text-gray-600 mb-4">拖拽图片或点击上传</p>
          <input
            type="file"
            accept="image/*"
            onChange={(e) => e.target.files?.[0] && handleUpload(e.target.files[0])}
            className="hidden"
            id="image-upload"
          />
          <label htmlFor="image-upload">
            <Button as="span" variant="outline" size="sm">
              选择文件
            </Button>
          </label>
        </div>
      )}

      <div className="flex gap-2">
        <Button variant="outline" size="sm" className="flex-1">
          素材库
        </Button>
        {onAIGenerate && (
          <Button variant="outline" size="sm" className="flex-1" onClick={onAIGenerate}>
            🤖 AI生成
          </Button>
        )}
      </div>
    </div>
  );
}
```

---

**Document Complete**: This component library provides all necessary UI components for the V4 editor implementation.
