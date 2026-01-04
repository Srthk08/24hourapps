-- ============================================
-- QUICK ONE-STEP FIX
-- ============================================
-- If the comprehensive scripts don't work, try this
-- This is the most permissive setup possible
-- ============================================

-- Disable RLS temporarily
ALTER TABLE public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'contact_submissions') LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.contact_submissions', r.policyname);
    END LOOP;
END $$;

-- Grant everything
GRANT USAGE ON SCHEMA public TO anon, authenticated, public;
GRANT ALL ON public.contact_submissions TO anon, authenticated, public;

-- Create single most permissive policy
CREATE POLICY "allow_all_inserts"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Re-enable RLS
ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- DONE! Test your form now.
-- ============================================






