-- ============================================
-- QUICK FIX: Make Customization Forms Table Work
-- ============================================
-- Run this if data is not storing in Supabase
-- This ensures all required columns exist and RLS allows inserts
-- ============================================

-- Step 1: Add missing columns that the code expects
DO $$ 
BEGIN
    -- Add product_type column (used by existing code)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_type'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_type TEXT;
        CREATE INDEX IF NOT EXISTS idx_customization_forms_product_type ON public.customization_forms(product_type);
    END IF;
    
    -- Add product_price column (used by existing code)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_price'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_price TEXT;
    END IF;
    
    -- Add admin_notes column
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'admin_notes'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN admin_notes TEXT;
    END IF;
END $$;

-- Step 2: Make required fields nullable so existing code can insert
DO $$ 
BEGIN
    -- Make plan_name nullable
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_name DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN
        NULL; -- Column might not exist or already nullable
    END;
    
    -- Make plan_type nullable
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_type DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    -- Make price nullable
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN price DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
    
    -- Make duration nullable
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN duration DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END $$;

-- Step 3: Ensure customer_email is populated
DO $$ 
BEGIN
    UPDATE public.customization_forms 
    SET customer_email = COALESCE(customer_email, contact_email, 'unknown@example.com') 
    WHERE customer_email IS NULL OR customer_email = '';
    
    -- If customer_email is still NULL after update, make it nullable temporarily
    BEGIN
        ALTER TABLE public.customization_forms ALTER COLUMN customer_email DROP NOT NULL;
    EXCEPTION WHEN OTHERS THEN
        NULL; -- Might already be nullable or have constraints
    END;
END $$;

-- Step 4: Recreate RLS policies to ensure inserts work
DROP POLICY IF EXISTS "Public can insert customization forms" ON public.customization_forms;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.customization_forms;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.customization_forms;

-- Recreate insert policies
CREATE POLICY "Public can insert customization forms"
    ON public.customization_forms
    FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Allow anonymous inserts"
    ON public.customization_forms
    FOR INSERT
    TO anon
    WITH CHECK (true);

CREATE POLICY "Allow authenticated inserts"
    ON public.customization_forms
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Step 5: Ensure grants are in place
GRANT INSERT ON public.customization_forms TO anon;
GRANT INSERT ON public.customization_forms TO authenticated;
GRANT SELECT ON public.customization_forms TO anon;
GRANT SELECT ON public.customization_forms TO authenticated;

-- Step 6: Verify the table structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'customization_forms'
ORDER BY ordinal_position;

-- Step 7: Test insert (optional - comment out if you don't want test data)
/*
INSERT INTO public.customization_forms (
    customer_email,
    contact_email,
    product_name,
    product_type,
    product_price,
    status
) VALUES (
    'test@example.com',
    'test@example.com',
    'Test Product',
    'android-tv-app',
    '₹299',
    'pending'
) ON CONFLICT DO NOTHING;
*/

-- ============================================
-- DONE! The table should now accept inserts from your application
-- ============================================
-- If data still doesn't store, check:
-- 1. Browser console for error messages
-- 2. Supabase logs for RLS policy violations
-- 3. That you're using the correct table name: 'customization_forms'
-- ============================================



