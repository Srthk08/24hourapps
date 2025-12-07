-- ============================================
-- ANDROID TV APP CUSTOMIZATION FORM TABLE
-- ============================================
-- SQL query to create table for storing Android TV App form data
-- Based on the form with: Name, Email, Phone, Logo, Background/Wallpaper, Intro Video
-- ============================================

-- Create table for Android TV App customization form submissions
CREATE TABLE IF NOT EXISTS public.android_tv_app_forms (
    -- Primary Key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- User Information (Required Fields)
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    
    -- Logo Upload (Required)
    logo_url TEXT,
    logo_filename TEXT,
    logo_mime_type TEXT,
    logo_size BIGINT, -- Size in bytes
    
    -- Background/Wallpaper Upload (Optional)
    -- Size: 1920x1080
    background_url TEXT,
    background_filename TEXT,
    background_mime_type TEXT,
    background_size BIGINT, -- Size in bytes
    background_width INTEGER, -- Should be 1920
    background_height INTEGER, -- Should be 1080
    
    -- Intro Video Upload (Optional)
    -- Requirements: 3-8 Seconds, MP4 video
    intro_video_url TEXT,
    intro_video_filename TEXT,
    intro_video_mime_type TEXT DEFAULT 'video/mp4',
    intro_video_size BIGINT, -- Size in bytes
    intro_video_duration TEXT, -- Duration in seconds (e.g., "5 seconds")
    
    -- Product & Plan Information
    product_name TEXT DEFAULT 'Android TV App',
    plan_name TEXT, -- e.g., "Pro Plan"
    plan_type TEXT, -- e.g., "Pro Plan"
    price NUMERIC(12, 2), -- e.g., 299.00
    price_currency TEXT DEFAULT 'GBP',
    duration TEXT, -- e.g., "Lifetime"
    features JSONB DEFAULT '[]'::jsonb, -- Array of features
    
    -- Status & Tracking
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'cancelled', 'rejected')),
    order_id UUID,
    payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_android_tv_app_forms_email ON public.android_tv_app_forms(email);
CREATE INDEX IF NOT EXISTS idx_android_tv_app_forms_phone_number ON public.android_tv_app_forms(phone_number);
CREATE INDEX IF NOT EXISTS idx_android_tv_app_forms_status ON public.android_tv_app_forms(status);
CREATE INDEX IF NOT EXISTS idx_android_tv_app_forms_payment_status ON public.android_tv_app_forms(payment_status);
CREATE INDEX IF NOT EXISTS idx_android_tv_app_forms_created_at ON public.android_tv_app_forms(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_android_tv_app_forms_order_id ON public.android_tv_app_forms(order_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.android_tv_app_forms ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Allow anyone (including anonymous users) to insert form data
CREATE POLICY "Public can insert Android TV app forms"
    ON public.android_tv_app_forms
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Allow users to view their own forms (by email)
CREATE POLICY "Users can view own Android TV app forms"
    ON public.android_tv_app_forms
    FOR SELECT
    USING (
        -- Authenticated users can view forms with their email
        (auth.uid() IS NOT NULL AND email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
        OR
        -- Allow viewing if email matches authenticated user's email
        (auth.uid() IS NOT NULL AND email = (SELECT email FROM public.profiles WHERE id = auth.uid()))
    );

-- Admins can view all forms
CREATE POLICY "Admins can view all Android TV app forms"
    ON public.android_tv_app_forms
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update forms
CREATE POLICY "Admins can update Android TV app forms"
    ON public.android_tv_app_forms
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete forms
CREATE POLICY "Admins can delete Android TV app forms"
    ON public.android_tv_app_forms
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- TRIGGER: Update updated_at timestamp
-- ============================================

CREATE OR REPLACE FUNCTION public.update_android_tv_app_forms_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating updated_at
DROP TRIGGER IF EXISTS update_android_tv_app_forms_updated_at_trigger ON public.android_tv_app_forms;
CREATE TRIGGER update_android_tv_app_forms_updated_at_trigger
    BEFORE UPDATE ON public.android_tv_app_forms
    FOR EACH ROW
    EXECUTE FUNCTION public.update_android_tv_app_forms_updated_at();

-- ============================================
-- GRANT PERMISSIONS
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.android_tv_app_forms TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_android_tv_app_forms_updated_at() TO anon, authenticated;

-- Ensure anonymous users can insert
GRANT INSERT ON public.android_tv_app_forms TO anon;
GRANT INSERT ON public.android_tv_app_forms TO authenticated;

-- ============================================
-- SAMPLE DATA INSERTION (for testing)
-- ============================================

-- Insert sample Android TV App form data
INSERT INTO public.android_tv_app_forms (
    name,
    email,
    phone_number,
    product_name,
    plan_name,
    plan_type,
    price,
    price_currency,
    duration,
    features,
    status,
    payment_status
) VALUES (
    'John Doe',
    'john.doe@example.com',
    '+919874588858',
    'Android TV App',
    'Pro Plan',
    'Pro Plan',
    299.00,
    'GBP',
    'Lifetime',
    '["Everything in Standard", "Unlimited DNS/Portals", "Intro Video", "Get All Future Updates in £19 Only"]'::jsonb,
    'pending',
    'pending'
) ON CONFLICT DO NOTHING;

-- ============================================
-- USAGE EXAMPLES
-- ============================================

-- Example 1: Insert a new form submission
/*
INSERT INTO public.android_tv_app_forms (
    name,
    email,
    phone_number,
    logo_url,
    logo_filename,
    logo_mime_type,
    logo_size,
    background_url,
    background_filename,
    background_mime_type,
    background_size,
    background_width,
    background_height,
    intro_video_url,
    intro_video_filename,
    intro_video_mime_type,
    intro_video_size,
    intro_video_duration,
    product_name,
    plan_name,
    plan_type,
    price,
    price_currency,
    duration,
    features,
    status,
    payment_status
) VALUES (
    'Jane Smith',
    'jane.smith@example.com',
    '+919874588859',
    'https://example.com/uploads/logo.png',
    'logo.png',
    'image/png',
    102400,
    'https://example.com/uploads/background.jpg',
    'background.jpg',
    'image/jpeg',
    2048000,
    1920,
    1080,
    'https://example.com/uploads/intro.mp4',
    'intro.mp4',
    'video/mp4',
    5120000,
    '5 seconds',
    'Android TV App',
    'Pro Plan',
    'Pro Plan',
    299.00,
    'GBP',
    'Lifetime',
    '["Everything in Standard", "Unlimited DNS/Portals", "Intro Video", "Get All Future Updates in £19 Only"]'::jsonb,
    'pending',
    'pending'
);
*/

-- Example 2: Query all pending forms
/*
SELECT 
    id,
    name,
    email,
    phone_number,
    product_name,
    plan_name,
    price,
    status,
    payment_status,
    created_at
FROM public.android_tv_app_forms
WHERE status = 'pending'
ORDER BY created_at DESC;
*/

-- Example 3: Update payment status after payment
/*
UPDATE public.android_tv_app_forms
SET payment_status = 'paid',
    status = 'in_progress',
    order_id = 'your-order-uuid-here'
WHERE id = 'form-uuid-here';
*/

-- ============================================
-- NOTES
-- ============================================
-- 1. Required Fields:
--    - name: Customer's name
--    - email: Customer's email address
--    - phone_number: Customer's phone number (format: +919874588858)
--
-- 2. File Upload Fields:
--    - logo_url: URL of uploaded logo file (required)
--    - logo_filename: Original filename of logo
--    - logo_mime_type: MIME type (e.g., 'image/png', 'image/jpeg')
--    - logo_size: File size in bytes
--
--    - background_url: URL of uploaded background/wallpaper (optional)
--    - background_filename: Original filename of background
--    - background_mime_type: MIME type (e.g., 'image/jpeg')
--    - background_size: File size in bytes
--    - background_width: Image width (should be 1920)
--    - background_height: Image height (should be 1080)
--
--    - intro_video_url: URL of uploaded intro video (optional)
--    - intro_video_filename: Original filename of intro video
--    - intro_video_mime_type: MIME type (default: 'video/mp4')
--    - intro_video_size: File size in bytes
--    - intro_video_duration: Duration in seconds (e.g., "5 seconds")
--      Requirements: 3-8 seconds, MP4 format
--
-- 3. Product & Plan Information:
--    - product_name: Default is 'Android TV App'
--    - plan_name: Name of the plan (e.g., "Pro Plan")
--    - plan_type: Type of plan (e.g., "Pro Plan")
--    - price: Price of the plan (e.g., 299.00)
--    - price_currency: Currency code (default: 'GBP')
--    - duration: Duration of the plan (e.g., "Lifetime")
--    - features: JSON array of plan features
--
-- 4. Status Values:
--    - status: 'pending', 'in_progress', 'completed', 'cancelled', 'rejected'
--    - payment_status: 'pending', 'paid', 'failed', 'refunded'
--
-- 5. RLS Policies:
--    - Anyone (including anonymous users) can create form submissions
--    - Users can view their own forms (by email)
--    - Admins can view, update, and delete all forms
--
-- 6. The trigger automatically updates the updated_at timestamp
--    whenever a row is updated
--
-- ============================================


