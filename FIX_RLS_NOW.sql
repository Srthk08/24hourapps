-- ============================================
-- IMMEDIATE FIX - RUN THIS IN SUPABASE SQL EDITOR
-- ============================================
-- This script will fix the RLS policy error immediately
-- Copy and paste this entire script into Supabase SQL Editor and run it
-- ============================================

-- Step 1: Ensure table exists and has correct structure
-- (This will not fail if table already exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions'
    ) THEN
        RAISE EXCEPTION 'Table contact_submissions does not exist. Please run CONTACT_US_SETUP.sql first.';
    END IF;
END $$;

-- Step 2: Ensure RLS is enabled
ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- Step 3: Drop ALL existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public can insert contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Anyone can submit contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow public inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Enable insert for all users" ON public.contact_submissions;

-- Step 4: Grant schema usage permissions
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO public;

-- Step 5: Grant table permissions (ALL operations)
GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

-- Step 6: Create comprehensive INSERT policies for all roles
-- Policy 1: For anonymous users (most common case)
CREATE POLICY "Allow anonymous inserts"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy 2: For authenticated users
CREATE POLICY "Allow authenticated inserts"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy 3: For public role (covers all cases)
CREATE POLICY "Public can insert contact forms"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Step 7: Explicit INSERT grants (redundant but ensures it works)
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- Step 8: Verify policies were created (uncomment to check)
-- SELECT 
--     schemaname,
--     tablename,
--     policyname,
--     permissive,
--     roles,
--     cmd,
--     qual,
--     with_check
-- FROM pg_policies 
-- WHERE tablename = 'contact_submissions' AND cmd = 'INSERT'
-- ORDER BY policyname;

-- ============================================
-- DONE! The RLS policies are now properly configured.
-- 
-- What this script does:
-- 1. Ensures the table exists
-- 2. Enables RLS on the table
-- 3. Drops all conflicting policies
-- 4. Grants schema and table permissions
-- 5. Creates INSERT policies for anon, authenticated, and public roles
-- 6. Grants explicit INSERT permissions
--
-- Now try submitting the contact form again.
-- The form should work for both logged-in and anonymous users.
-- ============================================

