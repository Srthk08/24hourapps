# Deployment Guide

Your project is ready for deployment! You have configuration files for both **Netlify** and **Vercel**.

## ✅ Build Status
- ✅ All duplicate key warnings fixed
- ✅ Build completed successfully
- ✅ 33 pages generated in `dist/` folder

## 🚀 Deployment Options

### Option 1: Deploy to Netlify (Recommended)

#### Method A: Using Netlify CLI
1. Install Netlify CLI (if not installed):
   ```bash
   npm install -g netlify-cli
   ```

2. Login to Netlify:
   ```bash
   netlify login
   ```

3. Initialize and deploy:
   ```bash
   netlify init
   netlify deploy --prod
   ```

#### Method B: Using Netlify Dashboard
1. Go to [netlify.com](https://netlify.com) and sign up/login
2. Click "Add new site" → "Import an existing project"
3. Connect your Git repository (GitHub/GitLab/Bitbucket)
4. Build settings (auto-detected from `netlify.toml`):
   - Build command: `npm run build`
   - Publish directory: `dist`
5. Add environment variables (if needed):
   - Go to Site settings → Environment variables
   - Add your Supabase keys:
     - `PUBLIC_SUPABASE_URL`
     - `PUBLIC_SUPABASE_ANON_KEY`
6. Click "Deploy site"

#### Method C: Drag & Drop
1. Build your project: `npm run build`
2. Go to [netlify.com](https://netlify.com)
3. Drag and drop the `dist` folder to the deploy area

---

### Option 2: Deploy to Vercel

#### Method A: Using Vercel CLI
1. Install Vercel CLI (if not installed):
   ```bash
   npm install -g vercel
   ```

2. Login to Vercel:
   ```bash
   vercel login
   ```

3. Deploy:
   ```bash
   vercel --prod
   ```

#### Method B: Using Vercel Dashboard
1. Go to [vercel.com](https://vercel.com) and sign up/login
2. Click "Add New Project"
3. Import your Git repository
4. Build settings (auto-detected from `vercel.json`):
   - Framework Preset: Astro
   - Build Command: `npm run build`
   - Output Directory: `dist`
5. Add environment variables:
   - Add your Supabase keys:
     - `PUBLIC_SUPABASE_URL`
     - `PUBLIC_SUPABASE_ANON_KEY`
6. Click "Deploy"

---

### Option 3: Deploy to Other Platforms

#### GitHub Pages
1. Install gh-pages:
   ```bash
   npm install --save-dev gh-pages
   ```

2. Add to `package.json`:
   ```json
   "scripts": {
     "deploy": "npm run build && gh-pages -d dist"
   }
   ```

3. Deploy:
   ```bash
   npm run deploy
   ```

#### Cloudflare Pages
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Pages → Create a project
3. Connect your Git repository
4. Build settings:
   - Build command: `npm run build`
   - Build output directory: `dist`
   - Node.js version: 18

#### AWS S3 + CloudFront
1. Build: `npm run build`
2. Upload `dist/` folder to S3 bucket
3. Configure CloudFront distribution
4. Set up custom domain

---

## 🔐 Environment Variables

Make sure to set these environment variables in your hosting platform:

### Required Variables:
- `PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anonymous key

### Optional Variables:
- `PUBLIC_SITE_URL` - Your site URL (for OAuth callbacks)

---

## 📝 Pre-Deployment Checklist

- [x] Build completed successfully
- [x] All warnings fixed
- [ ] Environment variables configured
- [ ] OAuth redirect URIs updated in Supabase
- [ ] Google OAuth redirect URI configured
- [ ] Test the deployed site

---

## 🔄 Post-Deployment Steps

1. **Update Supabase Redirect URLs:**
   - Go to Supabase Dashboard → Authentication → URL Configuration
   - Add your production URL to "Redirect URLs"
   - Example: `https://your-site.netlify.app/auth/callback`

2. **Update Google OAuth:**
   - Go to Google Cloud Console
   - Update authorized redirect URIs with your production URL
   - Example: `https://your-site.netlify.app/auth/callback`

3. **Test the deployment:**
   - Test login/signup
   - Test Google OAuth
   - Test product pages
   - Test cart functionality

---

## 🐛 Troubleshooting

### Build fails
- Check Node.js version (should be 18+)
- Run `npm install` to ensure dependencies are installed
- Check for TypeScript errors

### OAuth not working
- Verify redirect URIs in Supabase and Google Cloud Console
- Check environment variables are set correctly
- Ensure HTTPS is enabled (required for OAuth)

### Pages not loading
- Check redirect rules in `netlify.toml` or `vercel.json`
- Verify all routes are properly configured
- Check browser console for errors

---

## 📞 Need Help?

If you encounter any issues during deployment, check:
1. Build logs in your hosting platform
2. Browser console for client-side errors
3. Network tab for API errors
4. Supabase logs for database errors

---

## ✨ Quick Deploy Commands

### Netlify
```bash
npm run build
netlify deploy --prod
```

### Vercel
```bash
npm run build
vercel --prod
```

### Preview Locally
```bash
npm run build
npm run preview
```

---

**Your project is ready to deploy! 🚀**
