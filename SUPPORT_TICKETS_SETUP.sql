-- ============================================
-- SUPABASE SUPPORT TICKETS DATABASE SETUP
-- ============================================
-- Run these queries in your Supabase SQL Editor
-- to create tables for storing support tickets and admin replies
-- ============================================

-- ============================================
-- 1. SUPPORT TICKETS TABLE
-- ============================================
-- This table stores support ticket submissions from the "Create Support Ticket" form
-- Based on the form fields: Subject, Email, Priority, Description

CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number TEXT UNIQUE,
    subject TEXT NOT NULL,
    email TEXT,
    customer_email TEXT NOT NULL,
    user_email TEXT,
    customer_name TEXT,
    priority TEXT NOT NULL CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    description TEXT NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Add missing columns if table already exists (for existing installations)
DO $$ 
BEGIN
    -- Add ticket_number column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'ticket_number'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN ticket_number TEXT UNIQUE;
    END IF;
    
    -- Add customer_email column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'customer_email'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN customer_email TEXT;
        -- Copy email to customer_email if email exists
        UPDATE public.support_tickets SET customer_email = COALESCE(email, 'unknown@example.com') WHERE customer_email IS NULL;
        -- Make customer_email NOT NULL after migration (only if no NULL values exist)
        ALTER TABLE public.support_tickets ALTER COLUMN customer_email SET NOT NULL;
    ELSE
        -- If column exists, ensure it's populated from email if needed
        UPDATE public.support_tickets SET customer_email = COALESCE(customer_email, email, 'unknown@example.com') WHERE customer_email IS NULL;
    END IF;
    
    -- Add user_email column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'user_email'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN user_email TEXT;
    END IF;
    
    -- Add customer_name column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'customer_name'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN customer_name TEXT;
    END IF;
    
    -- Make email nullable if it doesn't exist or is required
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'email'
        AND is_nullable = 'NO'
    ) THEN
        ALTER TABLE public.support_tickets ALTER COLUMN email DROP NOT NULL;
    END IF;
END $$;

-- Create indexes for support_tickets table
CREATE INDEX IF NOT EXISTS idx_support_tickets_ticket_number ON public.support_tickets(ticket_number);
CREATE INDEX IF NOT EXISTS idx_support_tickets_email ON public.support_tickets(email);
CREATE INDEX IF NOT EXISTS idx_support_tickets_customer_email ON public.support_tickets(customer_email);
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_email ON public.support_tickets(user_email);
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON public.support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_priority ON public.support_tickets(priority);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON public.support_tickets(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can create support tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Public can insert support tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Allow anonymous inserts" ON public.support_tickets;
DROP POLICY IF EXISTS "Allow authenticated inserts" ON public.support_tickets;
DROP POLICY IF EXISTS "Users can view own tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Admins can view all tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Admins can update tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Admins can delete tickets" ON public.support_tickets;

-- RLS Policies for support_tickets table
-- Anyone (including anonymous users) can create support tickets
CREATE POLICY "Public can insert support tickets"
    ON public.support_tickets
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Additional policy for anonymous users (explicit)
CREATE POLICY "Allow anonymous inserts"
    ON public.support_tickets
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- Additional policy for authenticated users (explicit)
CREATE POLICY "Allow authenticated inserts"
    ON public.support_tickets
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Users can view their own tickets (by email or user_id)
CREATE POLICY "Users can view own tickets"
    ON public.support_tickets
    FOR SELECT
    USING (
        -- Authenticated users can view tickets associated with their user_id
        (auth.uid() IS NOT NULL AND user_id = auth.uid())
        OR
        -- Users can view tickets with their email (for anonymous users who created tickets)
        (customer_email = (SELECT email FROM public.profiles WHERE id = auth.uid()))
        OR
        (user_email = (SELECT email FROM public.profiles WHERE id = auth.uid()))
        OR
        (email = (SELECT email FROM public.profiles WHERE id = auth.uid()))
        OR
        -- Allow viewing if email matches authenticated user's email
        (auth.uid() IS NOT NULL AND customer_email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
    );

-- Admins can view all tickets
CREATE POLICY "Admins can view all tickets"
    ON public.support_tickets
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update tickets (e.g., change status, priority)
CREATE POLICY "Admins can update tickets"
    ON public.support_tickets
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete tickets
CREATE POLICY "Admins can delete tickets"
    ON public.support_tickets
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 2. SUPPORT TICKET REPLIES TABLE
-- ============================================
-- This table stores replies to support tickets (admin replies and user responses)

CREATE TABLE IF NOT EXISTS public.support_ticket_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
    reply_text TEXT NOT NULL,
    replied_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    is_admin_reply BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for support_ticket_replies table
CREATE INDEX IF NOT EXISTS idx_ticket_replies_ticket_id ON public.support_ticket_replies(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_replies_replied_by ON public.support_ticket_replies(replied_by);
CREATE INDEX IF NOT EXISTS idx_ticket_replies_created_at ON public.support_ticket_replies(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ticket_replies_is_admin ON public.support_ticket_replies(is_admin_reply);

-- Enable Row Level Security (RLS)
ALTER TABLE public.support_ticket_replies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view replies for own tickets" ON public.support_ticket_replies;
DROP POLICY IF EXISTS "Admins can view all replies" ON public.support_ticket_replies;
DROP POLICY IF EXISTS "Admins can create replies" ON public.support_ticket_replies;
DROP POLICY IF EXISTS "Users can create replies for own tickets" ON public.support_ticket_replies;
DROP POLICY IF EXISTS "Admins can update replies" ON public.support_ticket_replies;
DROP POLICY IF EXISTS "Admins can delete replies" ON public.support_ticket_replies;

-- RLS Policies for support_ticket_replies table
-- Users can view replies for their own tickets
CREATE POLICY "Users can view replies for own tickets"
    ON public.support_ticket_replies
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.support_tickets st
            WHERE st.id = support_ticket_replies.ticket_id
            AND (
                (st.user_id = auth.uid())
                OR
                (st.customer_email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
                OR
                (st.user_email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
                OR
                (st.email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
            )
        )
    );

-- Admins can view all replies
CREATE POLICY "Admins can view all replies"
    ON public.support_ticket_replies
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can create replies
CREATE POLICY "Admins can create replies"
    ON public.support_ticket_replies
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
        AND is_admin_reply = true
    );

-- Users can create replies for their own tickets
CREATE POLICY "Users can create replies for own tickets"
    ON public.support_ticket_replies
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.support_tickets st
            WHERE st.id = support_ticket_replies.ticket_id
            AND (
                (st.user_id = auth.uid())
                OR
                (st.customer_email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
                OR
                (st.user_email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
                OR
                (st.email IN (SELECT email FROM public.profiles WHERE id = auth.uid()))
            )
        )
        AND is_admin_reply = false
    );

-- Admins can update replies
CREATE POLICY "Admins can update replies"
    ON public.support_ticket_replies
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete replies
CREATE POLICY "Admins can delete replies"
    ON public.support_ticket_replies
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 3. TRIGGER: Update updated_at timestamp for tickets
-- ============================================

-- Ensure the update_updated_at_column function exists
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for support_tickets table
DROP TRIGGER IF EXISTS update_support_tickets_updated_at ON public.support_tickets;
CREATE TRIGGER update_support_tickets_updated_at
    BEFORE UPDATE ON public.support_tickets
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 4. TRIGGER: Auto-update ticket status when admin replies
-- ============================================
-- This trigger automatically updates the ticket status to 'in_progress' 
-- when an admin replies to a ticket

CREATE OR REPLACE FUNCTION public.handle_admin_reply()
RETURNS TRIGGER AS $$
BEGIN
    -- Update ticket status to 'in_progress' when admin replies
    IF NEW.is_admin_reply = true THEN
        UPDATE public.support_tickets
        SET status = CASE 
            WHEN status = 'open' THEN 'in_progress'
            ELSE status
        END,
        updated_at = NOW()
        WHERE id = NEW.ticket_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for admin replies
DROP TRIGGER IF EXISTS on_admin_reply ON public.support_ticket_replies;
CREATE TRIGGER on_admin_reply
    AFTER INSERT ON public.support_ticket_replies
    FOR EACH ROW
    WHEN (NEW.is_admin_reply = true)
    EXECUTE FUNCTION public.handle_admin_reply();

-- ============================================
-- 5. FUNCTION: Validate email format (optional helper)
-- ============================================

CREATE OR REPLACE FUNCTION public.validate_email(email_address TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN email_address ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- ============================================
-- 6. GRANT PERMISSIONS
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.support_tickets TO anon, authenticated;
GRANT ALL ON public.support_ticket_replies TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.validate_email(TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.handle_admin_reply() TO anon, authenticated;

-- Ensure anonymous users can insert (explicit grant)
GRANT INSERT ON public.support_tickets TO anon;
GRANT INSERT ON public.support_tickets TO authenticated;
GRANT INSERT ON public.support_ticket_replies TO anon;
GRANT INSERT ON public.support_ticket_replies TO authenticated;

-- ============================================
-- 7. SAMPLE DATA INSERTION (for testing)
-- ============================================

-- Insert sample support ticket
INSERT INTO public.support_tickets (
    ticket_number,
    subject,
    customer_email,
    email,
    user_email,
    customer_name,
    priority,
    description
) VALUES (
    'TKT-' || EXTRACT(EPOCH FROM NOW())::BIGINT,
    'Login issue with my account',
    'abhi123@gmail.com',
    'abhi123@gmail.com',
    'abhi123@gmail.com',
    'Abhi',
    'high',
    'I am unable to login to my account. I keep getting an error message saying "Invalid credentials" even though I am using the correct password. Please help me resolve this issue.'
) ON CONFLICT DO NOTHING;

-- Insert sample admin reply (if admin user exists)
-- Note: Replace 'admin-user-id-here' with actual admin user UUID
-- INSERT INTO public.support_ticket_replies (
--     ticket_id,
--     reply_text,
--     replied_by,
--     is_admin_reply
-- ) VALUES (
--     (SELECT id FROM public.support_tickets WHERE email = 'abhi123@gmail.com' LIMIT 1),
--     'Thank you for contacting us. We have reset your password. Please check your email for the reset link.',
--     (SELECT id FROM public.profiles WHERE role = 'admin' LIMIT 1),
--     true
-- ) ON CONFLICT DO NOTHING;

-- ============================================
-- NOTES:
-- ============================================
-- 1. After running these queries, verify tables were created:
--    SELECT table_name FROM information_schema.tables 
--    WHERE table_schema = 'public' 
--    AND table_name IN ('support_tickets', 'support_ticket_replies');
--
-- 2. Verify sample data was inserted:
--    SELECT * FROM public.support_tickets;
--    SELECT * FROM public.support_ticket_replies;
--
-- 3. To create a new support ticket from your application:
--    INSERT INTO public.support_tickets (
--        ticket_number, subject, customer_email, user_email, customer_name, priority, description
--    ) VALUES (
--        'TKT-' || EXTRACT(EPOCH FROM NOW())::BIGINT,
--        'My issue subject',
--        'user@example.com',
--        'user@example.com',
--        'User Name',
--        'medium',
--        'Detailed description of the issue...'
--    );
--
-- 4. To create an admin reply:
--    INSERT INTO public.support_ticket_replies (
--        ticket_id, reply_text, replied_by, is_admin_reply
--    ) VALUES (
--        'ticket-uuid-here',
--        'Admin reply message here',
--        'admin-user-uuid-here',
--        true
--    );
--
-- 5. To create a user reply:
--    INSERT INTO public.support_ticket_replies (
--        ticket_id, reply_text, replied_by, is_admin_reply
--    ) VALUES (
--        'ticket-uuid-here',
--        'User reply message here',
--        'user-uuid-here',
--        false
--    );
--
-- 6. To update ticket status (admin only):
--    UPDATE public.support_tickets 
--    SET status = 'resolved' 
--    WHERE id = 'ticket-uuid-here';
--
-- 7. Priority levels:
--    - 'low': Low priority issues
--    - 'medium': Medium priority issues
--    - 'high': High priority issues
--    - 'urgent': Urgent issues requiring immediate attention
--
-- 8. Ticket statuses:
--    - 'open': New ticket, not yet addressed
--    - 'in_progress': Ticket is being worked on
--    - 'resolved': Issue has been resolved
--    - 'closed': Ticket is closed
--
-- 9. RLS policies ensure:
--    - Anyone (including anonymous users) can create support tickets
--    - Users can view their own tickets and replies
--    - Admins can view, update, and delete all tickets and replies
--    - Admins can create replies (marked as admin replies)
--    - Users can create replies for their own tickets (marked as user replies)
--
-- 10. The trigger automatically updates ticket status to 'in_progress' 
--     when an admin replies to an 'open' ticket
--
-- 11. TROUBLESHOOTING RLS ISSUES:
--     If you get "row-level security policy" errors:
--     
--     a) Verify the INSERT policy exists:
--        SELECT * FROM pg_policies 
--        WHERE tablename = 'support_tickets' 
--        AND policyname = 'Public can insert support tickets';
--     
--     b) Test the policy manually:
--        SET ROLE anon;
--        INSERT INTO public.support_tickets (subject, email, priority, description) 
--        VALUES ('Test', 'test@example.com', 'low', 'Test description');
--        RESET ROLE;
--     
--     c) Make sure you've run ALL the GRANT statements above
--
-- ============================================

