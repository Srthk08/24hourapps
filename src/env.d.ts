/// <reference path="../.astro/types.d.ts" />

// Astro environment variables
interface ImportMetaEnv {
  // Support both PUBLIC_ (Astro standard) and VITE_ (legacy) prefixes
  readonly PUBLIC_SUPABASE_URL?: string;
  readonly PUBLIC_SUPABASE_ANON_KEY?: string;
  readonly VITE_SUPABASE_URL?: string;
  readonly VITE_SUPABASE_ANON_KEY?: string;
  readonly DEV: boolean;
  readonly PROD: boolean;
  readonly SITE?: string;
  readonly BASE?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}

// Global types
declare global {
  interface Window {
    __ENV__?: Record<string, string>;
    showToast?: (message: string, type?: string, duration?: number) => void;
  }
}

export {};