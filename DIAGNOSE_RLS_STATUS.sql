-- ============================================
-- RLS DIAGNOSTIC SCRIPT
-- ============================================
-- Run this AFTER running DEFINITIVE_RLS_FIX.sql
-- This will show you the current state of your RLS setup
-- ============================================

-- Check if table exists
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'contact_submissions'
        ) THEN '✅ Table exists'
        ELSE '❌ Table does NOT exist'
    END as table_status;

-- Check RLS status
SELECT 
    relname as table_name,
    relforcerowsecurity as rls_enabled,
    CASE 
        WHEN relforcerowsecurity THEN '✅ RLS is ENABLED'
        ELSE '❌ RLS is DISABLED'
    END as rls_status
FROM pg_class
WHERE relname = 'contact_submissions' 
AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- List ALL policies on contact_submissions
SELECT 
    policyname,
    roles,
    cmd as command,
    qual as using_expression,
    with_check as with_check_expression,
    CASE 
        WHEN cmd = 'INSERT' THEN '✅ INSERT policy'
        ELSE cmd || ' policy'
    END as policy_type
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'contact_submissions'
ORDER BY cmd, policyname;

-- Count policies by type
SELECT 
    cmd as command,
    COUNT(*) as policy_count
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'contact_submissions'
GROUP BY cmd
ORDER BY cmd;

-- Check grants
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.table_privileges
WHERE table_schema = 'public' 
AND table_name = 'contact_submissions'
AND grantee IN ('anon', 'authenticated', 'public')
ORDER BY grantee, privilege_type;

-- Check table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'contact_submissions'
ORDER BY ordinal_position;

-- Test INSERT as anonymous user (simulate your form)
-- Uncomment the lines below to test:
/*
SET ROLE anon;
INSERT INTO public.contact_submissions (
    first_name, 
    last_name, 
    email, 
    project_type, 
    message
) VALUES (
    'Diagnostic', 
    'Test', 
    'diagnostic@test.com', 
    'Web Development', 
    'This is a diagnostic test'
);
RESET ROLE;

-- Check if the test insert worked
SELECT * FROM public.contact_submissions 
WHERE email = 'diagnostic@test.com';
*/

-- Summary
DO $$
DECLARE
    table_exists BOOLEAN;
    rls_enabled BOOLEAN;
    insert_policy_count INTEGER;
    total_policies INTEGER;
BEGIN
    -- Check table exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions'
    ) INTO table_exists;
    
    -- Check RLS enabled
    SELECT relforcerowsecurity INTO rls_enabled
    FROM pg_class
    WHERE relname = 'contact_submissions' 
    AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
    
    -- Count INSERT policies
    SELECT COUNT(*) INTO insert_policy_count
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions' 
    AND cmd = 'INSERT';
    
    -- Count total policies
    SELECT COUNT(*) INTO total_policies
    FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'contact_submissions';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RLS DIAGNOSTIC SUMMARY';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Table exists: %', CASE WHEN table_exists THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'RLS enabled: %', CASE WHEN rls_enabled THEN '✅ YES' ELSE '❌ NO' END;
    RAISE NOTICE 'INSERT policies: %', insert_policy_count;
    RAISE NOTICE 'Total policies: %', total_policies;
    RAISE NOTICE '========================================';
    
    IF NOT table_exists THEN
        RAISE NOTICE '❌ ISSUE: Table does not exist! Run DEFINITIVE_RLS_FIX.sql first.';
    ELSIF NOT rls_enabled THEN
        RAISE NOTICE '❌ ISSUE: RLS is not enabled! Run DEFINITIVE_RLS_FIX.sql to fix.';
    ELSIF insert_policy_count = 0 THEN
        RAISE NOTICE '❌ ISSUE: No INSERT policies found! Run DEFINITIVE_RLS_FIX.sql to fix.';
    ELSIF insert_policy_count > 0 AND rls_enabled THEN
        RAISE NOTICE '✅ SETUP LOOKS GOOD!';
        RAISE NOTICE 'If you still get RLS errors, check:';
        RAISE NOTICE '1. Are you using the correct Supabase anon key?';
        RAISE NOTICE '2. Is the table structure matching your code?';
        RAISE NOTICE '3. Try running the test INSERT above (uncomment it)';
    END IF;
    RAISE NOTICE '========================================';
END $$;






