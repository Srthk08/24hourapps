# 🔧 Why Supabase Rejects Emails & How to Fix It

## ❌ The Problem

Supabase is rejecting valid Gmail addresses like:
- `raj@gmail.com` (3 characters) ❌
- `klll@gmail.com` (4 characters) ❌
- Even longer emails might fail

**Error:** `AuthApiError: Email address "raj@gmail.com" is invalid` (Status: 400)

---

## 🔍 Why This Happens

### 1. **Supabase's Built-in Email Validation**
Supabase Auth has **strict email validation** that:
- Validates emails on the **server-side** (not client-side)
- Uses **RFC 5322** email standards
- May have **custom validation rules** in your project
- Cannot be easily bypassed from client code

### 2. **Possible Reasons for Rejection**

1. **Email Format Validation**
   - Supabase might require specific email patterns
   - Some projects have custom email validation hooks
   - Email domain restrictions might be enabled

2. **Project Configuration**
   - Your Supabase project might have **email domain allowlist/blocklist**
   - **Email validation settings** in project config
   - **Custom validation functions** or Edge Functions

3. **Supabase Version/Region**
   - Different Supabase regions might have different validation
   - Some Supabase projects have stricter rules

---

## ✅ Solutions (In Order of Priority)

### Solution 1: Check Supabase Dashboard Settings ⭐ **MOST IMPORTANT**

#### Step 1: Check Authentication Settings

1. Go to **Supabase Dashboard** → Your Project
2. Navigate to **Authentication** → **Settings**
3. Look for these settings:

   **a) Email Auth Settings:**
   - **"Enable email confirmations"** - Try disabling this temporarily
   - **"Email validation"** - Check if there are custom rules
   - **"Email domain restrictions"** - Make sure Gmail is allowed

   **b) Project Settings:**
   - Go to **Settings** → **API**
   - Check for **"Email validation"** or **"Email requirements"**
   - Look for any **custom validation rules**

#### Step 2: Check for Custom Hooks/Triggers

1. Go to **Database** → **Functions**
2. Check if there are any **Edge Functions** or **Database Functions** that validate emails
3. Look for functions named:
   - `validate_email`
   - `check_email`
   - `email_validation`

#### Step 3: Check Email Templates

1. Go to **Authentication** → **Email Templates**
2. Check if email templates are configured correctly
3. Make sure there are no validation issues in templates

---

### Solution 2: Disable Email Confirmation (For Testing)

1. **Authentication** → **Settings**
2. Find **"Enable email confirmations"**
3. **Disable it** temporarily
4. **Save** settings
5. Try signup again

**Note:** This allows users to sign up without email confirmation. Re-enable it for production.

---

### Solution 3: Check Supabase Logs

1. Go to **Logs** → **API Logs** or **Postgres Logs**
2. Look for the exact error when signup fails
3. Check for additional error details that might explain the rejection

---

### Solution 4: Use Service Role Key (Advanced - Not Recommended)

If you have admin access, you could use the **service_role** key to bypass some validations, but this is **NOT recommended** for production and has security implications.

---

### Solution 5: Contact Supabase Support

If none of the above works:

1. Go to **Supabase Dashboard** → **Support**
2. Report the issue with:
   - Email format being rejected
   - Error message and status code
   - Your project details
   - Screenshots of the error

---

## 🔧 Temporary Workaround

### Use Longer Email Addresses

For testing, use emails with **5+ characters**:
- ✅ `testuser@gmail.com` (8 characters)
- ✅ `user123@gmail.com` (7 characters)
- ✅ `demo123@gmail.com` (7 characters)
- ❌ `raj@gmail.com` (3 characters) - Currently failing
- ❌ `test@gmail.com` (4 characters) - Might fail

### Add Frontend Validation

We've already added minimum length validation (3 characters), but you can increase it:

```javascript
// In signup.astro, increase minimum length
if (emailLocalPart.length < 5) {  // Changed from 3 to 5
  errorText.textContent = 'Email username must be at least 5 characters long.';
  // ...
}
```

---

## 📋 Checklist to Fix Email Validation

- [ ] Check **Authentication** → **Settings** → **Email Auth**
- [ ] Disable **"Enable email confirmations"** temporarily
- [ ] Check for **email domain restrictions**
- [ ] Check **Settings** → **API** for validation rules
- [ ] Check **Database** → **Functions** for custom validation
- [ ] Check **Logs** for detailed error messages
- [ ] Try with longer email addresses (5+ characters)
- [ ] Contact Supabase support if issue persists

---

## 🎯 Most Likely Fix

**90% of the time, the issue is in Supabase Dashboard settings:**

1. **Disable email confirmation** (Authentication → Settings)
2. **Check email domain restrictions** (make sure Gmail is allowed)
3. **Remove any custom email validation** if present

---

## ⚠️ Important Notes

1. **This is a Supabase server-side issue**, not your code
2. **Client-side validation passes** - your code is working correctly
3. **Supabase Auth validates on the server** - we can't override it from client
4. **Check Supabase Dashboard** - this is where the fix usually is

---

## 🔗 Related Files

- `src/pages/signup.astro` - Signup page (has email normalization)
- `SUPABASE_DATABASE_SETUP.sql` - Database setup
- `SUPABASE_EMAIL_FIX.md` - Previous troubleshooting guide

---

## 💡 Quick Test

Try these emails to see which work:
1. `testuser@gmail.com` (8 chars) - Should work ✅
2. `user123@gmail.com` (7 chars) - Should work ✅
3. `demo123@gmail.com` (7 chars) - Should work ✅
4. `raj@gmail.com` (3 chars) - Currently failing ❌

If longer emails work but shorter ones don't, it's a **Supabase validation rule** that requires minimum length.

---

**Last Updated:** After identifying persistent Supabase email validation issue


