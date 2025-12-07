-- ============================================
-- CUSTOMIZATION FORMS TABLE FIX
-- ============================================
-- This script adds missing columns that the application code expects
-- Run this AFTER running CUSTOMIZATION_FORMS_SETUP.sql
-- ============================================

-- Add product_type column if it doesn't exist (used by existing code)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_type'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_type TEXT;
        -- Create index for product_type
        CREATE INDEX IF NOT EXISTS idx_customization_forms_product_type ON public.customization_forms(product_type);
    END IF;
END $$;

-- Add product_price column if it doesn't exist (used by existing code)
-- This is kept for backward compatibility, but price should be used for new records
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_price'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_price TEXT;
    END IF;
END $$;

-- Make plan_name, plan_type, price, duration nullable for backward compatibility
-- Since existing code doesn't send these fields
DO $$ 
BEGIN
    -- Make plan_name nullable if it's NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'plan_name'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_name DROP NOT NULL;
    END IF;
    
    -- Make plan_type nullable if it's NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'plan_type'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_type DROP NOT NULL;
    END IF;
    
    -- Make price nullable if it's NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'price'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN price DROP NOT NULL;
    END IF;
    
    -- Make duration nullable if it's NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'duration'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN duration DROP NOT NULL;
    END IF;
END $$;

-- Add admin_notes column if it doesn't exist (used by updateCustomizationStatus)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'admin_notes'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN admin_notes TEXT;
    END IF;
END $$;

-- Ensure customer_email is populated from contact_email if missing
DO $$ 
BEGIN
    UPDATE public.customization_forms 
    SET customer_email = COALESCE(customer_email, contact_email, 'unknown@example.com') 
    WHERE customer_email IS NULL OR customer_email = '';
END $$;

-- Verify all columns exist
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'customization_forms'
ORDER BY ordinal_position;

-- ============================================
-- DONE! The table now supports both old and new field names
-- ============================================


