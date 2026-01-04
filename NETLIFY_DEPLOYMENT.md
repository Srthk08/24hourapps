# Netlify Deployment Guide

## 🚀 Quick Deploy to Netlify

You have **3 easy options** to deploy to Netlify:

---

## ✅ Option 1: Drag & Drop (Easiest - No Installation Needed)

### Step 1: Build Your Project
```bash
npm run build
```

### Step 2: Deploy
1. Go to [app.netlify.com](https://app.netlify.com)
2. Sign up or log in
3. On the dashboard, find the **"Sites"** section
4. Look for **"Want to deploy a new site without connecting to Git? Drag and drop your site output folder here"**
5. **Drag the entire `dist` folder** (not its contents) into the deploy area
6. Wait for upload to complete
7. Your site will be live at a URL like: `https://random-name-12345.netlify.app`

### Step 3: Configure Environment Variables
1. Go to **Site settings** → **Environment variables**
2. Click **"Add a variable"**
3. Add these variables:
   - **Key:** `PUBLIC_SUPABASE_URL`
     **Value:** `https://tguopyxmlfxcalhfitob.supabase.co`
   - **Key:** `PUBLIC_SUPABASE_ANON_KEY`
     **Value:** Your Supabase anonymous key
4. Click **"Save"**
5. Go to **Deploys** tab → Click **"Trigger deploy"** → **"Clear cache and deploy site"**

---

## ✅ Option 2: Connect Git Repository (Recommended for Updates)

### Step 1: Push to GitHub/GitLab/Bitbucket
1. Create a repository on GitHub (if you don't have one)
2. Push your code:
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/your-repo.git
   git push -u origin main
   ```

### Step 2: Connect to Netlify
1. Go to [app.netlify.com](https://app.netlify.com)
2. Click **"Add new site"** → **"Import an existing project"**
3. Choose **GitHub** (or GitLab/Bitbucket)
4. Authorize Netlify to access your repositories
5. Select your repository
6. Netlify will auto-detect settings from `netlify.toml`:
   - **Build command:** `npm run build`
   - **Publish directory:** `dist`
7. Click **"Deploy site"**

### Step 3: Add Environment Variables
1. Go to **Site settings** → **Environment variables**
2. Add:
   - `PUBLIC_SUPABASE_URL` = `https://tguopyxmlfxcalhfitob.supabase.co`
   - `PUBLIC_SUPABASE_ANON_KEY` = Your Supabase key
3. Go to **Deploys** → **Trigger deploy** → **Clear cache and deploy site**

---

## ✅ Option 3: Using Netlify CLI

### Step 1: Install Netlify CLI
```bash
npm install -g netlify-cli
```

### Step 2: Login
```bash
netlify login
```
This will open your browser to authorize.

### Step 3: Initialize Site
```bash
netlify init
```
Follow the prompts:
- Create & configure a new site
- Team: Choose your team
- Site name: (leave blank for random name, or enter custom name)
- Build command: `npm run build` (already set in netlify.toml)
- Directory to deploy: `dist` (already set in netlify.toml)

### Step 4: Set Environment Variables
```bash
netlify env:set PUBLIC_SUPABASE_URL "https://tguopyxmlfxcalhfitob.supabase.co"
netlify env:set PUBLIC_SUPABASE_ANON_KEY "your-supabase-anon-key"
```

### Step 5: Deploy
```bash
# Build and deploy
npm run build
netlify deploy --prod
```

---

## 🔧 Post-Deployment Configuration

### 1. Update Supabase Redirect URLs
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **Authentication** → **URL Configuration**
4. Under **"Redirect URLs"**, add:
   ```
   https://your-site-name.netlify.app/auth/callback
   ```
5. Under **"Site URL"**, set:
   ```
   https://your-site-name.netlify.app
   ```
6. Click **"Save"**

### 2. Update Google OAuth Redirect URI
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Navigate to **APIs & Services** → **Credentials**
3. Click on your OAuth 2.0 Client ID
4. Under **"Authorized redirect URIs"**, add:
   ```
   https://your-site-name.netlify.app/auth/callback
   ```
5. Click **"Save"**

### 3. Custom Domain (Optional)
1. Go to Netlify Dashboard → **Site settings** → **Domain management**
2. Click **"Add custom domain"**
3. Enter your domain name
4. Follow DNS configuration instructions

---

## ✅ Verify Deployment

After deployment, test these:
- [ ] Homepage loads: `https://your-site.netlify.app`
- [ ] Products page: `https://your-site.netlify.app/products`
- [ ] Login page: `https://your-site.netlify.app/login`
- [ ] Google OAuth works
- [ ] Product "Under Development" popup shows for blocked products

---

## 🐛 Troubleshooting

### "Not Found" Error
- ✅ Make sure you uploaded the **entire `dist` folder**, not just its contents
- ✅ Check that `dist/index.html` exists
- ✅ Check that `dist/_redirects` exists
- ✅ Verify Netlify build settings match `netlify.toml`

### OAuth Not Working
- ✅ Check environment variables are set
- ✅ Verify redirect URLs in Supabase and Google Cloud Console
- ✅ Make sure you're using HTTPS (Netlify provides this automatically)

### Build Fails
- ✅ Check Node.js version (should be 18+)
- ✅ Check build logs in Netlify dashboard
- ✅ Verify `netlify.toml` is in project root

---

## 📝 Quick Reference

**Build Command:** `npm run build`  
**Publish Directory:** `dist`  
**Node Version:** 18  
**Configuration File:** `netlify.toml` (already configured!)

---

## 🎉 You're Ready!

Your project is configured and ready for Netlify. Choose one of the 3 options above and deploy!

**Recommended:** Option 2 (Git connection) for automatic deployments on every push.


