-- ============================================
-- SUPABASE CONTACT US DATABASE SETUP
-- ============================================
-- Run these queries in your Supabase SQL Editor
-- to create table for storing contact form submissions
-- ============================================

-- ============================================
-- 1. CONTACT SUBMISSIONS TABLE
-- ============================================
-- This table stores contact form submissions from the "Send us a message" form

CREATE TABLE IF NOT EXISTS public.contact_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone_country_code TEXT,
    phone_number TEXT,
    phone TEXT,
    company_name TEXT,
    project_type TEXT,
    project_details TEXT,
    message TEXT,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'read', 'replied', 'archived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add missing columns if table already exists (for existing installations)
DO $$ 
BEGIN
    -- Add phone column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions' 
        AND column_name = 'phone'
    ) THEN
        ALTER TABLE public.contact_submissions ADD COLUMN phone TEXT;
    END IF;
    
    -- Add message column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions' 
        AND column_name = 'message'
    ) THEN
        ALTER TABLE public.contact_submissions ADD COLUMN message TEXT;
    END IF;
    
    -- Add user_id column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'contact_submissions' 
        AND column_name = 'user_id'
    ) THEN
        ALTER TABLE public.contact_submissions ADD COLUMN user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Create indexes for contact_submissions table
CREATE INDEX IF NOT EXISTS idx_contact_submissions_email ON public.contact_submissions(email);
CREATE INDEX IF NOT EXISTS idx_contact_submissions_status ON public.contact_submissions(status);
CREATE INDEX IF NOT EXISTS idx_contact_submissions_created_at ON public.contact_submissions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_contact_submissions_project_type ON public.contact_submissions(project_type);
CREATE INDEX IF NOT EXISTS idx_contact_submissions_user_id ON public.contact_submissions(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Anyone can submit contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Public can insert contact forms" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can view all contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can update contact submissions" ON public.contact_submissions;
DROP POLICY IF EXISTS "Admins can delete contact submissions" ON public.contact_submissions;

-- RLS Policies for contact_submissions table
-- Anyone (including anonymous users) can submit contact forms
-- This policy allows both authenticated and anonymous users to insert
-- Using TO public ensures it works for all roles
-- Note: For INSERT policies, only WITH CHECK is used (USING doesn't apply)
CREATE POLICY "Public can insert contact forms"
    ON public.contact_submissions
    FOR INSERT
    TO public
    WITH CHECK (true);
    
-- Additional policy for anonymous users (explicit)
CREATE POLICY "Allow anonymous inserts"
    ON public.contact_submissions
    FOR INSERT
    TO anon
    WITH CHECK (true);
    
-- Additional policy for authenticated users (explicit)
CREATE POLICY "Allow authenticated inserts"
    ON public.contact_submissions
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Admins can view all contact submissions
CREATE POLICY "Admins can view all contact submissions"
    ON public.contact_submissions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update contact submissions (e.g., change status)
CREATE POLICY "Admins can update contact submissions"
    ON public.contact_submissions
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete contact submissions
CREATE POLICY "Admins can delete contact submissions"
    ON public.contact_submissions
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 2. TRIGGER: Update updated_at timestamp
-- ============================================

-- Create trigger for contact_submissions table
DROP TRIGGER IF EXISTS update_contact_submissions_updated_at ON public.contact_submissions;
CREATE TRIGGER update_contact_submissions_updated_at
    BEFORE UPDATE ON public.contact_submissions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 3. FUNCTION: Validate email format (optional helper)
-- ============================================

CREATE OR REPLACE FUNCTION public.validate_email(email_address TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- 4. GRANT PERMISSIONS
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.contact_submissions TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.validate_email(TEXT) TO anon, authenticated;

-- Ensure anonymous users can insert (explicit grant)
GRANT INSERT ON public.contact_submissions TO anon;
GRANT INSERT ON public.contact_submissions TO authenticated;

-- ============================================
-- 5. SAMPLE DATA INSERTION (for testing)
-- ============================================

-- Insert sample contact submission
INSERT INTO public.contact_submissions (
    first_name,
    last_name,
    email,
    phone_country_code,
    phone_number,
    phone,
    company_name,
    project_type,
    project_details,
    message
) VALUES (
    'Raghav',
    'Sharma',
    'raghav@gmail.com',
    'IN +91',
    '1236547896',
    '+911236547896',
    'Rag Company',
    'Web Development',
    'I need a custom website for my business with e-commerce functionality.',
    'I need a custom website for my business with e-commerce functionality.'
) ON CONFLICT DO NOTHING;

-- ============================================
-- NOTES:
-- ============================================
-- 1. After running these queries, verify table was created:
--    SELECT table_name FROM information_schema.tables 
--    WHERE table_schema = 'public' 
--    AND table_name = 'contact_submissions';
--
-- 2. Verify sample data was inserted:
--    SELECT * FROM public.contact_submissions;
--
-- 3. To insert a new contact submission from your application:
--    INSERT INTO public.contact_submissions (
--        first_name, last_name, email, phone, 
--        company_name, project_type, project_details, message
--    ) VALUES (
--        'John', 'Doe', 'john@example.com', '+11234567890', 
--        'Acme Corp', 'Mobile App', 'Need a mobile app...', 'Need a mobile app...'
--    );
--
-- 4. To update submission status (admin only):
--    UPDATE public.contact_submissions 
--    SET status = 'read' 
--    WHERE id = 'submission-uuid-here';
--
-- 5. RLS policies ensure:
--    - Anyone (including anonymous users) can submit contact forms
--    - Only admins can view, update, or delete contact submissions
--
-- 6. Phone number format:
--    - phone: Store the complete phone number with country code (e.g., '+911236547896', '+11234567890')
--    - phone_country_code: Store the country code (e.g., 'IN +91', 'US +1') - optional, for backward compatibility
--    - phone_number: Store the actual phone number without country code - optional, for backward compatibility
--
-- 7. Project types can be customized based on your needs:
--    Common values: 'Web Development', 'Mobile App', 'E-commerce', 
--    'Restaurant System', 'Custom Solution', etc.
--
-- 8. TROUBLESHOOTING RLS ISSUES:
--    If you still get "row-level security policy" errors after running this script:
--    
--    a) Verify the INSERT policy exists:
--       SELECT * FROM pg_policies WHERE tablename = 'contact_submissions' AND policyname = 'Public can insert contact forms';
--    
--    b) Test the policy manually:
--       SET ROLE anon;
--       INSERT INTO public.contact_submissions (first_name, last_name, email, message) 
--       VALUES ('Test', 'User', 'test@example.com', 'Test message');
--       RESET ROLE;
--    
--    c) If still failing, temporarily disable RLS to test (NOT RECOMMENDED FOR PRODUCTION):
--       ALTER TABLE public.contact_submissions DISABLE ROW LEVEL SECURITY;
--       -- Test your insert, then re-enable:
--       ALTER TABLE public.contact_submissions ENABLE ROW LEVEL SECURITY;
--    
--    d) Make sure you've run ALL the GRANT statements above
--
-- 9. QUICK FIX SCRIPT (Run this separately if RLS errors persist):
--    Copy and run this in Supabase SQL Editor if the main script doesn't fix the issue:
--
--    -- Drop and recreate the INSERT policy
--    DROP POLICY IF EXISTS "Public can insert contact forms" ON public.contact_submissions;
--    DROP POLICY IF EXISTS "Anyone can submit contact forms" ON public.contact_submissions;
--    
--    CREATE POLICY "Public can insert contact forms"
--        ON public.contact_submissions
--        FOR INSERT
--        TO public
--        WITH CHECK (true);
--    
--    -- Ensure grants are in place
--    GRANT INSERT ON public.contact_submissions TO anon;
--    GRANT INSERT ON public.contact_submissions TO authenticated;
--
-- ============================================

