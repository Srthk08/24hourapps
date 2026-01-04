# Deployment Troubleshooting Guide

## ❌ "Not Found" Error After Uploading dist Folder

If you're seeing a "Not Found" error after uploading the `dist` folder, here are the solutions:

### ✅ Solution 1: Check Your Hosting Platform

#### For Netlify:
1. **Make sure you're uploading the ENTIRE `dist` folder**, not just its contents
2. **OR** use Netlify's drag-and-drop and drag the entire `dist` folder
3. **OR** connect your Git repository and let Netlify build automatically

**Important:** The `_redirects` file MUST be in the root of your `dist` folder for Netlify to work properly.

#### For Vercel:
1. Connect your Git repository (recommended)
2. Vercel will automatically detect Astro and build correctly
3. Make sure `vercel.json` is in your project root

#### For Other Platforms:
- Make sure the platform supports static site hosting
- Ensure `index.html` is in the root of the uploaded folder
- Check if the platform requires a specific folder structure

---

### ✅ Solution 2: Verify Build Output

Run these commands to verify your build:

```bash
# 1. Build the project
npm run build

# 2. Check if index.html exists
ls dist/index.html

# 3. Check if _redirects file exists
ls dist/_redirects

# 4. Preview locally to test
npm run preview
```

**Expected output:**
- ✅ `dist/index.html` should exist
- ✅ `dist/_redirects` should exist
- ✅ `dist/_astro/` folder should exist with JavaScript files
- ✅ All page folders should have `index.html` files

---

### ✅ Solution 3: Fix Common Issues

#### Issue: Missing `_redirects` file
**Solution:** The `_redirects` file is in `public/_redirects` and should be copied to `dist/` during build. If it's missing:

1. Check if `public/_redirects` exists
2. Rebuild: `npm run build`
3. Verify: `ls dist/_redirects`

#### Issue: Wrong folder structure
**Solution:** Make sure you're uploading the `dist` folder structure like this:

```
dist/
├── index.html          ← MUST exist
├── _redirects          ← MUST exist for Netlify
├── _astro/            ← JavaScript/CSS files
├── about/
│   └── index.html
├── products/
│   ├── index.html
│   └── android-tv-app/
│       └── index.html
└── ... (other folders)
```

#### Issue: Platform doesn't support SPA routing
**Solution:** Some platforms need specific configuration:

**For GitHub Pages:**
- Add `base: '/your-repo-name/'` to `astro.config.mjs`
- Or use a custom domain

**For AWS S3:**
- Configure error document to `index.html`
- Enable static website hosting

---

### ✅ Solution 4: Test Locally First

Before deploying, test the build locally:

```bash
# Build
npm run build

# Preview
npm run preview
```

Then open `http://localhost:4321` in your browser. If it works locally, the build is correct.

---

### ✅ Solution 5: Platform-Specific Fixes

#### Netlify:
1. Go to Site settings → Build & deploy
2. Verify:
   - Build command: `npm run build`
   - Publish directory: `dist`
3. Check Deploy log for errors
4. Make sure `_redirects` file is in `dist/` root

#### Vercel:
1. Check Project settings → General
2. Verify:
   - Framework Preset: Astro
   - Build Command: `npm run build`
   - Output Directory: `dist`
3. Check Deployment logs

#### Cloudflare Pages:
1. Go to Pages → Settings → Builds & deployments
2. Verify:
   - Build command: `npm run build`
   - Build output directory: `dist`
3. Add environment variables if needed

---

### ✅ Solution 6: Check Browser Console

Open browser DevTools (F12) and check:
1. **Console tab** - Look for JavaScript errors
2. **Network tab** - Check if files are loading (404 errors)
3. **Application tab** - Check if service workers are interfering

---

### ✅ Solution 7: Verify File Paths

Make sure all file paths in your HTML are relative (not absolute):

✅ **Correct:**
```html
<link rel="stylesheet" href="/_astro/index.css">
<script src="/_astro/index.js"></script>
```

❌ **Wrong:**
```html
<link rel="stylesheet" href="http://localhost:4321/_astro/index.css">
```

---

### ✅ Solution 8: Rebuild and Redeploy

If nothing works, try a clean rebuild:

```bash
# 1. Clean old build
rm -rf dist
# Or on Windows:
rmdir /s /q dist

# 2. Rebuild
npm run build

# 3. Verify build
ls dist/index.html

# 4. Upload dist folder again
```

---

## 🔍 Quick Diagnostic Checklist

- [ ] `dist/index.html` exists
- [ ] `dist/_redirects` exists (for Netlify)
- [ ] `dist/_astro/` folder exists with files
- [ ] All page folders have `index.html`
- [ ] Build completed without errors
- [ ] Local preview works (`npm run preview`)
- [ ] Environment variables are set (if needed)
- [ ] Platform build settings are correct

---

## 📞 Still Not Working?

If you've tried everything above and it's still not working:

1. **Share the error message** - What exactly does it say?
2. **Share your hosting platform** - Netlify, Vercel, etc.?
3. **Check the build logs** - Are there any errors during build?
4. **Check browser console** - Any JavaScript errors?

---

## ✨ Quick Fix Commands

```bash
# Clean and rebuild
rm -rf dist node_modules/.vite
npm run build

# Test locally
npm run preview

# Check build output
ls -la dist/
```

**Your build should now work! 🚀**


