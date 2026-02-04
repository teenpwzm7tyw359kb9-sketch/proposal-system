# Frontend Implementation Guide V3.0

**Version**: 3.0
**Last Updated**: 2026-02-04
**Status**: Complete
**Tech Stack**: Next.js 14+, React 18+, TypeScript, Zustand, Tailwind CSS, Framer Motion

---

## Table of Contents

1. [Overview](#1-overview)
2. [Three-Panel Layout Architecture](#2-three-panel-layout-architecture)
3. [Component Architecture](#3-component-architecture)
4. [State Management with Zustand](#4-state-management-with-zustand)
5. [Auto-Save Implementation](#5-auto-save-implementation)
6. [Version Control UI](#6-version-control-ui)
7. [AI Integration UI](#7-ai-integration-ui)
8. [Module System](#8-module-system)
9. [Real-Time Collaboration](#9-real-time-collaboration)
10. [Performance Optimization](#10-performance-optimization)

---

## 1. Overview

### 1.1 Architecture Principles

- **Component-Based**: Modular, reusable components
- **Type-Safe**: Full TypeScript coverage
- **Performance-First**: Lazy loading, code splitting, memoization
- **Responsive**: Mobile-first design approach
- **Accessible**: WCAG 2.1 AA compliant

### 1.2 Tech Stack Rationale

| Technology | Purpose | Justification |
|------------|---------|---------------|
| Next.js 14+ | Framework | App Router, Server Components, optimized performance |
| React 18+ | UI Library | Concurrent features, Suspense, streaming SSR |
| TypeScript | Type Safety | Catch errors early, better DX, self-documenting |
| Zustand | State Management | Lightweight, simple API, no boilerplate |
| Tailwind CSS | Styling | Utility-first, consistent design, small bundle |
| Framer Motion | Animations | Declarative animations, gesture support |

---

## 2. Three-Panel Layout Architecture

### 2.1 Layout Structure

```tsx
// app/proposals/[id]/edit/layout.tsx
import { ProposalEditorLayout } from '@/components/editor/ProposalEditorLayout';

export default function EditorLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <ProposalEditorLayout>{children}</ProposalEditorLayout>;
}
```

### 2.2 ProposalEditorLayout Component

```tsx
// components/editor/ProposalEditorLayout.tsx
'use client';

import { useState } from 'react';
import { TopNavigation } from './TopNavigation';
import { LeftSidebar } from './LeftSidebar';
import { CentralCanvas } from './CentralCanvas';
import { RightPanel } from './RightPanel';
import { useProposalStore } from '@/stores/proposalStore';

export function ProposalEditorLayout({ children }: { children: React.ReactNode }) {
  const [isRightPanelOpen, setIsRightPanelOpen] = useState(true);
  const { modules, activeModuleId } = useProposalStore();

  return (
    <div className="h-screen flex flex-col bg-gray-50">
      {/* Top Navigation - Fixed 64px */}
      <TopNavigation
        onToggleRightPanel={() => setIsRightPanelOpen(!isRightPanelOpen)}
        isRightPanelOpen={isRightPanelOpen}
      />

      <div className="flex-1 flex overflow-hidden">
        {/* Left Sidebar - Fixed 80px */}
        <LeftSidebar modules={modules} activeModuleId={activeModuleId} />

        {/* Central Canvas - Flexible */}
        <CentralCanvas modules={modules} activeModuleId={activeModuleId} />

        {/* Right Panel - Fixed 450px, Collapsible */}
        {isRightPanelOpen && (
          <RightPanel
            activeModuleId={activeModuleId}
            onClose={() => setIsRightPanelOpen(false)}
          />
        )}
      </div>
    </div>
  );
}
```

### 2.3 Top Navigation Component

```tsx
// components/editor/TopNavigation.tsx
'use client';

import { Save, Eye, Share2, ChevronDown, User } from 'lucide-react';
import { useProposalStore } from '@/stores/proposalStore';
import { useSaveStatus } from '@/hooks/useSaveStatus';

export function TopNavigation({
  onToggleRightPanel,
  isRightPanelOpen
}: {
  onToggleRightPanel: () => void;
  isRightPanelOpen: boolean;
}) {
  const { proposal, modules, scrollToModule } = useProposalStore();
  const { status, lastSaved } = useSaveStatus();

  return (
    <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6">
      {/* Left: Logo & Module Quick Nav */}
      <div className="flex items-center gap-6">
        <div className="font-bold text-xl">Logo</div>

        <nav className="flex items-center gap-2">
          {modules.map((module) => (
            <button
              key={module.id}
              onClick={() => scrollToModule(module.id)}
              className="px-3 py-1.5 text-sm hover:bg-gray-100 rounded-md transition-colors"
            >
              {module.type}
            </button>
          ))}
        </nav>
      </div>

      {/* Center: Save Status */}
      <div className="flex items-center gap-2 text-sm">
        <Save className={`w-4 h-4 ${status === 'saving' ? 'animate-spin' : ''}`} />
        <span className="text-gray-600">
          {status === 'saved' && `已保存 ${lastSaved}`}
          {status === 'saving' && '保存中...'}
          {status === 'unsaved' && '未保存'}
        </span>
      </div>

      {/* Right: Actions */}
      <div className="flex items-center gap-3">
        <button className="px-4 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50 flex items-center gap-2">
          <Eye className="w-4 h-4" />
          预览
        </button>
        <button className="px-4 py-2 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700 flex items-center gap-2">
          <Share2 className="w-4 h-4" />
          分享
        </button>
        <button className="px-4 py-2 text-sm border border-gray-300 rounded-md hover:bg-gray-50 flex items-center gap-2">
          EDIT
          <ChevronDown className="w-4 h-4" />
        </button>
        <button className="w-8 h-8 rounded-full bg-gray-200 flex items-center justify-center">
          <User className="w-4 h-4" />
        </button>
      </div>
    </header>
  );
}
```

### 2.4 Left Sidebar Component

```tsx
// components/editor/LeftSidebar.tsx
'use client';

import { Plus } from 'lucide-react';
import { ModuleThumbnail } from './ModuleThumbnail';
import { AddModuleDialog } from './AddModuleDialog';
import { useState } from 'react';
import { DndContext, closestCenter, DragEndEvent } from '@dnd-kit/core';
import { SortableContext, verticalListSortingStrategy } from '@dnd-kit/sortable';
import type { ProposalModule } from '@/types/proposal';

export function LeftSidebar({
  modules,
  activeModuleId
}: {
  modules: ProposalModule[];
  activeModuleId: string | null;
}) {
  const [showAddDialog, setShowAddDialog] = useState(false);
  const { reorderModules, scrollToModule } = useProposalStore();

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (over && active.id !== over.id) {
      reorderModules(active.id as string, over.id as string);
    }
  };

  return (
    <aside className="w-20 bg-white border-r border-gray-200 flex flex-col items-center py-4 gap-3 overflow-y-auto">
      <DndContext collisionDetection={closestCenter} onDragEnd={handleDragEnd}>
        <SortableContext items={modules.map(m => m.id)} strategy={verticalListSortingStrategy}>
          {modules.map((module) => (
            <ModuleThumbnail
              key={module.id}
              module={module}
              isActive={module.id === activeModuleId}
              onClick={() => scrollToModule(module.id)}
            />
          ))}
        </SortableContext>
      </DndContext>

      <button
        onClick={() => setShowAddDialog(true)}
        className="w-14 h-14 rounded-lg border-2 border-dashed border-gray-300 hover:border-blue-500 hover:bg-blue-50 flex items-center justify-center transition-colors"
      >
        <Plus className="w-6 h-6 text-gray-400" />
      </button>

      {showAddDialog && (
        <AddModuleDialog onClose={() => setShowAddDialog(false)} />
      )}
    </aside>
  );
}
```

### 2.5 Central Canvas Component

```tsx
// components/editor/CentralCanvas.tsx
'use client';

import { useRef, useEffect } from 'react';
import { useProposalStore } from '@/stores/proposalStore';
import { ModuleRenderer } from './modules/ModuleRenderer';
import type { ProposalModule } from '@/types/proposal';

export function CentralCanvas({
  modules,
  activeModuleId
}: {
  modules: ProposalModule[];
  activeModuleId: string | null;
}) {
  const canvasRef = useRef<HTMLDivElement>(null);
  const { setActiveModule } = useProposalStore();

  // Intersection Observer for active module detection
  useEffect(() => {
    if (!canvasRef.current) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && entry.intersectionRatio > 0.5) {
            const moduleId = entry.target.getAttribute('data-module-id');
            if (moduleId) setActiveModule(moduleId);
          }
        });
      },
      { threshold: 0.5, root: canvasRef.current }
    );

    const moduleElements = canvasRef.current.querySelectorAll('[data-module-id]');
    moduleElements.forEach((el) => observer.observe(el));

    return () => observer.disconnect();
  }, [modules, setActiveModule]);

  return (
    <main
      ref={canvasRef}
      className="flex-1 overflow-y-auto bg-gray-100 p-8"
    >
      <div className="max-w-6xl mx-auto space-y-8">
        {modules.map((module) => (
          <div
            key={module.id}
            data-module-id={module.id}
            id={`module-${module.id}`}
            className="bg-white rounded-lg shadow-sm overflow-hidden"
          >
            <ModuleRenderer module={module} />
          </div>
        ))}
      </div>
    </main>
  );
}
```

