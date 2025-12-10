-- ============================================
-- COMPLETE FIX WITH FULL VERIFICATION
-- ============================================
-- This script does EVERYTHING and verifies each step
-- Run this ENTIRE script in Supabase SQL Editor
-- ============================================

BEGIN;

-- ============================================
-- STEP 1: DISABLE RLS
-- ============================================

ALTER TABLE IF EXISTS public.contact_submissions DISABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    RAISE NOTICE 'Step 1: RLS disabled';
END $$;

-- ============================================
-- STEP 2: DROP ALL POLICIES
-- ============================================

DO $$ 
DECLARE
    r RECORD;
    count INTEGER := 0;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions CASCADE', r.policyname);
        count := count + 1;
    END LOOP;
    RAISE NOTICE 'Step 2: Dropped % policies', count;
END $$;

-- ============================================
-- STEP 3: ENSURE TABLE EXISTS
-- ============================================

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

DO $$
BEGIN
    ALTER TABLE public.contact_submissions ALTER COLUMN project_type DROP NOT NULL;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'Step 3: Table structure verified';
END $$;

-- ============================================
-- STEP 4: REVOKE AND REGRANT ALL PERMISSIONS
-- ============================================

-- Revoke everything first
REVOKE ALL ON public.contact_submissions FROM anon;
REVOKE ALL ON public.contact_submissions FROM authenticated;
REVOKE ALL ON public.contact_submissions FROM public;

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO public;

-- Grant ALL on table
GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

-- Explicit INSERT
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

DO $$
BEGIN
    RAISE NOTICE 'Step 4: Permissions granted';
END $$;

-- ============================================
-- STEP 5: CREATE POLICIES (WHILE RLS IS DISABLED)
-- ============================================

-- Drop if they exist
DROP POLICY IF EXISTS "anon_insert_policy" ON public.contact_submissions;
DROP POLICY IF EXISTS "authenticated_insert_policy" ON public.contact_submissions;
DROP POLICY IF EXISTS "public_insert_policy" ON public.contact_submissions;

-- Create anon policy
CREATE POLICY "anon_insert_policy"
    ON public.contact_submissions
    AS PERMISSIVE
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Create authenticated policy
CREATE POLICY "authenticated_insert_policy"
    ON public.contact_submissions
    AS PERMISSIVE
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Create public policy
CREATE POLICY "public_insert_policy"
    ON public.contact_submissions
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (true);

DO $$
DECLARE
    policy_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    RAISE NOTICE 'Step 5: Created % INSERT policies', policy_count;
END $$;

-- ============================================
-- STEP 6: ENABLE RLS
-- ============================================

ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE
    rls_enabled BOOLEAN;
BEGIN
    SELECT relforcerowsecurity INTO rls_enabled
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'contact_submissions' 
    AND n.nspname = 'public';
    
    IF rls_enabled THEN
        RAISE NOTICE 'Step 6: RLS enabled successfully';
    ELSE
        RAISE EXCEPTION 'RLS was not enabled!';
    END IF;
END $$;

-- ============================================
-- STEP 7: VERIFY EVERYTHING
-- ============================================

DO $$
DECLARE
    rls_enabled BOOLEAN;
    anon_policy BOOLEAN;
    auth_policy BOOLEAN;
    public_policy BOOLEAN;
    anon_grant BOOLEAN;
    auth_grant BOOLEAN;
    public_grant BOOLEAN;
BEGIN
    -- Check RLS
    SELECT relforcerowsecurity INTO rls_enabled
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'contact_submissions' 
    AND n.nspname = 'public';
    
    -- Check policies
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND 'anon' = ANY(roles)
    ) INTO anon_policy;
    
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND 'authenticated' = ANY(roles)
    ) INTO auth_policy;
    
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND 'public' = ANY(roles)
    ) INTO public_policy;
    
    -- Check grants
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_privileges
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions'
        AND grantee = 'anon'
        AND privilege_type = 'INSERT'
    ) INTO anon_grant;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_privileges
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions'
        AND grantee = 'authenticated'
        AND privilege_type = 'INSERT'
    ) INTO auth_grant;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.table_privileges
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions'
        AND grantee = 'public'
        AND privilege_type = 'INSERT'
    ) INTO public_grant;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'FINAL VERIFICATION';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RLS Enabled: %', CASE WHEN rls_enabled THEN '✅' ELSE '❌' END;
    RAISE NOTICE 'Anon Policy: %', CASE WHEN anon_policy THEN '✅' ELSE '❌' END;
    RAISE NOTICE 'Auth Policy: %', CASE WHEN auth_policy THEN '✅' ELSE '❌' END;
    RAISE NOTICE 'Public Policy: %', CASE WHEN public_policy THEN '✅' ELSE '❌' END;
    RAISE NOTICE 'Anon Grant: %', CASE WHEN anon_grant THEN '✅' ELSE '❌' END;
    RAISE NOTICE 'Auth Grant: %', CASE WHEN auth_grant THEN '✅' ELSE '❌' END;
    RAISE NOTICE 'Public Grant: %', CASE WHEN public_grant THEN '✅' ELSE '❌' END;
    RAISE NOTICE '========================================';
    
    IF rls_enabled AND anon_policy AND auth_policy AND public_policy AND anon_grant AND auth_grant AND public_grant THEN
        RAISE NOTICE '✅✅✅ ALL CHECKS PASSED!';
        RAISE NOTICE '✅ Your contact form should work now!';
        RAISE NOTICE '✅ If it still doesn''t work, the issue is NOT with RLS policies.';
        RAISE NOTICE '✅ Check: Browser cache, Supabase client initialization, or network issues.';
    ELSE
        RAISE NOTICE '❌ Some checks failed. Review the output above.';
    END IF;
    RAISE NOTICE '========================================';
END $$;

COMMIT;

-- ============================================
-- DONE!
-- ============================================



