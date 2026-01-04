-- ============================================
-- FINAL FIX - DISABLE RLS TEMPORARILY
-- ============================================
-- If nothing else works, use this to DISABLE RLS
-- This will allow inserts to work immediately
-- WARNING: This removes RLS protection - use only for testing
-- ============================================

-- Step 1: Drop all policies
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT policyname 
        FROM pg_policies 
        WHERE tablename = 'contact_submissions'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions', r.policyname);
    END LOOP;
END $$;

-- Step 2: Disable RLS completely
ALTER TABLE public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- Step 3: Grant all permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated, public;
GRANT ALL ON public.contact_submissions TO anon, authenticated, public;

-- ============================================
-- DONE! RLS is now DISABLED
-- Your contact form should work now.
-- 
-- ⚠️ WARNING: This removes security protection.
-- Only use this if you need immediate access.
-- Consider re-enabling RLS with proper policies later.
-- ============================================






