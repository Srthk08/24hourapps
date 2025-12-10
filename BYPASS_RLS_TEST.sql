-- ============================================
-- BYPASS RLS TEST - This will tell us if RLS is the problem
-- ============================================
-- Run this to completely disable RLS and test
-- If this works, RLS is the problem
-- If this doesn't work, the problem is something else
-- ============================================

-- Disable RLS completely
ALTER TABLE public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- Grant everything
GRANT ALL ON public.contact_submissions TO anon;
GRANT ALL ON public.contact_submissions TO authenticated;
GRANT ALL ON public.contact_submissions TO public;

-- Verify RLS is disabled
SELECT 
    'RLS Status' as check_type,
    CASE 
        WHEN relforcerowsecurity THEN '❌ STILL ENABLED'
        ELSE '✅ DISABLED - RLS is OFF'
    END as status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname = 'contact_submissions' 
AND n.nspname = 'public';

-- ============================================
-- NOW TEST YOUR CONTACT FORM
-- ============================================
-- 1. Go to your contact form
-- 2. Fill it out and submit
-- 3. Does it work now?
--
-- ✅ If YES: RLS policies are the problem
--    → Run DIAGNOSE_AND_FIX_NOW.sql to fix policies
--
-- ❌ If NO: RLS is NOT the problem
--    → The issue is:
--      - Browser cache
--      - Supabase client not initialized
--      - Wrong Supabase project
--      - Network/firewall
--      - Code issue
-- ============================================



