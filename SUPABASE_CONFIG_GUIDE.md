# How to Change Supabase URL and Anon Key

## 📋 Overview
This guide explains how to replace the Supabase URL and anon key throughout the codebase.

## ✅ **RECOMMENDED METHOD: Using .env File**

### Step 1: Create/Update `.env` File
Create a file named `.env` in the root directory (`twenty_four_hour_apps-main/.env`) with:

```
VITE_SUPABASE_URL=your_new_supabase_url_here
VITE_SUPABASE_ANON_KEY=your_new_anon_key_here
```

**Example:**
```
VITE_SUPABASE_URL=https://yourproject.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Step 2: Update Fallback Values in Core Files
Even with `.env`, you should update the fallback values in these files:

#### File 1: `src/lib/supabase.ts` (Lines 3-6)
```typescript
const SUPABASE_CONFIG = {
  url: 'your_new_supabase_url_here',
  anonKey: 'your_new_anon_key_here'
};
```

#### File 2: `src/components/MenuOperatorGuard.astro` (Lines 10-13)
```typescript
const SUPABASE_CONFIG = {
  url: 'your_new_supabase_url_here',
  anonKey: 'your_new_anon_key_here'
};
```

#### File 3: `src/layouts/MenuOperatorLayout.astro` (Lines 542-543)
```typescript
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'your_new_supabase_url_here';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'your_new_anon_key_here';
```

### Step 3: Update Hardcoded Values in Other Files
These files have hardcoded values that need to be updated:

#### File 4: `src/lib/customization-db.js` (Lines 3-4)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
const SUPABASE_ANON_KEY = 'your_new_anon_key_here';
```

#### File 5: `src/pages/contact.astro` (Line 404)
```javascript
const supabaseUrl = 'your_new_supabase_url_here';
```

#### File 6: `src/pages/support.astro` (Line 262)
```javascript
const supabaseUrl = 'your_new_supabase_url_here';
```

#### File 7: `src/layouts/Layout.astro` (Line 726)
```javascript
const supabaseUrl = 'your_new_supabase_url_here';
```

#### File 8: `src/pages/auth/callback.astro` (Lines 6, 97)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

#### File 9: `src/pages/admin/users.astro` (Line 330)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

#### File 10: `src/pages/admin/support.astro` (Line 121)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

#### File 11: `src/pages/admin/profile.astro` (Line 173)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

#### File 12: `src/pages/admin/orders.astro` (Line 194)
```javascript
'your_new_supabase_url_here',
```

#### File 13: `src/pages/admin/index.astro` (Line 217)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

#### File 14: `src/pages/admin/data.astro` (Lines 375, 528)
```javascript
'your_new_supabase_url_here',
```

#### File 15: `src/pages/cart.astro` (Lines 2721, 2761)
```javascript
'your_new_supabase_url_here',
```

#### File 16: `src/layouts/MenuOperatorAdminLayout.astro` (Line 455)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

#### File 17: `src/layouts/AdminLayout.astro` (Line 503)
```javascript
const SUPABASE_URL = 'your_new_supabase_url_here';
```

## 🔍 How to Find All Instances

### Search for URL:
Search for: `lmrrdcaavwwletcjcpqv.supabase.co`

### Search for Anon Key:
Search for: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9`

## 📝 Summary

**Total Files to Update: 17 files**

1. ✅ `.env` (create new file)
2. ✅ `src/lib/supabase.ts`
3. ✅ `src/components/MenuOperatorGuard.astro`
4. ✅ `src/layouts/MenuOperatorLayout.astro`
5. ✅ `src/lib/customization-db.js`
6. ✅ `src/pages/contact.astro`
7. ✅ `src/pages/support.astro`
8. ✅ `src/layouts/Layout.astro`
9. ✅ `src/pages/auth/callback.astro`
10. ✅ `src/pages/admin/users.astro`
11. ✅ `src/pages/admin/support.astro`
12. ✅ `src/pages/admin/profile.astro`
13. ✅ `src/pages/admin/orders.astro`
14. ✅ `src/pages/admin/index.astro`
15. ✅ `src/pages/admin/data.astro`
16. ✅ `src/pages/cart.astro`
17. ✅ `src/layouts/MenuOperatorAdminLayout.astro`
18. ✅ `src/layouts/AdminLayout.astro`

## ⚠️ Important Notes

1. **Environment Variables**: Files that use `import.meta.env.VITE_SUPABASE_URL` will automatically use the `.env` file values if set correctly.

2. **Fallback Values**: Even if you set `.env`, update the fallback values in case the env file is missing.

3. **Restart Required**: After updating `.env`, restart your development server.

4. **Deployment**: Make sure to set environment variables in your hosting platform (Netlify, Vercel, etc.) as well.

## 🚀 Quick Steps

1. Create `.env` file with new values
2. Update `src/lib/supabase.ts` (main config)
3. Update `src/components/MenuOperatorGuard.astro`
4. Update `src/layouts/MenuOperatorLayout.astro`
5. Search and replace in all other files using your IDE's "Find and Replace" feature:
   - Find: `https://lmrrdcaavwwletcjcpqv.supabase.co`
   - Replace: `your_new_url`
   - Find: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (full key)
   - Replace: `your_new_key`



