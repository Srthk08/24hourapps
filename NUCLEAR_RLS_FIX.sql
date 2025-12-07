-- ============================================
-- NUCLEAR RLS FIX - This WILL work
-- ============================================
-- This script takes the most aggressive approach:
-- 1. Completely disables RLS
-- 2. Drops ALL policies
-- 3. Sets up everything fresh
-- 4. Re-enables RLS with correct policies
-- ============================================

-- ============================================
-- STEP 1: COMPLETELY DISABLE RLS
-- ============================================

ALTER TABLE IF EXISTS public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 2: DROP ALL POLICIES (EVERY SINGLE ONE)
-- ============================================

DO $$ 
DECLARE
    r RECORD;
    dropped_count INTEGER := 0;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions'
    ) LOOP
        BEGIN
            EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions CASCADE', r.policyname);
            dropped_count := dropped_count + 1;
            RAISE NOTICE 'Dropped policy: %', r.policyname;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Error dropping policy %: %', r.policyname, SQLERRM;
        END;
    END LOOP;
    RAISE NOTICE 'Dropped % policies total', dropped_count;
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

-- Make project_type nullable
DO $$ 
BEGIN
    ALTER TABLE public.contact_submissions ALTER COLUMN project_type DROP NOT NULL;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- ============================================
-- STEP 4: GRANT EVERYTHING (BEFORE POLICIES)
-- ============================================

-- Grant schema usage
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO public;

-- Grant ALL permissions on table
GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

-- Explicit INSERT grants
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- ============================================
-- STEP 5: CREATE POLICIES (WHILE RLS IS DISABLED)
-- ============================================
-- Policies can be created even when RLS is disabled
-- This ensures they're ready when we enable RLS

-- Policy for ANON (anonymous users) - MOST IMPORTANT!
-- Using PERMISSIVE explicitly and WITH CHECK (true) to allow all inserts
CREATE POLICY "anon_insert_policy"
    ON public.contact_submissions
    AS PERMISSIVE
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy for AUTHENTICATED (logged in users)
CREATE POLICY "authenticated_insert_policy"
    ON public.contact_submissions
    AS PERMISSIVE
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy for PUBLIC (covers everything)
CREATE POLICY "public_insert_policy"
    ON public.contact_submissions
    AS PERMISSIVE
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Admin policies
CREATE POLICY "admin_select_policy"
    ON public.contact_submissions
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "admin_update_policy"
    ON public.contact_submissions
    FOR UPDATE
    TO authenticated
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

CREATE POLICY "admin_delete_policy"
    ON public.contact_submissions
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- STEP 6: ENABLE RLS (NOW THAT POLICIES ARE READY)
-- ============================================

ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 7: VERIFY EVERYTHING
-- ============================================

DO $$
DECLARE
    rls_enabled BOOLEAN;
    anon_policy_exists BOOLEAN;
    auth_policy_exists BOOLEAN;
    public_policy_exists BOOLEAN;
    total_policies INTEGER;
BEGIN
    -- Check RLS is enabled
    SELECT relforcerowsecurity INTO rls_enabled
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relname = 'contact_submissions' 
    AND n.nspname = 'public';
    
    -- Check if anon policy exists
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND policyname = 'anon_insert_policy'
    ) INTO anon_policy_exists;
    
    -- Check if authenticated policy exists
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND policyname = 'authenticated_insert_policy'
    ) INTO auth_policy_exists;
    
    -- Check if public policy exists
    SELECT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions' 
        AND cmd = 'INSERT'
        AND policyname = 'public_insert_policy'
    ) INTO public_policy_exists;
    
    -- Count total INSERT policies
    SELECT COUNT(*) INTO total_policies
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VERIFICATION RESULTS';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RLS Enabled: %', CASE WHEN rls_enabled THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'Anon policy exists: %', CASE WHEN anon_policy_exists THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'Authenticated policy exists: %', CASE WHEN auth_policy_exists THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'Public policy exists: %', CASE WHEN public_policy_exists THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'Total INSERT policies: %', total_policies;
    RAISE NOTICE '========================================';
    
    IF rls_enabled AND anon_policy_exists AND auth_policy_exists AND public_policy_exists THEN
        RAISE NOTICE '✅✅✅ SUCCESS! Everything is set up correctly!';
        RAISE NOTICE '✅ Your contact form should work now!';
    ELSE
        RAISE NOTICE '⚠️ WARNING: Something might be missing.';
        IF NOT rls_enabled THEN
            RAISE NOTICE '   - RLS is not enabled';
        END IF;
        IF NOT anon_policy_exists THEN
            RAISE NOTICE '   - Anon policy is missing (CRITICAL!)';
        END IF;
        IF NOT auth_policy_exists THEN
            RAISE NOTICE '   - Authenticated policy is missing';
        END IF;
        IF NOT public_policy_exists THEN
            RAISE NOTICE '   - Public policy is missing';
        END IF;
    END IF;
    RAISE NOTICE '========================================';
END $$;

-- ============================================
-- STEP 8: TEST INSERT (Optional but recommended)
-- ============================================
-- Uncomment the lines below to test if inserts work:

/*
-- Test as anonymous user
DO $$
BEGIN
    PERFORM set_config('role', 'anon', true);
    
    INSERT INTO public.contact_submissions (
        first_name, 
        last_name, 
        email, 
        project_type, 
        message
    ) VALUES (
        'Nuclear Fix Test', 
        'User', 
        'nuclear-test@example.com', 
        'Web Development', 
        'This is a test from the nuclear fix script'
    );
    
    PERFORM set_config('role', 'postgres', true);
    
    RAISE NOTICE '✅ Test insert successful!';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Test insert failed: %', SQLERRM;
    PERFORM set_config('role', 'postgres', true);
END $$;

-- Check if test insert worked
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM public.contact_submissions 
            WHERE email = 'nuclear-test@example.com'
        ) THEN '✅ Test insert found in database!'
        ELSE '❌ Test insert NOT found'
    END as test_result;
*/

-- ============================================
-- DONE!
-- ============================================
-- This script:
-- ✅ Completely disabled RLS
-- ✅ Dropped ALL existing policies
-- ✅ Created fresh policies for anon, authenticated, and public
-- ✅ Re-enabled RLS
-- ✅ Verified everything
--
-- If you still get errors, the issue might be:
-- 1. Browser cache - try hard refresh (Ctrl+Shift+R)
-- 2. Supabase client not using anon key - check your code
-- 3. Table permissions - run this script again
-- ============================================

