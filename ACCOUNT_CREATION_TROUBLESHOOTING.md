# 🔧 Account Creation Troubleshooting Guide

## ❌ Problem: "Email address 'lk@gmail.com' is invalid"

### Possible Causes:

1. **HTML5 Pattern Validation Issue**
   - The HTML5 `pattern` attribute might be too strict
   - Fixed: Updated pattern to `^[a-zA-Z0-9][a-zA-Z0-9._-]*@gmail\.com$`

2. **Missing Database Tables**
   - The `profiles` table might not exist in Supabase
   - **Solution:** Run the SQL queries in `SUPABASE_DATABASE_SETUP.sql`

3. **Supabase Email Validation**
   - Supabase might have email validation settings enabled
   - Check Supabase Dashboard → Authentication → Settings

4. **RLS (Row Level Security) Policies**
   - RLS policies might be blocking profile creation
   - **Solution:** The SQL file includes proper RLS policies

---

## ✅ Solution Steps:

### Step 1: Run Database Setup SQL

1. Go to your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `SUPABASE_DATABASE_SETUP.sql`
4. Click **Run** to execute all queries

### Step 2: Check Supabase Auth Settings

1. Go to **Authentication** → **Settings**
2. Check **Email Auth** settings:
   - **Enable email confirmations:** Can be disabled for testing
   - **Email template:** Should be configured

### Step 3: Verify Tables Are Created

Run this query in SQL Editor:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'user_activity_log');
```

### Step 4: Test Profile Creation

Run this query to check if profiles table is accessible:
```sql
SELECT * FROM public.profiles LIMIT 1;
```

---

## 🔍 Debugging Steps:

### 1. Check Browser Console

Open browser DevTools (F12) and check:
- JavaScript errors
- Network requests to Supabase
- Console logs from signup process

### 2. Check Supabase Logs

1. Go to Supabase Dashboard
2. Navigate to **Logs** → **Postgres Logs**
3. Look for errors related to:
   - `profiles` table
   - `INSERT` operations
   - Permission errors

### 3. Test Email Validation

The email `lk@gmail.com` should be valid. Test with:
- `test@gmail.com` ✅
- `user123@gmail.com` ✅
- `user.name@gmail.com` ✅
- `user_name@gmail.com` ✅
- `user-name@gmail.com` ✅

**Invalid formats:**
- `.user@gmail.com` ❌ (starts with dot)
- `user@gmail.com` ✅ (but might fail if too short)
- `user@example.com` ❌ (not Gmail)

---

## 📋 Database Tables Required:

### 1. `profiles` Table
Stores user profile information:
- `id` (UUID) - Links to auth.users
- `email` (TEXT) - User email
- `full_name` (TEXT) - User's full name
- `phone` (TEXT) - Phone number
- `company_name` (TEXT) - Company name
- `role` (TEXT) - User role (customer, admin, etc.)
- `status` (TEXT) - Account status
- And more...

### 2. `user_activity_log` Table
Logs user activities:
- `user_id` (UUID) - Links to profiles
- `action` (TEXT) - Action type (login, signup, etc.)
- `details` (JSONB) - Additional details
- `created_at` (TIMESTAMPTZ) - Timestamp

---

## 🚀 Quick Fix Commands:

### If Profile Creation Fails:

1. **Check if user exists in auth.users:**
```sql
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'lk@gmail.com';
```

2. **Manually create profile (if needed):**
```sql
INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    status,
    username,
    created_at,
    updated_at
)
VALUES (
    'USER_ID_FROM_AUTH_USERS',
    'lk@gmail.com',
    'User Name',
    'customer',
    'pending_verification',
    'lk',
    NOW(),
    NOW()
);
```

3. **Check RLS policies:**
```sql
SELECT * FROM pg_policies 
WHERE tablename = 'profiles';
```

---

## ⚠️ Common Issues:

### Issue 1: "relation 'profiles' does not exist"
**Solution:** Run the SQL setup file to create the table

### Issue 2: "permission denied for table profiles"
**Solution:** Check RLS policies and grants in the SQL file

### Issue 3: "duplicate key value violates unique constraint"
**Solution:** User already exists. Check if profile was created:
```sql
SELECT * FROM public.profiles WHERE email = 'lk@gmail.com';
```

### Issue 4: Email validation fails in browser
**Solution:** 
- Clear browser cache
- Check HTML5 pattern attribute
- Try a different email format

---

## 📝 Testing Checklist:

- [ ] Database tables created (`profiles`, `user_activity_log`)
- [ ] RLS policies are set correctly
- [ ] Trigger function `handle_new_user()` is created
- [ ] Email validation works in browser
- [ ] Supabase Auth is configured correctly
- [ ] Browser console shows no errors
- [ ] Network requests to Supabase succeed

---

## 🔗 Related Files:

- `SUPABASE_DATABASE_SETUP.sql` - Database setup queries
- `src/pages/signup.astro` - Signup page code
- `src/lib/supabase.ts` - Supabase client configuration

---

**Last Updated:** After fixing email validation pattern

