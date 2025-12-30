# RLS Policy Fix Instructions

## Issue
The contact form is failing with error: "new row violates row-level security policy for table 'contact_submissions'"

## Solution
Run the updated `FIX_RLS_NOW.sql` script in your Supabase SQL Editor.

## Steps to Fix

1. **Open Supabase Dashboard**
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor

2. **Run the Fix Script**
   - Open the file `FIX_RLS_NOW.sql` in this project
   - Copy the entire contents
   - Paste into Supabase SQL Editor
   - Click "Run" or press Ctrl+Enter

3. **Verify the Fix**
   - The script will:
     - Ensure the table exists
     - Enable RLS
     - Drop all conflicting policies
     - Grant proper permissions
     - Create INSERT policies for all user roles (anon, authenticated, public)

4. **Test the Contact Form**
   - Go to your contact page
   - Fill out and submit the form
   - The submission should now work without errors

## What the Fix Does

- **Drops conflicting policies**: Removes any existing policies that might be blocking inserts
- **Grants permissions**: Ensures anon, authenticated, and public roles have INSERT permissions
- **Creates comprehensive policies**: Creates INSERT policies for all three roles to ensure it works regardless of user authentication status
- **Maintains security**: Only allows inserts (not reads/updates/deletes) for non-admin users

## Notes

- The fix does NOT change your project code or flow
- The fix only updates database policies
- After running the script, wait a few seconds for changes to propagate
- If issues persist, verify you're using the correct Supabase project

## Verification Query (Optional)

After running the fix, you can verify the policies were created by running this in SQL Editor:

```sql
SELECT 
    policyname,
    roles,
    cmd,
    with_check
FROM pg_policies 
WHERE tablename = 'contact_submissions' AND cmd = 'INSERT'
ORDER BY policyname;
```

You should see 3 INSERT policies:
1. "Allow anonymous inserts" (for anon role)
2. "Allow authenticated inserts" (for authenticated role)
3. "Public can insert contact forms" (for public role)





