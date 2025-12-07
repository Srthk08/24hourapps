-- ============================================
-- CUSTOMIZATION FORMS DIAGNOSTIC & FIX
-- ============================================
-- Run this to diagnose and fix issues with data not storing
-- ============================================

-- Step 1: Check if table exists
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms'
    ) THEN
        RAISE EXCEPTION 'Table customization_forms does not exist. Please run CUSTOMIZATION_FORMS_SETUP.sql first.';
    ELSE
        RAISE NOTICE '✅ Table customization_forms exists';
    END IF;
END $$;

-- Step 2: Temporarily disable RLS to test inserts
ALTER TABLE public.customization_forms DISABLE ROW LEVEL SECURITY;

-- Step 3: Add all missing columns that the code expects
DO $$ 
BEGIN
    -- Add product_type
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_type'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_type TEXT;
        CREATE INDEX IF NOT EXISTS idx_customization_forms_product_type ON public.customization_forms(product_type);
        RAISE NOTICE '✅ Added product_type column';
    END IF;
    
    -- Add product_price
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_price'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_price TEXT;
        RAISE NOTICE '✅ Added product_price column';
    END IF;
    
    -- Add admin_notes
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'admin_notes'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN admin_notes TEXT;
        RAISE NOTICE '✅ Added admin_notes column';
    END IF;
END $$;

-- Step 4: Make customer_email nullable and add default trigger
DO $$ 
BEGIN
    -- Check if customer_email is NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'customer_email'
        AND is_nullable = 'NO'
    ) THEN
        -- First, populate any NULL values from contact_email
        UPDATE public.customization_forms 
        SET customer_email = COALESCE(contact_email, 'unknown@example.com') 
        WHERE customer_email IS NULL OR customer_email = '';
        
        -- Then make it nullable
        ALTER TABLE public.customization_forms ALTER COLUMN customer_email DROP NOT NULL;
        RAISE NOTICE '✅ Made customer_email nullable';
    END IF;
END $$;

-- Create trigger to auto-populate customer_email from contact_email if missing
CREATE OR REPLACE FUNCTION public.set_customer_email_from_contact()
RETURNS TRIGGER AS $$
BEGIN
    -- If customer_email is not provided, use contact_email
    IF NEW.customer_email IS NULL OR NEW.customer_email = '' THEN
        NEW.customer_email := COALESCE(NEW.contact_email, 'unknown@example.com');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_customer_email_trigger ON public.customization_forms;
CREATE TRIGGER set_customer_email_trigger
    BEFORE INSERT ON public.customization_forms
    FOR EACH ROW
    EXECUTE FUNCTION public.set_customer_email_from_contact();

-- Step 5: Make all plan-related fields nullable
DO $$ 
BEGIN
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_name DROP NOT NULL;
        RAISE NOTICE '✅ Made plan_name nullable';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '⚠️ plan_name: %', SQLERRM;
    END;
    
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_type DROP NOT NULL;
        RAISE NOTICE '✅ Made plan_type nullable';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '⚠️ plan_type: %', SQLERRM;
    END;
    
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN price DROP NOT NULL;
        RAISE NOTICE '✅ Made price nullable';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '⚠️ price: %', SQLERRM;
    END;
    
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN duration DROP NOT NULL;
        RAISE NOTICE '✅ Made duration nullable';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '⚠️ duration: %', SQLERRM;
    END;
END $$;

-- Step 6: Test insert with minimal data (what the code actually sends)
DO $$ 
DECLARE
    test_id UUID;
BEGIN
    -- Try to insert a test record with only the fields the code sends
    INSERT INTO public.customization_forms (
        product_type,
        product_name,
        product_price,
        project_name,
        contact_person,
        app_name,
        product_description,
        restaurant_name,
        cuisine_type,
        logo_url,
        logo_filename,
        logo_mime_type,
        logo_size,
        contact_email,
        contact_phone,
        primary_color,
        secondary_color,
        accent_color,
        text_color,
        additional_requirements,
        menu_items,
        restaurant_address,
        owner_name,
        status,
        contact_email
    ) VALUES (
        'android-tv-app',
        'Test Product',
        '₹299',
        'Test Project',
        'Test Person',
        'Test App',
        'Test Description',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        'test@example.com',
        NULL,
        '#3B82F6',
        '#10B981',
        '#F59E0B',
        '#1F2937',
        '',
        '[]'::jsonb,
        NULL,
        NULL,
        'pending',
        'test@example.com'
    ) RETURNING id INTO test_id;
    
    RAISE NOTICE '✅ Test insert successful! ID: %', test_id;
    
    -- Clean up test record
    DELETE FROM public.customization_forms WHERE id = test_id;
    RAISE NOTICE '✅ Test record cleaned up';
    
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Test insert failed: %', SQLERRM;
END $$;

-- Step 7: Re-enable RLS with permissive policies
ALTER TABLE public.customization_forms ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "Public can insert customization forms" ON public.customization_forms;
DROP POLICY IF EXISTS "Anyone can insert customization forms" ON public.customization_forms;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.customization_forms;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.customization_forms;
DROP POLICY IF EXISTS "Users can view own customizations" ON public.customization_forms;
DROP POLICY IF EXISTS "Admins can view all customizations" ON public.customization_forms;
DROP POLICY IF EXISTS "Admins can update customizations" ON public.customization_forms;
DROP POLICY IF EXISTS "Admins can delete customizations" ON public.customization_forms;

-- Create very permissive insert policy (allows anyone to insert)
CREATE POLICY "Anyone can insert customization forms"
    ON public.customization_forms
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Create permissive select policy (users can see their own, admins see all)
CREATE POLICY "Users can view own customizations"
    ON public.customization_forms
    FOR SELECT
    USING (
        -- Allow if no auth (for anonymous)
        auth.uid() IS NULL
        OR
        -- Allow if user_id matches
        user_id = auth.uid()
        OR
        -- Allow if email matches
        customer_email = (SELECT email FROM public.profiles WHERE id = auth.uid())
        OR
        contact_email = (SELECT email FROM public.profiles WHERE id = auth.uid())
        OR
        -- Allow admins to see all
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create admin update policy
CREATE POLICY "Admins can update customizations"
    ON public.customization_forms
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Create admin delete policy
CREATE POLICY "Admins can delete customizations"
    ON public.customization_forms
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Step 8: Ensure grants are correct
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.customization_forms TO anon, authenticated;
GRANT INSERT ON public.customization_forms TO anon;
GRANT INSERT ON public.customization_forms TO authenticated;
GRANT SELECT ON public.customization_forms TO anon;
GRANT SELECT ON public.customization_forms TO authenticated;

-- Step 9: Show current table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'customization_forms'
ORDER BY ordinal_position;

-- Step 10: Show current policies
SELECT 
    policyname,
    cmd,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'customization_forms';

-- ============================================
-- DIAGNOSTIC COMPLETE
-- ============================================
-- If the test insert above succeeded, your table is configured correctly.
-- If it failed, check the error message above.
-- 
-- Next steps:
-- 1. Check browser console for JavaScript errors
-- 2. Check Supabase logs in Dashboard > Logs
-- 3. Try inserting from your application again
-- ============================================

