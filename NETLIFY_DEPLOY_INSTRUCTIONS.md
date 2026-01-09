# 🚀 Netlify Deployment Instructions

## ✅ Build Status
- ✅ Build completed successfully
- ✅ 33 pages generated in `dist/` folder
- ✅ All static assets ready for deployment

## 📦 Build Output
- **Build Directory:** `dist/`
- **Total Pages:** 33 pages
- **Build Time:** ~11 seconds
- **Status:** Ready for deployment

## 🔧 Deployment Steps

### Option 1: Drag & Drop (Easiest)

1. **Go to Netlify Dashboard**
   - Visit: https://app.netlify.com
   - Sign in or create account

2. **Deploy the `dist` folder**
   - On the dashboard, find "Sites" section
   - Drag and drop the entire `dist` folder to the deploy area
   - Wait for upload to complete

3. **Your site will be live!**
   - Netlify will provide a URL like: `https://random-name-12345.netlify.app`

### Option 2: Connect Git Repository (Recommended)

1. **Push to GitHub/GitLab/Bitbucket**
   ```bash
   git add .
   git commit -m "Ready for deployment"
   git push origin main
   ```

2. **Connect to Netlify**
   - Go to https://app.netlify.com
   - Click "Add new site" → "Import an existing project"
   - Connect your Git repository
   - Netlify will auto-detect settings from `netlify.toml`

3. **Add Environment Variables** (IMPORTANT!)
   - Go to Site settings → Environment variables
   - Add these variables:
     - **Key:** `PUBLIC_SUPABASE_URL`
       **Value:** `https://tguopyxmlfxcalhfitob.supabase.co`
     - **Key:** `PUBLIC_SUPABASE_ANON_KEY`
       **Value:** Your Supabase anonymous key
   - Click "Save"

4. **Deploy**
   - Netlify will automatically build and deploy
   - Or click "Trigger deploy" → "Clear cache and deploy site"

## ⚙️ Environment Variables Required

**CRITICAL:** You MUST set these in Netlify Dashboard:

1. `PUBLIC_SUPABASE_URL` = `https://tguopyxmlfxcalhfitob.supabase.co`
2. `PUBLIC_SUPABASE_ANON_KEY` = Your Supabase anonymous key

**Without these, the site will not work properly!**

## 🔄 Post-Deployment Configuration

### 1. Update Supabase Redirect URLs

1. Go to Supabase Dashboard → Authentication → URL Configuration
2. Set **Site URL** to your Netlify URL:
   ```
   https://your-site-name.netlify.app
   ```
3. Add to **Redirect URLs**:
   ```
   https://your-site-name.netlify.app/auth/callback
   https://your-site-name.netlify.app/**
   ```

### 2. Update Google OAuth (if using)

1. Go to Google Cloud Console
2. Navigate to APIs & Services → Credentials
3. Click on your OAuth 2.0 Client ID
4. Add to **Authorized redirect URIs**:
   ```
   https://your-site-name.netlify.app/auth/callback
   ```

## ✅ Verification Checklist

After deployment, verify:
- [ ] Site loads at Netlify URL
- [ ] All pages are accessible
- [ ] Login/Signup works
- [ ] Products display correctly
- [ ] Cart functionality works
- [ ] Contact form works
- [ ] OAuth redirects work (if configured)

## 🐛 Troubleshooting

### Issue: Site shows blank page
- **Solution:** Check environment variables are set correctly
- **Solution:** Clear browser cache (Ctrl+Shift+R)

### Issue: API calls failing
- **Solution:** Verify `PUBLIC_SUPABASE_URL` and `PUBLIC_SUPABASE_ANON_KEY` are set
- **Solution:** Check browser console for errors

### Issue: OAuth not working
- **Solution:** Update Supabase redirect URLs with production URL
- **Solution:** Update Google OAuth redirect URIs

## 📝 Build Configuration

The project is configured with:
- **Framework:** Astro (static output)
- **Build Command:** `npm run build`
- **Publish Directory:** `dist`
- **Node Version:** 18

All settings are in `netlify.toml` and will be auto-detected.

## 🎉 Ready to Deploy!

Your build is complete and ready for Netlify deployment. The `dist/` folder contains everything needed.

**Remember:** Set environment variables in Netlify Dashboard before deploying!

