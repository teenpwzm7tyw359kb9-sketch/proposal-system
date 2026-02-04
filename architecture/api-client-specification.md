# API Client Specification V3.0

**Version**: 3.0
**Last Updated**: 2026-02-04
**Status**: Complete
**Tech Stack**: TypeScript, Axios, React Query

---

## Table of Contents

1. [API Client Architecture](#1-api-client-architecture)
2. [TypeScript Interfaces](#2-typescript-interfaces)
3. [API Hooks for All 12 Modules](#3-api-hooks-for-all-12-modules)
4. [Auto-Save Hooks](#4-auto-save-hooks)
5. [Version Control Hooks](#5-version-control-hooks)
6. [AI Generation Hooks](#6-ai-generation-hooks)
7. [Error Handling and Retry Logic](#7-error-handling-and-retry-logic)

---

## 1. API Client Architecture

### 1.1 Base API Client

```typescript
// lib/api/client.ts
import axios, { AxiosInstance, AxiosRequestConfig } from 'axios';
import { getSession } from 'next-auth/react';

class APIClient {
  private client: AxiosInstance;

  constructor() {
    this.client = axios.create({
      baseURL: process.env.NEXT_PUBLIC_API_URL || '/api',
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // Request interceptor for auth
    this.client.interceptors.request.use(
      async (config) => {
        const session = await getSession();
        if (session?.accessToken) {
          config.headers.Authorization = `Bearer ${session.accessToken}`;
        }
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor for error handling
    this.client.interceptors.response.use(
      (response) => response,
      async (error) => {
        if (error.response?.status === 401) {
          // Handle token refresh or redirect to login
          window.location.href = '/login';
        }
        return Promise.reject(error);
      }
    );
  }

  async get<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.get<T>(url, config);
    return response.data;
  }

  async post<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.post<T>(url, data, config);
    return response.data;
  }

  async put<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.put<T>(url, data, config);
    return response.data;
  }

  async patch<T>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.patch<T>(url, data, config);
    return response.data;
  }

  async delete<T>(url: string, config?: AxiosRequestConfig): Promise<T> {
    const response = await this.client.delete<T>(url, config);
    return response.data;
  }
}

export const apiClient = new APIClient();
```

---

## 2. TypeScript Interfaces

### 2.1 Proposal Types

```typescript
// types/proposal.ts
export interface Proposal {
  id: string;
  title: string;
  clientName: string;
  projectName: string;
  status: 'draft' | 'published' | 'archived';
  modules: ProposalModule[];
  createdAt: string;
  updatedAt: string;
  createdBy: string;
}

export interface ProposalModule {
  id: string;
  type: ModuleType;
  order: number;
  data: ModuleData;
}

export type ModuleType =
  | 'hero'
  | 'insight'
  | 'manifesto'
  | 'floorplan'
  | 'storage'
  | 'rendering'
  | 'gallery'
  | 'moodboard'
  | 'technical'
  | 'delivery'
  | 'quotation'
  | 'ending';

export type ModuleData =
  | HeroModuleData
  | InsightModuleData
  | ManifestoModuleData
  | FloorplanModuleData
  | StorageModuleData
  | RenderingModuleData
  | GalleryModuleData
  | MoodboardModuleData
  | TechnicalModuleData
  | DeliveryModuleData
  | QuotationModuleData
  | EndingModuleData;
```

### 2.2 Module Data Types

```typescript
// types/modules.ts
export interface HeroModuleData {
  titleCn: string;
  titleEn: string;
  subtitleCn: string;
  subtitleEn: string;
  clientName: string;
  buttonText: string;
  backgroundImage: string;
  textColor: string;
  overlayOpacity: number;
  textAlign: 'left' | 'center' | 'right';
}

export interface InsightModuleData {
  labelEn: string;
  titleCn: string;
  content: string;
  image: string;
  grayscale: boolean;
  allowZoom: boolean;
  layoutRatio: '40-60' | '50-50' | '60-40';
}

export interface FloorplanModuleData {
  labelEn: string;
  titleCn: string;
  beforeImage: string;
  afterImage: string;
  beforeLabel: string;
  afterLabel: string;
  description?: string;
  transitionEffect: 'fade' | 'slideLeft' | 'slideUp';
  defaultView: 'before' | 'after';
}

export interface StorageModuleData {
  labelEn: string;
  titleCn: string;
  areas: StorageArea[];
  layout: '2-column' | '3-column';
}

export interface StorageArea {
  name: string;
  volume: string;
  description: string;
  image: string;
}

export interface RenderingModuleData {
  labelEn: string;
  titleCn: string;
  renderingImage: string;
  hotspots: Hotspot[];
  showSidebar: boolean;
  showPrice: boolean;
}

export interface Hotspot {
  id: string;
  x: number; // percentage
  y: number; // percentage
  label: string;
  title: string;
  description: string;
  price?: string;
}

export interface GalleryModuleData {
  labelEn: string;
  titleCn: string;
  images: GalleryImage[];
  layout: '2-column' | '3-column' | '4-column' | 'masonry';
  showCategoryFilter: boolean;
  showImageTitle: boolean;
}

export interface GalleryImage {
  url: string;
  title: string;
  category: string;
}

export interface MoodboardModuleData {
  labelEn: string;
  titleCn: string;
  colors: ColorSwatch[];
  images: ReferenceImage[];
  layout: 'asymmetric' | 'grid' | 'masonry';
}

export interface ColorSwatch {
  hex: string;
  name: string;
}

export interface ReferenceImage {
  url: string;
  size: 'small' | 'medium' | 'large';
  opacity: number;
}

export interface TechnicalModuleData {
  labelEn: string;
  titleCn: string;
  content: string;
  layout: 'single' | 'double';
}

export interface DeliveryModuleData {
  labelEn: string;
  titleCn: string;
  phases: DeliveryPhase[];
  totalDuration: string;
}

export interface DeliveryPhase {
  name: string;
  duration: string;
  tasks: string[];
}

export interface QuotationModuleData {
  labelEn: string;
  titleCn: string;
  quotationId: string;
  showProductImages: boolean;
  showSpecs: boolean;
  showSubtotal: boolean;
  showNotes: boolean;
  allowOnlineConfirmation: boolean;
  validityDays: number;
}

export interface EndingModuleData {
  titleCn: string;
  titleEn: string;
  subtitleCn: string;
  subtitleEn: string;
  companyName: string;
  phone: string;
  email: string;
  address: string;
  wechatQR?: string;
  officialQR?: string;
  backgroundType: 'color' | 'image';
  backgroundColor?: string;
  backgroundImage?: string;
  textColor: string;
}
```

### 2.3 Version Types

```typescript
// types/version.ts
export interface ProposalVersion {
  id: string;
  proposalId: string;
  versionNumber: number;
  summary?: string;
  changes?: string;
  data: any;
  author: string;
  createdAt: string;
}

export interface VersionDiff {
  added: string[];
  removed: string[];
  modified: string[];
}
```

### 2.4 AI Types

```typescript
// types/ai.ts
export interface AIGenerationRequest {
  moduleType: string;
  generationType: 'text' | 'image';
  prompt: string;
  options?: {
    style?: string;
    size?: string;
    count?: number;
  };
}

export interface AIGenerationResponse {
  results: string[];
  usage: {
    tokens: number;
    cost: number;
  };
}

export interface AIProvider {
  id: string;
  name: string;
  models: AIModel[];
}

export interface AIModel {
  id: string;
  name: string;
  type: 'text' | 'image' | 'both';
}
```

---

## 3. API Hooks for All 12 Modules

### 3.1 Proposal Hooks

```typescript
// hooks/api/useProposal.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { Proposal } from '@/types/proposal';

export function useProposal(proposalId: string) {
  return useQuery({
    queryKey: ['proposal', proposalId],
    queryFn: () => apiClient.get<Proposal>(`/proposals/${proposalId}`),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
}

export function useProposals() {
  return useQuery({
    queryKey: ['proposals'],
    queryFn: () => apiClient.get<Proposal[]>('/proposals'),
  });
}

export function useCreateProposal() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Proposal>) =>
      apiClient.post<Proposal>('/proposals', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposals'] });
    },
  });
}

export function useUpdateProposal(proposalId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<Proposal>) =>
      apiClient.patch<Proposal>(`/proposals/${proposalId}`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
      queryClient.invalidateQueries({ queryKey: ['proposals'] });
    },
  });
}

export function useDeleteProposal() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (proposalId: string) =>
      apiClient.delete(`/proposals/${proposalId}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposals'] });
    },
  });
}
```

### 3.2 Module Hooks

```typescript
// hooks/api/useModules.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { ProposalModule } from '@/types/proposal';

export function useAddModule(proposalId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (module: ProposalModule) =>
      apiClient.post(`/proposals/${proposalId}/modules`, module),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
    },
  });
}

export function useUpdateModule(proposalId: string, moduleId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<ProposalModule>) =>
      apiClient.patch(`/proposals/${proposalId}/modules/${moduleId}`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
    },
  });
}

export function useDeleteModule(proposalId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (moduleId: string) =>
      apiClient.delete(`/proposals/${proposalId}/modules/${moduleId}`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
    },
  });
}

export function useReorderModules(proposalId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (moduleIds: string[]) =>
      apiClient.post(`/proposals/${proposalId}/modules/reorder`, { moduleIds }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
    },
  });
}
```

---

## 4. Auto-Save Hooks

### 4.1 Auto-Save with Debounce

```typescript
// hooks/api/useAutoSave.ts
import { useEffect, useRef, useCallback } from 'react';
import { useMutation } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import { useAutosaveStore } from '@/stores/autosaveStore';
import { debounce } from 'lodash';

export function useAutoSave(proposalId: string, debounceMs: number = 3000) {
  const { setStatus, setLastSaved, setError } = useAutosaveStore();
  const saveTimeoutRef = useRef<NodeJS.Timeout>();

  const saveMutation = useMutation({
    mutationFn: (data: any) =>
      apiClient.patch(`/proposals/${proposalId}/autosave`, data),
    onMutate: () => {
      setStatus('saving');
    },
    onSuccess: () => {
      setLastSaved(new Date());
      setStatus('saved');
    },
    onError: (error: any) => {
      setError(error.message || 'Auto-save failed');
      setStatus('error');
    },
  });

  const debouncedSave = useCallback(
    debounce((data: any) => {
      saveMutation.mutate(data);
    }, debounceMs),
    [saveMutation, debounceMs]
  );

  const save = useCallback(
    (data: any) => {
      setStatus('unsaved');
      debouncedSave(data);
    },
    [debouncedSave, setStatus]
  );

  const saveImmediately = useCallback(
    (data: any) => {
      debouncedSave.cancel();
      saveMutation.mutate(data);
    },
    [debouncedSave, saveMutation]
  );

  useEffect(() => {
    return () => {
      debouncedSave.cancel();
    };
  }, [debouncedSave]);

  return {
    save,
    saveImmediately,
    isSaving: saveMutation.isPending,
  };
}
```

### 4.2 Optimistic Updates

```typescript
// hooks/api/useOptimisticUpdate.ts
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { Proposal } from '@/types/proposal';

export function useOptimisticModuleUpdate(proposalId: string, moduleId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: any) =>
      apiClient.patch(`/proposals/${proposalId}/modules/${moduleId}`, data),

    // Optimistic update
    onMutate: async (newData) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['proposal', proposalId] });

      // Snapshot previous value
      const previousProposal = queryClient.getQueryData<Proposal>([
        'proposal',
        proposalId,
      ]);

      // Optimistically update
      queryClient.setQueryData<Proposal>(['proposal', proposalId], (old) => {
        if (!old) return old;
        return {
          ...old,
          modules: old.modules.map((m) =>
            m.id === moduleId ? { ...m, ...newData } : m
          ),
        };
      });

      return { previousProposal };
    },

    // Rollback on error
    onError: (err, newData, context) => {
      if (context?.previousProposal) {
        queryClient.setQueryData(['proposal', proposalId], context.previousProposal);
      }
    },

    // Refetch on success or error
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
    },
  });
}
```

---

## 5. Version Control Hooks

### 5.1 Version Hooks

```typescript
// hooks/api/useVersions.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { ProposalVersion } from '@/types/version';

export function useVersions(proposalId: string) {
  return useQuery({
    queryKey: ['versions', proposalId],
    queryFn: () =>
      apiClient.get<ProposalVersion[]>(`/proposals/${proposalId}/versions`),
  });
}

export function useCreateVersion(proposalId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: { summary?: string; changes?: string }) =>
      apiClient.post<ProposalVersion>(`/proposals/${proposalId}/versions`, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['versions', proposalId] });
    },
  });
}

export function useRestoreVersion(proposalId: string) {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (versionId: string) =>
      apiClient.post(`/proposals/${proposalId}/versions/${versionId}/restore`),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['proposal', proposalId] });
      queryClient.invalidateQueries({ queryKey: ['versions', proposalId] });
    },
  });
}

export function useCompareVersions(proposalId: string) {
  return useMutation({
    mutationFn: ({ versionA, versionB }: { versionA: string; versionB: string }) =>
      apiClient.get(
        `/proposals/${proposalId}/versions/compare?a=${versionA}&b=${versionB}`
      ),
  });
}
```

---

## 6. AI Generation Hooks

### 6.1 AI Generation Hook

```typescript
// hooks/api/useAIGeneration.ts
import { useMutation } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { AIGenerationRequest, AIGenerationResponse } from '@/types/ai';

export function useAIGeneration() {
  const mutation = useMutation({
    mutationFn: (request: AIGenerationRequest) =>
      apiClient.post<AIGenerationResponse>('/ai/generate', request),
  });

  return {
    generate: mutation.mutate,
    isGenerating: mutation.isPending,
    results: mutation.data?.results,
    usage: mutation.data?.usage,
    error: mutation.error?.message,
  };
}
```

### 6.2 AI Settings Hook

```typescript
// hooks/api/useAISettings.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { AIProvider } from '@/types/ai';

export function useAISettings() {
  const queryClient = useQueryClient();

  const { data: settings } = useQuery({
    queryKey: ['ai-settings'],
    queryFn: () => apiClient.get('/ai/settings'),
  });

  const { data: providers } = useQuery({
    queryKey: ['ai-providers'],
    queryFn: () => apiClient.get<AIProvider[]>('/ai/providers'),
  });

  const updateSettings = useMutation({
    mutationFn: (data: any) => apiClient.patch('/ai/settings', data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['ai-settings'] });
    },
  });

  return {
    provider: settings?.provider,
    model: settings?.model,
    availableModels: providers?.find((p) => p.id === settings?.provider)?.models || [],
    setProvider: (provider: string) => updateSettings.mutate({ provider }),
    setModel: (model: string) => updateSettings.mutate({ model }),
  };
}
```

---

## 7. Error Handling and Retry Logic

### 7.1 Error Handler

```typescript
// lib/api/errorHandler.ts
import { AxiosError } from 'axios';
import { toast } from 'sonner';

export interface APIError {
  message: string;
  code: string;
  details?: any;
}

export function handleAPIError(error: unknown) {
  if (error instanceof AxiosError) {
    const apiError = error.response?.data as APIError;

    switch (error.response?.status) {
      case 400:
        toast.error(apiError?.message || '请求参数错误');
        break;
      case 401:
        toast.error('未授权，请重新登录');
        window.location.href = '/login';
        break;
      case 403:
        toast.error('没有权限执行此操作');
        break;
      case 404:
        toast.error('请求的资源不存在');
        break;
      case 429:
        toast.error('请求过于频繁，请稍后再试');
        break;
      case 500:
        toast.error('服务器错误，请稍后再试');
        break;
      default:
        toast.error(apiError?.message || '发生未知错误');
    }

    return apiError;
  }

  toast.error('网络错误，请检查您的连接');
  return { message: 'Network error', code: 'NETWORK_ERROR' };
}
```

### 7.2 Retry Configuration

```typescript
// lib/api/queryClient.ts
import { QueryClient } from '@tanstack/react-query';
import { handleAPIError } from './errorHandler';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: (failureCount, error) => {
        // Don't retry on 4xx errors
        if (error instanceof Error && 'response' in error) {
          const status = (error as any).response?.status;
          if (status >= 400 && status < 500) {
            return false;
          }
        }
        // Retry up to 3 times for other errors
        return failureCount < 3;
      },
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000),
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes (formerly cacheTime)
    },
    mutations: {
      retry: false,
      onError: handleAPIError,
    },
  },
});
```

### 7.3 Network Status Hook

```typescript
// hooks/useNetworkStatus.ts
import { useEffect, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';

export function useNetworkStatus() {
  const [isOnline, setIsOnline] = useState(
    typeof navigator !== 'undefined' ? navigator.onLine : true
  );
  const queryClient = useQueryClient();

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
      // Refetch all queries when coming back online
      queryClient.refetchQueries();
    };

    const handleOffline = () => {
      setIsOnline(false);
    };

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, [queryClient]);

  return { isOnline };
}
```

---

## 8. Usage Examples

### 8.1 Complete Editor Integration

```typescript
// app/proposals/[id]/edit/page.tsx
'use client';

import { useProposal } from '@/hooks/api/useProposal';
import { useAutoSave } from '@/hooks/api/useAutoSave';
import { useProposalStore } from '@/stores/proposalStore';
import { ProposalEditorLayout } from '@/components/editor/ProposalEditorLayout';

export default function ProposalEditorPage({ params }: { params: { id: string } }) {
  const { data: proposal, isLoading } = useProposal(params.id);
  const { save } = useAutoSave(params.id);
  const { modules, setProposal } = useProposalStore();

  useEffect(() => {
    if (proposal) {
      setProposal(proposal);
    }
  }, [proposal, setProposal]);

  useEffect(() => {
    if (modules) {
      save({ modules });
    }
  }, [modules, save]);

  if (isLoading) return <div>Loading...</div>;

  return <ProposalEditorLayout />;
}
```

---

**Document Complete**: This API client specification provides comprehensive TypeScript interfaces and React Query hooks for all frontend API interactions.
