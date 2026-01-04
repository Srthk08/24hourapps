-- ============================================
-- DIAGNOSE AND FIX - This will find the problem
-- ============================================
-- Run this ENTIRE script in Supabase SQL Editor
-- ============================================

-- ============================================
-- STEP 1: Check current state
-- ============================================

DO $$
DECLARE
    rls_enabled BOOLEAN;
    policy_count INTEGER;
    anon_policy BOOLEAN;
BEGIN
    -- Check RLS
    SELECT relforcerowsecurity INTO rls_enabled
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'contact_submissions' 
    AND n.nspname = 'public';
    
    -- Count policies
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    
    -- Check anon policy
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND 'anon' = ANY(roles)
    ) INTO anon_policy;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'CURRENT STATE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RLS Enabled: %', CASE WHEN rls_enabled THEN 'YES' ELSE 'NO' END;
    RAISE NOTICE 'INSERT Policies: %', policy_count;
    RAISE NOTICE 'Anon has policy: %', CASE WHEN anon_policy THEN 'YES' ELSE 'NO' END;
    RAISE NOTICE '========================================';
END $$;

-- ============================================
-- STEP 2: COMPLETE RESET AND FIX
-- ============================================

-- Disable RLS
ALTER TABLE IF EXISTS public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- Drop ALL policies
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions CASCADE', r.policyname);
    END LOOP;
END $$;

-- Ensure table exists
CREATE TABLE IF NOT EXISTS public.contact_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    phone_country_code TEXT,
    phone_number TEXT,
    company_name TEXT,
    project_type TEXT,
    project_details TEXT,
    message TEXT,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Make project_type nullable
DO $$ 
BEGIN
    ALTER TABLE public.contact_submissions ALTER COLUMN project_type DROP NOT NULL;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- ============================================
-- STEP 3: GRANT PERMISSIONS
-- ============================================

-- Revoke all first
REVOKE ALL ON public.contact_submissions FROM anon CASCADE;
REVOKE ALL ON public.contact_submissions FROM authenticated CASCADE;
REVOKE ALL ON public.contact_submissions FROM public CASCADE;

-- Grant schema
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO public;

-- Grant table permissions
GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

GRANT SELECT ON public.contact_submissions TO anon;
GRANT SELECT ON public.contact_submissions TO authenticated;
GRANT SELECT ON public.contact_submissions TO public;

-- ============================================
-- STEP 4: CREATE POLICIES - SIMPLEST POSSIBLE
-- ============================================

-- CRITICAL: Create policy for anon with simplest possible check
CREATE POLICY "anon_insert_contact_submissions"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Also for authenticated
CREATE POLICY "authenticated_insert_contact_submissions"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Also for public
CREATE POLICY "public_insert_contact_submissions"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- ============================================
-- STEP 5: ENABLE RLS
-- ============================================

ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 6: VERIFY
-- ============================================

DO $$
DECLARE
    rls_enabled BOOLEAN;
    policy_count INTEGER;
    anon_policy BOOLEAN;
BEGIN
    SELECT relforcerowsecurity INTO rls_enabled
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'contact_submissions' 
    AND n.nspname = 'public';
    
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND 'anon' = ANY(roles)
    ) INTO anon_policy;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'AFTER FIX';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RLS Enabled: %', CASE WHEN rls_enabled THEN 'YES ✅' ELSE 'NO ❌' END;
    RAISE NOTICE 'INSERT Policies: %', policy_count;
    RAISE NOTICE 'Anon has policy: %', CASE WHEN anon_policy THEN 'YES ✅' ELSE 'NO ❌' END;
    RAISE NOTICE '========================================';
    
    IF rls_enabled AND policy_count >= 1 AND anon_policy THEN
        RAISE NOTICE '✅ Setup looks correct!';
    ELSE
        RAISE NOTICE '❌ Setup incomplete!';
    END IF;
END $$;

-- ============================================
-- STEP 7: TEST INSERT (This will show if it works)
-- ============================================

-- Try to insert as anon (this simulates your form)
DO $$
BEGIN
    -- Switch to anon role
    PERFORM set_config('role', 'anon', false);
    
    -- Try insert
    INSERT INTO public.contact_submissions (
        first_name, 
        last_name, 
        email, 
        project_type, 
        message
    ) VALUES (
        'Diagnostic Test', 
        'User', 
        'diagnostic@test.com', 
        'Web Development', 
        'This is a diagnostic test'
    );
    
    -- Switch back
    PERFORM set_config('role', 'postgres', false);
    
    RAISE NOTICE '✅✅✅ TEST INSERT SUCCEEDED!';
    RAISE NOTICE '✅ RLS policies are working correctly!';
    RAISE NOTICE '✅ If your form still fails, the issue is NOT with RLS.';
    RAISE NOTICE '✅ Check: Browser cache, Supabase client, or network issues.';
    
EXCEPTION WHEN OTHERS THEN
    PERFORM set_config('role', 'postgres', false);
    RAISE NOTICE '❌❌❌ TEST INSERT FAILED!';
    RAISE NOTICE '❌ Error: %', SQLERRM;
    RAISE NOTICE '❌ This means RLS policies are NOT working.';
    RAISE NOTICE '❌ The error code is: %', SQLSTATE;
END $$;

-- Check if test insert was successful
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.contact_submissions 
            WHERE email = 'diagnostic@test.com'
        ) THEN '✅ Test insert found in database - RLS is working!'
        ELSE '❌ Test insert NOT found - RLS is blocking it'
    END as test_result;

-- ============================================
-- DONE!
-- ============================================
-- This script:
-- 1. Shows current state
-- 2. Completely resets everything
-- 3. Creates simplest possible policies
-- 4. Tests if inserts work
-- 5. Shows you the result
--
-- If the test insert succeeds but your form doesn't work,
-- the issue is NOT with RLS - it's with your code or browser.
-- ============================================






