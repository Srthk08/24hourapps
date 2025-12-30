-- ============================================
-- QUICK FIX - Run this NOW to fix RLS error
-- ============================================
-- This creates explicit policies for anon, authenticated, and public roles
-- Run this entire script in Supabase SQL Editor
-- ============================================

-- Drop all existing INSERT policies
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'contact_submissions'
        AND cmd = 'INSERT'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions', r.policyname);
    END LOOP;
END $$;

-- Ensure grants are in place
GRANT USAGE ON SCHEMA public TO anon, authenticated, public;
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;
GRANT INSERT ON public.contact_submissions TO public;

-- Create THREE separate INSERT policies (this is the key!)

-- 1. For anonymous users (not logged in)
CREATE POLICY "anon_can_insert_contact"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- 2. For authenticated users (logged in)
CREATE POLICY "authenticated_can_insert_contact"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- 3. For public role (covers all)
CREATE POLICY "public_can_insert_contact"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Verify
DO $$
DECLARE
    policy_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    
    RAISE NOTICE '✅ Created % INSERT policies', policy_count;
    RAISE NOTICE '✅ Your contact form should work now!';
END $$;





