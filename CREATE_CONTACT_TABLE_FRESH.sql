-- ============================================
-- FRESH CONTACT SUBMISSIONS TABLE SETUP
-- ============================================
-- This script will:
-- 1. Drop the old contact_submissions table completely
-- 2. Create a fresh table with proper structure
-- 3. Set up RLS policies correctly from the start
-- 4. Grant all necessary permissions
-- 
-- Run this entire script in Supabase SQL Editor
-- ============================================

-- ============================================
-- STEP 1: DROP OLD TABLE AND ALL DEPENDENCIES
-- ============================================

-- Drop all policies first (if they exist)
DROP POLICY IF EXISTS "Public can insert contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Anyone can submit contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Allow public inserts" ON public.contact_submissions;
DROP POLICY IF EXISTS "Enable insert for all users" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can view all contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can update contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can delete contact submissions" ON public.contact_submissions;

-- Drop triggers if they exist
DROP TRIGGER IF EXISTS update_contact_submissions_updated_at ON public.contact_submissions;

-- Drop indexes if they exist
DROP INDEX IF EXISTS idx_contact_submissions_email;
DROP INDEX IF EXISTS idx_contact_submissions_status;
DROP INDEX IF EXISTS idx_contact_submissions_created_at;
DROP INDEX IF EXISTS idx_contact_submissions_project_type;
DROP INDEX IF EXISTS idx_contact_submissions_user_id;

-- Drop the table completely (CASCADE removes all dependencies)
DROP TABLE IF EXISTS public.contact_submissions CASCADE;

-- ============================================
-- STEP 2: CREATE FRESH TABLE WITH PROPER STRUCTURE
-- ============================================

CREATE TABLE public.contact_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,  -- Stores formatted phone number (e.g., "+919876543210")
    phone_country_code TEXT,  -- Optional: stores country code separately (e.g., "IN +91")
    phone_number TEXT,  -- Optional: stores phone number without country code
    company_name TEXT,  -- Optional
    project_type TEXT NOT NULL,  -- Required: e.g., "Android TV App", "Web Development", etc.
    project_details TEXT,  -- Stores the project details/message
    message TEXT,  -- Stores the message (same as project_details for compatibility)
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,  -- Optional: links to user if logged in
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- STEP 3: CREATE INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX idx_contact_submissions_email ON public.contact_submissions(email);
CREATE INDEX idx_contact_submissions_status ON public.contact_submissions(status);
CREATE INDEX idx_contact_submissions_created_at ON public.contact_submissions(created_at DESC);
CREATE INDEX idx_contact_submissions_project_type ON public.contact_submissions(project_type);
CREATE INDEX idx_contact_submissions_user_id ON public.contact_submissions(user_id);

-- ============================================
-- STEP 4: GRANT SCHEMA PERMISSIONS (BEFORE RLS)
-- ============================================

GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO public;

-- ============================================
-- STEP 5: GRANT TABLE PERMISSIONS (BEFORE RLS)
-- ============================================

-- Grant ALL permissions to all roles (we'll control access with RLS)
GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

-- Explicit INSERT grants (redundant but ensures it works)
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- ============================================
-- STEP 6: CREATE RLS POLICIES (BEFORE ENABLING RLS)
-- ============================================
-- IMPORTANT: Create policies BEFORE enabling RLS
-- This ensures they're ready when RLS is turned on

-- Policy 1: Allow anonymous users to INSERT (WITH CHECK (true) means allow all inserts)
CREATE POLICY "Allow anonymous inserts"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy 2: Allow authenticated users to INSERT
CREATE POLICY "Allow authenticated inserts"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy 3: Allow public role to INSERT (covers all cases)
CREATE POLICY "Public can insert contact forms"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Policy 4: Admins can SELECT (view all submissions)
CREATE POLICY "Admins can view all contact submissions"
    ON public.contact_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy 5: Admins can UPDATE (change status, etc.)
CREATE POLICY "Admins can update contact submissions"
    ON public.contact_submissions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy 6: Admins can DELETE
CREATE POLICY "Admins can delete contact submissions"
    ON public.contact_submissions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- STEP 7: ENABLE ROW LEVEL SECURITY (AFTER POLICIES)
-- ============================================
-- Now enable RLS - policies are already in place

ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 8: CREATE TRIGGER FOR UPDATED_AT
-- ============================================

-- First, ensure the update_updated_at_column function exists
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update updated_at timestamp
CREATE TRIGGER update_contact_submissions_updated_at
    BEFORE UPDATE ON public.contact_submissions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- STEP 9: VERIFICATION (Optional - uncomment to check)
-- ============================================

-- Verify table was created
-- SELECT table_name, column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'contact_submissions'
-- ORDER BY ordinal_position;

-- Verify policies were created
-- SELECT 
--     policyname,
--     roles,
--     cmd,
--     with_check
-- FROM pg_policies 
-- WHERE tablename = 'contact_submissions'
-- ORDER BY cmd, policyname;

-- ============================================
-- DONE! 
-- ============================================
-- The table is now created with proper RLS policies.
-- 
-- What this script does:
-- ✅ Drops the old table completely
-- ✅ Creates a fresh table with all required fields
-- ✅ Sets up RLS with INSERT policies for anon, authenticated, and public
-- ✅ Grants all necessary permissions
-- ✅ Creates indexes for performance
-- ✅ Sets up admin policies for SELECT, UPDATE, DELETE
-- ✅ Creates trigger for auto-updating updated_at
--
-- Now try submitting the contact form again - it should work!
-- ============================================

