-- ============================================
-- COMPREHENSIVE FIX FOR CONTACT FORM RLS POLICY ERROR
-- ============================================
-- Run this script in Supabase SQL Editor to fix RLS issues
-- This creates multiple policies to ensure inserts work for all user types
-- ============================================

-- Step 1: Drop ALL existing policies on contact_submissions
DROP POLICY IF EXISTS "Public can insert contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Anyone can submit contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can view all contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can update contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can delete contact submissions" ON public.contact_submissions;

-- Step 2: Create separate policies for anonymous and authenticated users
-- This ensures maximum compatibility

-- Policy for anonymous users (not logged in)
CREATE POLICY "Allow anonymous inserts"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy for authenticated users (logged in - any role)
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
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- Step 4: Recreate admin policies for viewing/updating/deleting
CREATE POLICY "Admins can view all contact submissions"
    ON public.contact_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update contact submissions"
    ON public.contact_submissions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can delete contact submissions"
    ON public.contact_submissions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Step 5: Verify policies were created
-- Run this query to check all policies:
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
-- FROM pg_policies 
-- WHERE tablename = 'contact_submissions'
-- ORDER BY policyname;

-- ============================================
-- IMPORTANT: After running this script:
-- 1. Try submitting the contact form again
-- 2. If it still fails, check the Supabase dashboard:
--    - Go to Authentication > Policies
--    - Find contact_submissions table
--    - Verify the INSERT policies are listed
-- 3. Make sure RLS is enabled (it should be)
-- ============================================





