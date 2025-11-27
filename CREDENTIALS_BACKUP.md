# 🔐 Credentials Backup Documentation

## Current Credentials Location

This document shows where your Supabase credentials are currently stored in the codebase.

### 📋 Current Credentials

**Supabase URL:**
```
https://lmrrdcaavwwletcjcpqv.supabase.co
```

**Supabase Anon Key:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcnJkY2Fhdnd3bGV0Y2pjcHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDQ0ODgsImV4cCI6MjA3MTA4MDQ4OH0.AU59Qfr6K9i880Gcn5y-3pjCf8PXsDIq4OI0-lPQVuQ
```

---

## 📍 Files Where Credentials Are Currently Hardcoded

### 1. **Main Configuration File** (Primary Location)
**File:** `src/lib/supabase.ts`  
**Lines:** 4-5
```typescript
const SUPABASE_CONFIG = {
  url: 'https://lmrrdcaavwwletcjcpqv.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcnJkY2Fhdnd3bGV0Y2pjcHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDQ0ODgsImV4cCI6MjA3MTA4MDQ4OH0.AU59Qfr6K9i880Gcn5y-3pjCf8PXsDIq4OI0-lPQVuQ'
};
```

### 2. **Menu Operator Guard Component**
**File:** `src/components/MenuOperatorGuard.astro`  
**Lines:** 10-13
```typescript
const SUPABASE_CONFIG = {
  url: 'https://lmrrdcaavwwletcjcpqv.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcnJkY2Fhdnd3bGV0Y2pjcHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDQ0ODgsImV4cCI6MjA3MTA4MDQ4OH0.AU59Qfr6K9i880Gcn5y-3pjCf8PXsDIq4OI0-lPQVuQ'
};
```

### 3. **Customization Database**
**File:** `src/lib/customization-db.js`  
**Lines:** 3-4
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcnJkY2Fhdnd3bGV0Y2pjcHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDQ0ODgsImV4cCI6MjA3MTA4MDQ4OH0.AU59Qfr6K9i880Gcn5y-3pjCf8PXsDIq4OI0-lPQVuQ';
```

### 4. **Contact Page**
**File:** `src/pages/contact.astro`  
**Line:** 404
```javascript
const supabaseUrl = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 5. **Support Page**
**File:** `src/pages/support.astro`  
**Line:** 262
```javascript
const supabaseUrl = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 6. **Main Layout**
**File:** `src/layouts/Layout.astro`  
**Line:** 726
```javascript
const supabaseUrl = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 7. **Menu Operator Layout**
**File:** `src/layouts/MenuOperatorLayout.astro`  
**Lines:** 542-543
```typescript
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://lmrrdcaavwwletcjcpqv.supabase.co';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcnJkY2Fhdnd3bGV0Y2pjcHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDQ0ODgsImV4cCI6MjA3MTA4MDQ4OH0.AU59Qfr6K9i880Gcn5y-3pjCf8PXsDIq4OI0-lPQVuQ';
```

### 8. **Auth Callback Page**
**File:** `src/pages/auth/callback.astro`  
**Lines:** 6, 97
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 9. **Admin Users Page**
**File:** `src/pages/admin/users.astro`  
**Line:** 330
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 10. **Admin Support Page**
**File:** `src/pages/admin/support.astro`  
**Line:** 121
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 11. **Admin Profile Page**
**File:** `src/pages/admin/profile.astro`  
**Line:** 173
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 12. **Admin Orders Page**
**File:** `src/pages/admin/orders.astro`  
**Line:** 194
```javascript
'https://lmrrdcaavwwletcjcpqv.supabase.co',
```

### 13. **Admin Index Page**
**File:** `src/pages/admin/index.astro`  
**Line:** 217
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 14. **Admin Data Page**
**File:** `src/pages/admin/data.astro`  
**Lines:** 375, 528
```javascript
'https://lmrrdcaavwwletcjcpqv.supabase.co',
```

### 15. **Cart Page**
**File:** `src/pages/cart.astro`  
**Lines:** 2721, 2761
```javascript
'https://lmrrdcaavwwletcjcpqv.supabase.co',
```

### 16. **Menu Operator Admin Layout**
**File:** `src/layouts/MenuOperatorAdminLayout.astro`  
**Line:** 455
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

### 17. **Admin Layout**
**File:** `src/layouts/AdminLayout.astro`  
**Line:** 503
```javascript
const SUPABASE_URL = 'https://lmrrdcaavwwletcjcpqv.supabase.co';
```

---

## 📝 Backup Files Created

1. **`.env.backup`** - Contains the current credentials in .env format
2. **`CREDENTIALS_BACKUP.md`** - This documentation file

---

## ⚠️ Important Notes

1. **No .env file exists yet** - The credentials are currently hardcoded in the files listed above.

2. **When you create a new .env file:**
   - The credentials in `.env.backup` are your current working credentials
   - Copy them to your new `.env` file if you want to keep using the same credentials
   - Or replace them with new credentials if you're switching to a new Supabase project

3. **Environment Variables:**
   - `VITE_SUPABASE_URL` - Your Supabase project URL
   - `VITE_SUPABASE_ANON_KEY` - Your Supabase anonymous/public key

4. **Files that use environment variables:**
   - `src/lib/supabase.ts` - Will use `.env` values if available
   - `src/components/MenuOperatorGuard.astro` - Will use `.env` values if available
   - `src/layouts/MenuOperatorLayout.astro` - Will use `.env` values if available
   - Other files still have hardcoded values that need to be updated manually

---

## 🔄 Next Steps

1. **Review the credentials** in `.env.backup`
2. **Create your new `.env` file** with either:
   - The same credentials (copy from `.env.backup`)
   - New credentials (if switching projects)
3. **Restart your development server** after creating/updating `.env`
4. **Update hardcoded values** in the 17 files listed above (optional but recommended)

---

**Last Updated:** Backup created before creating new .env file

