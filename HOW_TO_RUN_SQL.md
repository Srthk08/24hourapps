# 📋 How to Run SQL Setup in Supabase

## ⚠️ Important: Which File to Run

- ❌ **DO NOT run** `SUPABASE_EMAIL_FIX.md` - This is a documentation file, not SQL
- ✅ **RUN** `SUPABASE_DATABASE_SETUP.sql` - This is the SQL file you need

---

## 🚀 Step-by-Step: Run SQL in Supabase

### Step 1: Open Supabase Dashboard

1. Go to **https://supabase.com/dashboard**
2. **Sign in** to your account
3. **Select your project** (the one with URL: `tguopyxmlfxcalhfitob.supabase.co`)

### Step 2: Open SQL Editor

1. In the left sidebar, click **SQL Editor**
2. Click **New Query** button (top right)

### Step 3: Open the SQL File

1. In your project, open: `SUPABASE_DATABASE_SETUP.sql`
2. **Select ALL** the content (Ctrl+A)
3. **Copy** it (Ctrl+C)

### Step 4: Paste and Run SQL

1. **Paste** the SQL into the Supabase SQL Editor
2. **Review** the SQL to make sure it looks correct
3. Click **Run** button (or press `Ctrl+Enter`)

### Step 5: Verify Tables Were Created

After running, verify the tables exist by running this query:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'user_activity_log');
```

You should see:
- `profiles`
- `user_activity_log`

---

## 📝 What the SQL Does

The `SUPABASE_DATABASE_SETUP.sql` file will:

1. ✅ Create `profiles` table - Stores user account information
2. ✅ Create `user_activity_log` table - Logs user activities
3. ✅ Set up Row Level Security (RLS) policies
4. ✅ Create trigger to auto-create profile on signup
5. ✅ Create helper functions
6. ✅ Set up proper permissions

---

## ⚠️ Common Issues

### Issue 1: "relation already exists"
**Solution:** The tables already exist. You can either:
- Drop existing tables first (be careful!)
- Or skip the CREATE TABLE statements

### Issue 2: "permission denied"
**Solution:** 
- Make sure you're logged in as project owner
- Or use the service role key

### Issue 3: "function already exists"
**Solution:** The functions already exist. The SQL uses `CREATE OR REPLACE` so it should update them.

---

## ✅ After Running SQL

1. **Test signup** - Try creating an account
2. **Check console** - Look for any errors
3. **Verify profile creation** - Check if profile was created in `profiles` table

---

## 🔍 Quick Verification Query

Run this to check if everything is set up correctly:

```sql
-- Check if profiles table exists and has correct structure
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if trigger exists
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND event_object_table = 'users';
```

---

## 📋 Files Reference

- ✅ **SUPABASE_DATABASE_SETUP.sql** - SQL file to run (THIS ONE!)
- 📖 **SUPABASE_EMAIL_FIX.md** - Documentation/guide (NOT SQL)
- 📖 **ACCOUNT_CREATION_TROUBLESHOOTING.md** - Troubleshooting guide

---

## 🎯 Summary

1. Open `SUPABASE_DATABASE_SETUP.sql` (NOT the .md file)
2. Copy ALL the SQL code
3. Paste into Supabase SQL Editor
4. Click Run
5. Verify tables were created
6. Test signup

---

**Remember:** Run the `.sql` file, not the `.md` file!


