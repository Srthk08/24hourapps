# Google OAuth Fix - Step by Step Guide

## Current Error
"Unable to exchange external code" - This means Supabase can't redirect back to your app after Google authentication.

## Root Cause
The redirect URI configuration in Supabase Dashboard is missing or incorrect.

---

## ✅ STEP-BY-STEP FIX

### Step 1: Configure Supabase Site URL and Redirect URLs

1. **Go to Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your project: `tguopyxmlfxcalhfitob`

2. **Navigate to Authentication Settings**
   - Click on **"Authentication"** in the left sidebar
   - Click on **"URL Configuration"** (or "Settings" → "URL Configuration")

3. **Set Site URL (CRITICAL - This is often the issue!)**
   In the **"Site URL"** field, set:
   ```
   http://localhost:4321
   ```
   **For Production:**
   ```
   https://yourdomain.com
   ```
   ⚠️ **IMPORTANT**: The Site URL must match your app's origin EXACTLY (no trailing slash, no /auth/callback)

4. **Add Redirect URLs**
   In the **"Redirect URLs"** section, add these URLs (one per line):
   ```
   http://localhost:4321/auth/callback
   http://localhost:4321/**
   ```
   
   **For Production (when you deploy):**
   ```
   https://yourdomain.com/auth/callback
   https://yourdomain.com/**
   ```

5. **Click "Save"**
   
6. **VERIFY**: After saving, check that:
   - Site URL is: `http://localhost:4321` (no trailing slash)
   - Redirect URLs include: `http://localhost:4321/auth/callback`

---

### Step 2: Verify Google OAuth Provider Settings

1. **In Supabase Dashboard**
   - Go to **Authentication** → **Providers**
   - Find **"Google"** in the list
   - Click on it to edit

2. **Verify Settings:**
   - ✅ **Enabled**: Should be ON
   - ✅ **Client ID (for OAuth)**: Should match your Google Cloud Console Client ID
   - ✅ **Client Secret (for OAuth)**: Should match your Google Cloud Console Client Secret

3. **Save if you made any changes**

---

### Step 3: Verify Google Cloud Console Configuration

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com
   - Select your project

2. **Navigate to OAuth Credentials**
   - Go to **APIs & Services** → **Credentials**
   - Find your **OAuth 2.0 Client ID** (the one used in Supabase)

3. **Verify Authorized Redirect URIs**
   The redirect URI should be:
   ```
   https://tguopyxmlfxcalhfitob.supabase.co/auth/v1/callback
   ```
   
   ✅ **This is CORRECT** - Don't change this!

4. **Verify Authorized JavaScript Origins**
   Should include:
   ```
   https://tguopyxmlfxcalhfitob.supabase.co
   ```

---

### Step 4: Wait for Changes to Propagate

- After making changes in Supabase, wait **2-3 minutes** for them to take effect
- Clear your browser cache or try in incognito mode

---

### Step 5: Test the Flow

1. Go to: `http://localhost:4321/login`
2. Click **"Continue with Google"**
3. Complete Google authentication
4. You should be redirected back to your app

---

## 🔍 Troubleshooting

### If it still doesn't work:

1. **Check Browser Console**
   - Open Developer Tools (F12)
   - Look for error messages
   - Check the Network tab for failed requests

2. **Verify Supabase Redirect URLs**
   - Make sure `http://localhost:4321/auth/callback` is EXACTLY as shown
   - No trailing slashes
   - No extra spaces

3. **Check Supabase Logs**
   - Go to Supabase Dashboard → Logs → Auth Logs
   - Look for OAuth-related errors

4. **Verify Port Number**
   - Make sure your app is running on port 4321
   - If using a different port, update the redirect URL accordingly

---

## 📝 Important Notes

- **Google Cloud Console redirect URI** = Supabase's callback URL ✅ (This is correct)
- **Supabase redirect URLs** = Your app's callback URL ✅ (This needs to be configured)
- The flow is: Google → Supabase → Your App

---

## 🎯 Quick Checklist

- [ ] Added `http://localhost:4321/auth/callback` to Supabase Redirect URLs
- [ ] Google OAuth provider is enabled in Supabase
- [ ] Client ID and Secret match between Supabase and Google Cloud Console
- [ ] Google Cloud Console redirect URI is: `https://tguopyxmlfxcalhfitob.supabase.co/auth/v1/callback`
- [ ] Waited 2-3 minutes after making changes
- [ ] Tested the flow

---

## Still Not Working?

If you've completed all steps and it's still not working, check:

1. **Supabase Project Settings**
   - Go to Settings → API
   - Verify the project URL is correct

2. **Network Issues**
   - Try a different browser
   - Try incognito/private mode
   - Check if any firewall is blocking requests

3. **Code Issues**
   - Check browser console for JavaScript errors
   - Verify the callback page is accessible at `/auth/callback`

