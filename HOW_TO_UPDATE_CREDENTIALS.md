# 🔐 How to Update Credentials for a New Project

## 📍 Quick Answer: Where to Change Credentials

### ✅ **PRIMARY LOCATION (Easiest - Do This First!)**

**File:** `.env` (in the root directory)

Just update these two lines:
```env
VITE_SUPABASE_URL=your_new_supabase_url_here
VITE_SUPABASE_ANON_KEY=your_new_anon_key_here
```

**After updating `.env`:**
- ✅ Restart your development server
- ✅ Files that use `import.meta.env` will automatically use the new values

---

### ⚠️ **IMPORTANT: Also Update Fallback Values**

Even though `.env` works, you should also update the **fallback values** in code files. These are used if the `.env` file is missing or not loaded.

---

## 📝 Step-by-Step Guide

### **Step 1: Update `.env` File** (Required)

**Location:** `twenty_four_hour_apps-main/.env`

```env
VITE_SUPABASE_URL=https://your-new-project.supabase.co
VITE_SUPABASE_ANON_KEY=your_new_anon_key_here
```

---

### **Step 2: Update Main Configuration Files** (Recommended)

These are the **3 most important files** that need updating:

#### **File 1: `src/lib/supabase.ts`** (Lines 4-5)
```typescript
const SUPABASE_CONFIG = {
  url: 'https://your-new-project.supabase.co',  // ← Change this
  anonKey: 'your_new_anon_key_here'              // ← Change this
};
```

#### **File 2: `src/components/MenuOperatorGuard.astro`** (Lines 10-13)
```typescript
const SUPABASE_CONFIG = {
  url: 'https://your-new-project.supabase.co',  // ← Change this
  anonKey: 'your_new_anon_key_here'              // ← Change this
};
```

#### **File 3: `src/lib/customization-db.js`** (Lines 3-4)
```javascript
const SUPABASE_URL = 'https://your-new-project.supabase.co';  // ← Change this
const SUPABASE_ANON_KEY = 'your_new_anon_key_here';            // ← Change this
```

---

### **Step 3: Update Other Files** (Optional but Recommended)

These files also have hardcoded credentials. Update them for consistency:

#### **Files with Supabase URL only:**
- `src/pages/contact.astro` (Line 404)
- `src/pages/support.astro` (Line 262)
- `src/layouts/Layout.astro` (Line 726)
- `src/pages/auth/callback.astro` (Lines 6, 97)
- `src/pages/admin/users.astro` (Line 330)
- `src/pages/admin/support.astro` (Line 121)
- `src/pages/admin/profile.astro` (Line 173)
- `src/pages/admin/orders.astro` (Line 194)
- `src/pages/admin/index.astro` (Line 217)
- `src/pages/admin/data.astro` (Lines 375, 528)
- `src/pages/cart.astro` (Lines 2721, 2761)
- `src/layouts/MenuOperatorAdminLayout.astro` (Line 455)
- `src/layouts/AdminLayout.astro` (Line 503)

#### **File with environment variable fallback:**
- `src/layouts/MenuOperatorLayout.astro` (Lines 542-543)
```typescript
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://your-new-project.supabase.co';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'your_new_anon_key_here';
```

---

## 🚀 Quick Update Method (Using Find & Replace)

If you want to update all files at once, use your IDE's **Find & Replace** feature:

### **Find and Replace:**
1. **Find:** `https://lmrrdcaavwwletcjcpqv.supabase.co`
   **Replace:** `https://your-new-project.supabase.co`

2. **Find:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtcnJkY2Fhdnd3bGV0Y2pjcHF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MDQ0ODgsImV4cCI6MjA3MTA4MDQ4OH0.AU59Qfr6K9i880Gcn5y-3pjCf8PXsDIq4OI0-lPQVuQ`
   **Replace:** `your_new_anon_key_here`

---

## 📋 Summary: Minimum Required Changes

**For a new project, you MUST update:**

1. ✅ **`.env` file** - Primary location (REQUIRED)
2. ✅ **`src/lib/supabase.ts`** - Main config (RECOMMENDED)
3. ✅ **`src/components/MenuOperatorGuard.astro`** - Guard component (RECOMMENDED)
4. ✅ **`src/lib/customization-db.js`** - Customization DB (RECOMMENDED)

**The other 14 files are optional** but recommended for consistency.

---

## ⚡ After Updating Credentials

1. **Restart your development server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

2. **Clear browser cache** (if needed)

3. **Test the connection** - Try logging in or accessing Supabase features

---

## 🔍 How to Find Your New Supabase Credentials

1. Go to your Supabase project dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** → Use for `VITE_SUPABASE_URL`
   - **anon/public key** → Use for `VITE_SUPABASE_ANON_KEY`

---

## 📌 Notes

- **`.env` file is in `.gitignore`** - It won't be committed to Git (this is good for security!)
- **Always backup old credentials** before changing (like we did with `env_backup.txt`)
- **For production/deployment**, also set environment variables in your hosting platform (Netlify, Vercel, etc.)

---

**Last Updated:** Guide created after setting up `.env` file

