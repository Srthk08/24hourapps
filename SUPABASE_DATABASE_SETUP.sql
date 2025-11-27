-- ============================================
-- SUPABASE DATABASE SETUP SQL QUERIES
-- ============================================
-- Run these queries in your Supabase SQL Editor
-- to create the necessary tables for user accounts
-- ============================================

-- ============================================
-- 1. PROFILES TABLE
-- ============================================
-- This table stores user profile information
-- It's linked to Supabase Auth users via the 'id' field

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    phone TEXT,
    company_name TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'developer', 'support', 'menu_operator')),
    status TEXT NOT NULL DEFAULT 'pending_verification' CHECK (status IN ('active', 'inactive', 'suspended', 'pending_verification')),
    username TEXT,
    avatar_url TEXT,
    bio TEXT,
    website TEXT,
    location TEXT,
    timezone TEXT,
    language TEXT,
    preferences JSONB DEFAULT '{}'::jsonb,
    last_login_at TIMESTAMPTZ,
    login_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON public.profiles(status);

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Service role can insert profiles" ON public.profiles;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- RLS Policies for profiles table
-- Users can read their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.profiles
    FOR UPDATE
    USING (auth.uid() = id);

-- Service role can insert profiles (for signup)
CREATE POLICY "Service role can insert profiles"
    ON public.profiles
    FOR INSERT
    WITH CHECK (true);

-- Admins can view all profiles
CREATE POLICY "Admins can view all profiles"
    ON public.profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 2. USER ACTIVITY LOG TABLE
-- ============================================
-- This table logs user activities (login, signup, etc.)

CREATE TABLE IF NOT EXISTS public.user_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_user_activity_user_id ON public.user_activity_log(user_id);
CREATE INDEX IF NOT EXISTS idx_user_activity_action ON public.user_activity_log(action);
CREATE INDEX IF NOT EXISTS idx_user_activity_created_at ON public.user_activity_log(created_at);

-- Enable RLS
ALTER TABLE public.user_activity_log ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own activity logs" ON public.user_activity_log;
DROP POLICY IF EXISTS "Service role can insert activity logs" ON public.user_activity_log;
DROP POLICY IF EXISTS "Admins can view all activity logs" ON public.user_activity_log;

-- RLS Policies for user_activity_log
-- Users can view their own activity logs
CREATE POLICY "Users can view own activity logs"
    ON public.user_activity_log
    FOR SELECT
    USING (auth.uid() = user_id);

-- Service role can insert activity logs
CREATE POLICY "Service role can insert activity logs"
    ON public.user_activity_log
    FOR INSERT
    WITH CHECK (true);

-- Admins can view all activity logs
CREATE POLICY "Admins can view all activity logs"
    ON public.user_activity_log
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 3. FUNCTION: Auto-create profile on user signup
-- ============================================
-- This function automatically creates a profile when a user signs up

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        phone,
        company_name,
        role,
        status,
        username,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'phone', ''),
        COALESCE(NEW.raw_user_meta_data->>'company_name', ''),
        'customer',
        'pending_verification',
        COALESCE(
            LOWER(REGEXP_REPLACE(NEW.raw_user_meta_data->>'full_name', '[^a-zA-Z0-9]', '_', 'g')),
            SPLIT_PART(NEW.email, '@', 1)
        ),
        NOW(),
        NOW()
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to auto-create profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 4. FUNCTION: Update updated_at timestamp
-- ============================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for profiles table
DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 5. FUNCTION: Create profile for existing user (RPC)
-- ============================================
-- This function can be called if profile creation fails

CREATE OR REPLACE FUNCTION public.create_profile_for_existing_user(
    user_id UUID,
    user_email TEXT,
    user_full_name TEXT DEFAULT '',
    user_phone TEXT DEFAULT '',
    user_company_name TEXT DEFAULT '',
    user_role TEXT DEFAULT 'customer'
)
RETURNS void AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        phone,
        company_name,
        role,
        status,
        username,
        created_at,
        updated_at
    )
    VALUES (
        user_id,
        user_email,
        COALESCE(user_full_name, ''),
        COALESCE(user_phone, ''),
        COALESCE(user_company_name, ''),
        COALESCE(user_role, 'customer'),
        'pending_verification',
        COALESCE(
            LOWER(REGEXP_REPLACE(user_full_name, '[^a-zA-Z0-9]', '_', 'g')),
            SPLIT_PART(user_email, '@', 1)
        ),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE
    SET
        email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, profiles.full_name),
        phone = COALESCE(EXCLUDED.phone, profiles.phone),
        company_name = COALESCE(EXCLUDED.company_name, profiles.company_name),
        role = COALESCE(EXCLUDED.role, profiles.role),
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. GRANT PERMISSIONS
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.profiles TO anon, authenticated;
GRANT ALL ON public.user_activity_log TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_profile_for_existing_user(UUID, TEXT, TEXT, TEXT, TEXT, TEXT) TO anon, authenticated;

-- ============================================
-- NOTES:
-- ============================================
-- 1. After running these queries, make sure:
--    - Email confirmation is disabled in Supabase Auth settings (for testing)
--    - Or enable email confirmation and check email inbox
--
-- 2. To test if tables are created:
--    SELECT * FROM public.profiles LIMIT 1;
--    SELECT * FROM public.user_activity_log LIMIT 1;
--
-- 3. If you get permission errors, you may need to run as service_role
--    or adjust the RLS policies
--
-- 4. The trigger will automatically create a profile when a user signs up
--    via Supabase Auth
--
-- ============================================

