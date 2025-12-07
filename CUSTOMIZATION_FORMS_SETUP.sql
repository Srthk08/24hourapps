-- ============================================
-- SUPABASE CUSTOMIZATION FORMS DATABASE SETUP
-- ============================================
-- Run these queries in your Supabase SQL Editor
-- to create table for storing product customization form details
-- Based on the customization form with file uploads and plan selection
-- ============================================

-- ============================================
-- 1. CUSTOMIZATION FORMS TABLE
-- ============================================
-- This table stores customization form submissions with file uploads
-- Fields: Logo, Background/Wallpaper, Intro Video, Selected Plan details

CREATE TABLE IF NOT EXISTS public.customization_forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User Information
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    customer_email TEXT NOT NULL,
    customer_name TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    
    -- Product & Plan Information
    product_id UUID,
    product_name TEXT NOT NULL,
    product_slug TEXT,
    product_type TEXT, -- For backward compatibility with existing code
    product_price TEXT, -- For backward compatibility (old format: '₹0')
    plan_id UUID,
    plan_name TEXT, -- Made nullable for backward compatibility
    plan_type TEXT, -- Made nullable for backward compatibility
    price NUMERIC(12, 2), -- Made nullable for backward compatibility
    price_currency TEXT DEFAULT 'GBP',
    duration TEXT, -- Made nullable for backward compatibility
    features JSONB DEFAULT '[]'::jsonb,
    
    -- File Uploads
    logo_url TEXT,
    logo_filename TEXT,
    logo_mime_type TEXT,
    logo_size BIGINT,
    
    background_url TEXT,
    background_filename TEXT,
    background_mime_type TEXT,
    background_size BIGINT,
    
    intro_video_url TEXT,
    intro_video_filename TEXT,
    intro_video_mime_type TEXT,
    intro_video_size BIGINT,
    intro_video_duration TEXT,
    
    -- Additional Information
    project_name TEXT,
    contact_person TEXT,
    app_name TEXT,
    product_description TEXT,
    additional_requirements TEXT,
    
    -- Customization Details (for restaurant/other products)
    restaurant_name TEXT,
    cuisine_type TEXT,
    restaurant_address TEXT,
    owner_name TEXT,
    primary_color TEXT DEFAULT '#3B82F6',
    secondary_color TEXT DEFAULT '#10B981',
    accent_color TEXT DEFAULT '#F59E0B',
    text_color TEXT DEFAULT '#1F2937',
    menu_items JSONB DEFAULT '[]'::jsonb,
    menu_categories JSONB DEFAULT '[]'::jsonb,
    
    -- Status & Tracking
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled', 'rejected')),
    order_id UUID,
    customization_number TEXT UNIQUE,
    admin_notes TEXT, -- For admin to add notes when updating status
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add missing columns if table already exists (for existing installations)
DO $$ 
BEGIN
    -- Add customization_number column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'customization_number'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN customization_number TEXT;
        -- Generate unique customization numbers for existing records
        UPDATE public.customization_forms 
        SET customization_number = 'CUST-' || LPAD(id::text, 8, '0')
        WHERE customization_number IS NULL;
        -- Make it unique after populating
        ALTER TABLE public.customization_forms ADD CONSTRAINT customization_forms_customization_number_key UNIQUE (customization_number);
    END IF;
    
    -- Add background file columns if they don't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'background_url'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN background_url TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN background_filename TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN background_mime_type TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN background_size BIGINT;
    END IF;
    
    -- Add intro video columns if they don't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'intro_video_url'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN intro_video_url TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN intro_video_filename TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN intro_video_mime_type TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN intro_video_size BIGINT;
        ALTER TABLE public.customization_forms ADD COLUMN intro_video_duration TEXT;
    END IF;
    
    -- Add plan information columns if they don't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'plan_id'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN plan_id UUID;
        ALTER TABLE public.customization_forms ADD COLUMN plan_name TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN plan_type TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN price NUMERIC(12, 2);
        ALTER TABLE public.customization_forms ADD COLUMN price_currency TEXT DEFAULT 'GBP';
        ALTER TABLE public.customization_forms ADD COLUMN duration TEXT;
        ALTER TABLE public.customization_forms ADD COLUMN features JSONB DEFAULT '[]'::jsonb;
    END IF;
    
    -- Add product_id and product_slug if they don't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_id'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_id UUID;
        ALTER TABLE public.customization_forms ADD COLUMN product_slug TEXT;
    END IF;
    
    -- Add product_type if it doesn't exist (used by existing code)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_type'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_type TEXT;
        CREATE INDEX IF NOT EXISTS idx_customization_forms_product_type ON public.customization_forms(product_type);
    END IF;
    
    -- Add product_price if it doesn't exist (used by existing code)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'product_price'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN product_price TEXT;
    END IF;
    
    -- Add admin_notes if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'admin_notes'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN admin_notes TEXT;
    END IF;
    
    -- Make plan_name, plan_type, price, duration nullable if they're NOT NULL
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'plan_name'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_name DROP NOT NULL;
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'plan_type'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN plan_type DROP NOT NULL;
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'price'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN price DROP NOT NULL;
    END IF;
    
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'duration'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.customization_forms ALTER COLUMN duration DROP NOT NULL;
    END IF;
    
    -- Add customer_email if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'customization_forms' 
        AND column_name = 'customer_email'
    ) THEN
        ALTER TABLE public.customization_forms ADD COLUMN customer_email TEXT;
        -- Copy from contact_email if available
        UPDATE public.customization_forms 
        SET customer_email = COALESCE(contact_email, 'unknown@example.com') 
        WHERE customer_email IS NULL;
        -- Make it NOT NULL after populating
        ALTER TABLE public.customization_forms ALTER COLUMN customer_email SET NOT NULL;
    END IF;
END $$;

-- Create indexes for customization_forms table
CREATE INDEX IF NOT EXISTS idx_customization_forms_user_id ON public.customization_forms(user_id);
CREATE INDEX IF NOT EXISTS idx_customization_forms_customer_email ON public.customization_forms(customer_email);
CREATE INDEX IF NOT EXISTS idx_customization_forms_product_id ON public.customization_forms(product_id);
CREATE INDEX IF NOT EXISTS idx_customization_forms_plan_id ON public.customization_forms(plan_id);
CREATE INDEX IF NOT EXISTS idx_customization_forms_status ON public.customization_forms(status);
CREATE INDEX IF NOT EXISTS idx_customization_forms_created_at ON public.customization_forms(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_customization_forms_customization_number ON public.customization_forms(customization_number);
CREATE INDEX IF NOT EXISTS idx_customization_forms_order_id ON public.customization_forms(order_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.customization_forms ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can create customization forms" ON public.customization_forms;
DROP POLICY IF EXISTS "Public can insert customization forms" ON public.customization_forms;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.customization_forms;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.customization_forms;
DROP POLICY IF EXISTS "Users can view own customizations" ON public.customization_forms;
DROP POLICY IF EXISTS "Admins can view all customizations" ON public.customization_forms;
DROP POLICY IF EXISTS "Admins can update customizations" ON public.customization_forms;
DROP POLICY IF EXISTS "Admins can delete customizations" ON public.customization_forms;

-- RLS Policies for customization_forms table
-- Anyone (including anonymous users) can create customization forms
CREATE POLICY "Public can insert customization forms"
    ON public.customization_forms
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Additional policy for anonymous users (explicit)
CREATE POLICY "Allow anonymous inserts"
    ON public.customization_forms
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Additional policy for authenticated users (explicit)
CREATE POLICY "Allow authenticated inserts"
    ON public.customization_forms
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Users can view their own customizations (by email or user_id)
CREATE POLICY "Users can view own customizations"
    ON public.customization_forms
    FOR SELECT
    USING (
        -- Authenticated users can view customizations associated with their user_id
        (auth.uid() IS NOT NULL AND user_id = auth.uid())
        OR
        -- Users can view customizations with their email
        (customer_email = (SELECT email FROM public.profiles WHERE id = auth.uid()))
        OR
        (contact_email = (SELECT email FROM public.profiles WHERE id = auth.uid()))
        OR
        -- Allow viewing if email matches authenticated user's email
        (auth.uid() IS NOT NULL AND customer_email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
    );

-- Admins can view all customizations
CREATE POLICY "Admins can view all customizations"
    ON public.customization_forms
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update customizations (e.g., change status)
CREATE POLICY "Admins can update customizations"
    ON public.customization_forms
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete customizations
CREATE POLICY "Admins can delete customizations"
    ON public.customization_forms
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 2. TRIGGER: Auto-generate customization number
-- ============================================

CREATE OR REPLACE FUNCTION public.generate_customization_number()
RETURNS TRIGGER AS $$
DECLARE
    seq_num INTEGER;
BEGIN
    IF NEW.customization_number IS NULL OR NEW.customization_number = '' THEN
        -- Get next sequence number
        SELECT COALESCE(MAX(CAST(SUBSTRING(customization_number FROM '(\d+)$') AS INTEGER)), 0) + 1
        INTO seq_num
        FROM public.customization_forms
        WHERE customization_number LIKE 'CUST-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-%';
        
        -- Generate customization number: CUST-YYYYMMDD-XXXXXX
        NEW.customization_number := 'CUST-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for auto-generating customization number
DROP TRIGGER IF EXISTS generate_customization_number_trigger ON public.customization_forms;
CREATE TRIGGER generate_customization_number_trigger
    BEFORE INSERT ON public.customization_forms
    FOR EACH ROW
    EXECUTE FUNCTION public.generate_customization_number();

-- ============================================
-- 3. TRIGGER: Update updated_at timestamp
-- ============================================

-- Ensure the update_updated_at_column function exists
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for customization_forms table
DROP TRIGGER IF EXISTS update_customization_forms_updated_at ON public.customization_forms;
CREATE TRIGGER update_customization_forms_updated_at
    BEFORE UPDATE ON public.customization_forms
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 4. GRANT PERMISSIONS
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.customization_forms TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.generate_customization_number() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_updated_at_column() TO anon, authenticated;

-- Ensure anonymous users can insert (explicit grant)
GRANT INSERT ON public.customization_forms TO anon;
GRANT INSERT ON public.customization_forms TO authenticated;

-- ============================================
-- 5. SAMPLE DATA INSERTION (for testing)
-- ============================================

-- Insert sample customization form
INSERT INTO public.customization_forms (
    customer_email,
    customer_name,
    product_name,
    plan_name,
    plan_type,
    price,
    price_currency,
    duration,
    features,
    status
) VALUES (
    'customer@example.com',
    'John Doe',
    'Android TV App',
    'Pro Plan',
    'Pro Plan',
    299.00,
    'GBP',
    'Lifetime',
    '["Everything in Standard", "Unlimited DNS/Portals", "Intro Video", "Get All Future Updates in £19 Only"]'::jsonb,
    'pending'
) ON CONFLICT DO NOTHING;

-- ============================================
-- NOTES:
-- ============================================
-- 1. After running these queries, verify table was created:
--    SELECT table_name FROM information_schema.tables 
--    WHERE table_schema = 'public' 
--    AND table_name = 'customization_forms';
--
-- 2. Verify sample data was inserted:
--    SELECT * FROM public.customization_forms;
--
-- 3. To create a new customization form from your application:
--    INSERT INTO public.customization_forms (
--        customer_email, customer_name, product_name, plan_name, plan_type,
--        price, price_currency, duration, features,
--        logo_url, logo_filename, background_url, background_filename,
--        intro_video_url, intro_video_filename, status
--    ) VALUES (
--        'user@example.com',
--        'User Name',
--        'Android TV App',
--        'Pro Plan',
--        'Pro Plan',
--        299.00,
--        'GBP',
--        'Lifetime',
--        '["Feature 1", "Feature 2"]'::jsonb,
--        'https://example.com/logo.png',
--        'logo.png',
--        'https://example.com/background.jpg',
--        'background.jpg',
--        'https://example.com/intro.mp4',
--        'intro.mp4',
--        'pending'
--    );
--
-- 4. File Upload Fields:
--    - logo_url: URL of uploaded logo file
--    - logo_filename: Original filename of logo
--    - logo_mime_type: MIME type of logo (e.g., 'image/png')
--    - logo_size: Size of logo file in bytes
--    - background_url: URL of uploaded background/wallpaper (1920x1080)
--    - background_filename: Original filename of background
--    - background_mime_type: MIME type of background
--    - background_size: Size of background file in bytes
--    - intro_video_url: URL of uploaded intro video (3-8 seconds, MP4)
--    - intro_video_filename: Original filename of intro video
--    - intro_video_mime_type: MIME type of intro video (e.g., 'video/mp4')
--    - intro_video_size: Size of intro video file in bytes
--    - intro_video_duration: Duration of video (e.g., '5 seconds')
--
-- 5. Plan Information:
--    - plan_name: Name of the plan (e.g., "Pro Plan")
--    - plan_type: Type of plan (e.g., "Pro Plan", "Standard Plan")
--    - price: Price of the plan (NUMERIC)
--    - price_currency: Currency code (e.g., 'GBP', 'USD', 'INR')
--    - duration: Duration of the plan (e.g., "Lifetime", "1 Year")
--    - features: JSON array of plan features
--
-- 6. Status values:
--    - 'pending': New customization request
--    - 'in_progress': Being worked on
--    - 'completed': Completed
--    - 'cancelled': Cancelled by user
--    - 'rejected': Rejected by admin
--
-- 7. RLS policies ensure:
--    - Anyone (including anonymous users) can create customization forms
--    - Users can view their own customizations
--    - Admins can view, update, and delete all customizations
--
-- 8. The trigger automatically generates a unique customization number
--    in the format: CUST-YYYYMMDD-XXXXXX
--
-- ============================================

