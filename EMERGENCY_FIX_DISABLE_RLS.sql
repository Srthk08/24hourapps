-- ============================================
-- EMERGENCY FIX: TEMPORARILY DISABLE RLS
-- ============================================
-- If nothing else works, run this to disable RLS completely
-- This will allow inserts to work, but removes security
-- ONLY USE THIS FOR TESTING!
-- ============================================

-- Disable RLS
ALTER TABLE public.contact_submissions DISABLE ROW LEVEL SECURITY;

-- Verify it's disabled
SELECT 
    'RLS Status' as check_type,
    CASE 
        WHEN relforcerowsecurity THEN '❌ STILL ENABLED'
        ELSE '✅ DISABLED'
    END as status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname = 'contact_submissions' 
AND n.nspname = 'public';

-- Grant permissions (in case they're missing)
GRANT USAGE ON SCHEMA public TO anon, authenticated, public;
GRANT ALL ON public.contact_submissions TO anon, authenticated, public;

-- ============================================
-- WARNING: With RLS disabled, ANYONE can insert
-- This is NOT secure for production!
-- ============================================
-- After testing, you MUST:
-- 1. Re-enable RLS
-- 2. Create proper policies
-- 3. Run COMPLETE_FIX_WITH_VERIFICATION.sql
-- ============================================



