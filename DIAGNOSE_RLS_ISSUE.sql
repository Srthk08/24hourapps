-- ============================================
-- DIAGNOSTIC SCRIPT - Check Current RLS Status
-- ============================================
-- Run this FIRST to see what's wrong
-- ============================================

-- 1. Check if table exists
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' AND table_name = 'contact_submissions'
        ) THEN '✅ Table EXISTS'
        ELSE '❌ Table DOES NOT EXIST'
    END as table_status;

-- 2. Check if RLS is enabled
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM pg_tables 
            WHERE schemaname = 'public' 
            AND tablename = 'contact_submissions' 
            AND rowsecurity = true
        ) THEN '✅ RLS is ENABLED'
        ELSE '❌ RLS is DISABLED'
    END as rls_status;

-- 3. List ALL policies on the table
SELECT 
    policyname,
    roles,
    cmd,
    qual,
    with_check,
    CASE 
        WHEN cmd = 'INSERT' THEN '✅ INSERT Policy'
        ELSE 'Other Policy'
    END as policy_type
FROM pg_policies 
WHERE tablename = 'contact_submissions'
ORDER BY cmd, policyname;

-- 4. Check permissions
SELECT 
    grantee,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public' 
AND table_name = 'contact_submissions'
AND grantee IN ('anon', 'authenticated', 'public')
ORDER BY grantee, privilege_type;

-- 5. Count INSERT policies
SELECT 
    COUNT(*) as insert_policy_count,
    CASE 
        WHEN COUNT(*) = 0 THEN '❌ NO INSERT POLICIES - THIS IS THE PROBLEM!'
        WHEN COUNT(*) > 0 THEN '✅ INSERT policies exist'
    END as status
FROM pg_policies 
WHERE tablename = 'contact_submissions' 
AND cmd = 'INSERT';

-- ============================================
-- If you see "NO INSERT POLICIES" above,
-- that's why it's failing!
-- Run ULTIMATE_RLS_FIX.sql to fix it.
-- ============================================






