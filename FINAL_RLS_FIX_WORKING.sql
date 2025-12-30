-- ============================================
-- FINAL RLS FIX - THIS WILL DEFINITELY WORK
-- ============================================
-- The issue: Anonymous users in Supabase use the 'anon' role
-- We need EXPLICIT policies for anon, authenticated, AND public
-- ============================================

-- ============================================
-- STEP 1: DROP ALL EXISTING POLICIES
-- ============================================

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
        BEGIN
            EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions CASCADE', r.policyname);
        EXCEPTION WHEN OTHERS THEN
            NULL;
        END;
    END LOOP;
END $$;

-- ============================================
-- STEP 2: DISABLE RLS TEMPORARILY
-- ============================================

ALTER TABLE IF EXISTS public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 3: ENSURE TABLE EXISTS WITH CORRECT STRUCTURE
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

-- Make project_type nullable if needed
DO $$ 
BEGIN
    ALTER TABLE public.contact_submissions ALTER COLUMN project_type DROP NOT NULL;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- ============================================
-- STEP 4: GRANT ALL PERMISSIONS
-- ============================================

GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO public;

GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- ============================================
-- STEP 5: CREATE EXPLICIT POLICIES FOR ALL ROLES
-- ============================================
-- CRITICAL: Create separate policies for anon, authenticated, AND public
-- This ensures it works regardless of which role the user has

-- Policy 1: Anonymous users (not logged in) - THIS IS THE KEY!
CREATE POLICY "anon_insert_contact"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Policy 2: Authenticated users (logged in)
CREATE POLICY "authenticated_insert_contact"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Policy 3: Public role (covers all)
CREATE POLICY "public_insert_contact"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- ============================================
-- STEP 6: CREATE ADMIN POLICIES
-- ============================================

CREATE POLICY "admins_select_contact"
    ON public.contact_submissions
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "admins_update_contact"
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

CREATE POLICY "admins_delete_contact"
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
-- STEP 7: ENABLE RLS
-- ============================================

ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STEP 8: VERIFY SETUP
-- ============================================

DO $$
DECLARE
    anon_policy_count INTEGER;
    auth_policy_count INTEGER;
    public_policy_count INTEGER;
    total_insert_policies INTEGER;
BEGIN
    -- Count policies by role
    SELECT COUNT(*) INTO anon_policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT'
    AND 'anon' = ANY(roles);
    
    SELECT COUNT(*) INTO auth_policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT'
    AND 'authenticated' = ANY(roles);
    
    SELECT COUNT(*) INTO public_policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT'
    AND 'public' = ANY(roles);
    
    SELECT COUNT(*) INTO total_insert_policies
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RLS SETUP VERIFICATION';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Anon INSERT policies: %', anon_policy_count;
    RAISE NOTICE 'Authenticated INSERT policies: %', auth_policy_count;
    RAISE NOTICE 'Public INSERT policies: %', public_policy_count;
    RAISE NOTICE 'Total INSERT policies: %', total_insert_policies;
    RAISE NOTICE '========================================';
    
    IF anon_policy_count > 0 AND auth_policy_count > 0 AND public_policy_count > 0 THEN
        RAISE NOTICE '✅ SUCCESS! All policies created correctly!';
        RAISE NOTICE '✅ Your contact form should work now!';
    ELSIF total_insert_policies > 0 THEN
        RAISE NOTICE '⚠️ Some policies exist, but not all roles covered.';
        RAISE NOTICE 'This might still work, but test your form.';
    ELSE
        RAISE NOTICE '❌ WARNING: No INSERT policies found!';
    END IF;
    RAISE NOTICE '========================================';
END $$;

-- ============================================
-- DONE!
-- ============================================
-- This script creates THREE separate INSERT policies:
-- 1. For 'anon' role (anonymous users)
-- 2. For 'authenticated' role (logged in users)
-- 3. For 'public' role (covers all)
--
-- This ensures your contact form works regardless of
-- whether the user is logged in or not.
-- ============================================





