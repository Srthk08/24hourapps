-- ============================================
-- CHECK CURRENT STATE - Run this FIRST
-- ============================================
-- This will show you exactly what's in your database
-- Copy the output and share it if you need help
-- ============================================

-- Check if table exists
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'contact_submissions'
        ) THEN '✅ Table EXISTS'
        ELSE '❌ Table DOES NOT EXIST'
    END as table_status;

-- Check RLS status
SELECT 
    relname as table_name,
    relforcerowsecurity as rls_enabled,
    CASE 
        WHEN relforcerowsecurity THEN '✅ RLS is ENABLED'
        ELSE '❌ RLS is DISABLED'
    END as rls_status
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE c.relname = 'contact_submissions' 
AND n.nspname = 'public';

-- List ALL policies with details
SELECT 
    policyname,
    roles,
    cmd as command,
    qual as using_clause,
    with_check as with_check_clause
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'contact_submissions'
ORDER BY cmd, policyname;

-- Count policies by type
SELECT 
    cmd as command,
    COUNT(*) as policy_count,
    string_agg(policyname, ', ') as policy_names
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'contact_submissions'
GROUP BY cmd
ORDER BY cmd;

-- Check grants for anon, authenticated, public
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'public' 
AND table_name = 'contact_submissions'
AND grantee IN ('anon', 'authenticated', 'public')
ORDER BY grantee, privilege_type;

-- Detailed INSERT policy check
SELECT 
    'INSERT Policies' as check_type,
    COUNT(*) as count,
    string_agg(policyname || ' (' || array_to_string(roles, ', ') || ')', '; ') as details
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'contact_submissions' 
AND cmd = 'INSERT';

-- Check if anon has INSERT policy
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE schemaname = 'public' 
            AND tablename = 'contact_submissions' 
            AND cmd = 'INSERT'
            AND 'anon' = ANY(roles)
        ) THEN '✅ Anon has INSERT policy'
        ELSE '❌ Anon does NOT have INSERT policy'
    END as anon_policy_check;

-- Check if authenticated has INSERT policy
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE schemaname = 'public' 
            AND tablename = 'contact_submissions' 
            AND cmd = 'INSERT'
            AND 'authenticated' = ANY(roles)
        ) THEN '✅ Authenticated has INSERT policy'
        ELSE '❌ Authenticated does NOT have INSERT policy'
    END as authenticated_policy_check;

-- Check if public has INSERT policy
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_policies 
            WHERE schemaname = 'public' 
            AND tablename = 'contact_submissions' 
            AND cmd = 'INSERT'
            AND 'public' = ANY(roles)
        ) THEN '✅ Public has INSERT policy'
        ELSE '❌ Public does NOT have INSERT policy'
    END as public_policy_check;






