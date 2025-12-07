-- ============================================
-- QUICK FIX FOR CONTACT FORM RLS POLICY ERROR
-- ============================================
-- Run this script in Supabase SQL Editor if you're getting:
-- "new row violates row-level security policy for table 'contact_submissions'"
-- ============================================

-- Step 1: Drop existing INSERT policies
DROP POLICY IF EXISTS "Public can insert contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Anyone can submit contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.contact_submissions;

-- Step 2: Create multiple INSERT policies to ensure it works for all user types
-- Policy for anonymous users
CREATE POLICY "Allow anonymous inserts"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy for authenticated users
CREATE POLICY "Allow authenticated inserts"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy for public (covers all cases)
CREATE POLICY "Public can insert contact forms"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Step 3: Ensure proper grants are in place
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- Step 4: Verify the policy was created
-- Run this query to check:
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies 
-- WHERE tablename = 'contact_submissions';

-- ============================================
-- After running this, try submitting the contact form again
-- ============================================

