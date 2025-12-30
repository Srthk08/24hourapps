-- ============================================
-- TEST: Disable RLS Completely to Test
-- ============================================
-- This will temporarily disable RLS to see if that's the issue
-- If inserts work with RLS disabled, then it's a policy problem
-- If inserts still fail, it's a different issue (permissions, triggers, etc.)
-- ============================================

-- Disable RLS completely
ALTER TABLE public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- Verify RLS is disabled
SELECT 
    relname as table_name,
    relforcerowsecurity as rls_enabled,
    CASE 
        WHEN relforcerowsecurity THEN '❌ RLS is still ENABLED'
        ELSE '✅ RLS is DISABLED'
    END as status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname = 'contact_submissions' 
AND n.nspname = 'public';

-- Now try your contact form
-- If it works with RLS disabled, the issue is with policies
-- If it still doesn't work, the issue is something else

-- ============================================
-- IMPORTANT: After testing, you MUST re-enable RLS
-- Run the script below to re-enable with proper policies
-- ============================================





