-- ============================================
-- ENABLE REAL-TIME REPLICATION FOR TABLES
-- ============================================
-- Run this in Supabase SQL Editor to enable real-time updates
-- This allows the website to receive instant updates when data changes
-- This version safely handles missing tables
-- ============================================

DO $$
DECLARE
    table_exists BOOLEAN;
BEGIN
    -- Enable real-time for products table (if exists)
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'products'
    ) INTO table_exists;
    
    IF table_exists THEN
        BEGIN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.products;
            ALTER TABLE public.products REPLICA IDENTITY FULL;
            RAISE NOTICE '✅ Enabled real-time for products table';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️ products table already in publication or error: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ products table does not exist, skipping...';
    END IF;

    -- Enable real-time for product_plans table (if exists)
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'product_plans'
    ) INTO table_exists;
    
    IF table_exists THEN
        BEGIN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.product_plans;
            ALTER TABLE public.product_plans REPLICA IDENTITY FULL;
            RAISE NOTICE '✅ Enabled real-time for product_plans table';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️ product_plans table already in publication or error: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ product_plans table does not exist, skipping...';
    END IF;

    -- Enable real-time for profiles table (if exists)
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'profiles'
    ) INTO table_exists;
    
    IF table_exists THEN
        BEGIN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
            ALTER TABLE public.profiles REPLICA IDENTITY FULL;
            RAISE NOTICE '✅ Enabled real-time for profiles table';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️ profiles table already in publication or error: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ profiles table does not exist, skipping...';
    END IF;

    -- Enable real-time for order_customizations table (if exists)
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'order_customizations'
    ) INTO table_exists;
    
    IF table_exists THEN
        BEGIN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.order_customizations;
            ALTER TABLE public.order_customizations REPLICA IDENTITY FULL;
            RAISE NOTICE '✅ Enabled real-time for order_customizations table';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️ order_customizations table already in publication or error: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ order_customizations table does not exist, skipping...';
    END IF;

    -- Enable real-time for customization_forms table (if exists)
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms'
    ) INTO table_exists;
    
    IF table_exists THEN
        BEGIN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.customization_forms;
            ALTER TABLE public.customization_forms REPLICA IDENTITY FULL;
            RAISE NOTICE '✅ Enabled real-time for customization_forms table';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️ customization_forms table already in publication or error: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ customization_forms table does not exist, skipping...';
    END IF;

    -- Enable real-time for support_tickets table (if exists)
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets'
    ) INTO table_exists;
    
    IF table_exists THEN
        BEGIN
            ALTER PUBLICATION supabase_realtime ADD TABLE public.support_tickets;
            ALTER TABLE public.support_tickets REPLICA IDENTITY FULL;
            RAISE NOTICE '✅ Enabled real-time for support_tickets table';
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '⚠️ support_tickets table already in publication or error: %', SQLERRM;
        END;
    ELSE
        RAISE NOTICE '⚠️ support_tickets table does not exist, skipping...';
    END IF;

    RAISE NOTICE '✅ Real-time setup complete!';
END $$;

-- Verify real-time is enabled (run this to check which tables have real-time)
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;

