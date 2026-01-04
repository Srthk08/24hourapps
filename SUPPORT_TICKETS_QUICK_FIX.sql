-- ============================================
-- QUICK FIX: Add Missing Columns to support_tickets
-- ============================================
-- Run this if you already have the support_tickets table
-- and need to add the missing columns that the application expects
-- ============================================

-- Add ticket_number column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'ticket_number'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN ticket_number TEXT;
        -- Create unique index
        CREATE UNIQUE INDEX IF NOT EXISTS idx_support_tickets_ticket_number ON public.support_tickets(ticket_number);
    END IF;
END $$;

-- Add customer_email column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'customer_email'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN customer_email TEXT;
        -- Copy email to customer_email for existing rows
        UPDATE public.support_tickets 
        SET customer_email = COALESCE(email, 'unknown@example.com') 
        WHERE customer_email IS NULL;
        -- Make it NOT NULL after populating
        ALTER TABLE public.support_tickets ALTER COLUMN customer_email SET NOT NULL;
        -- Create index
        CREATE INDEX IF NOT EXISTS idx_support_tickets_customer_email ON public.support_tickets(customer_email);
    ELSE
        -- If column exists but has NULL values, populate them
        UPDATE public.support_tickets 
        SET customer_email = COALESCE(customer_email, email, 'unknown@example.com') 
        WHERE customer_email IS NULL;
    END IF;
END $$;

-- Add user_email column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'user_email'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN user_email TEXT;
        -- Copy email to user_email for existing rows
        UPDATE public.support_tickets 
        SET user_email = COALESCE(email, customer_email) 
        WHERE user_email IS NULL;
        -- Create index
        CREATE INDEX IF NOT EXISTS idx_support_tickets_user_email ON public.support_tickets(user_email);
    END IF;
END $$;

-- Add customer_name column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'support_tickets' 
        AND column_name = 'customer_name'
    ) THEN
        ALTER TABLE public.support_tickets ADD COLUMN customer_name TEXT;
    END IF;
END $$;

-- Make email nullable if it's currently NOT NULL (for backward compatibility)
DO $$ 
BEGIN
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

-- Update RLS policies to include new columns
DROP POLICY IF EXISTS "Users can view own tickets" ON public.support_tickets;
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

-- Verify columns were added
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'support_tickets'
ORDER BY ordinal_position;

-- ============================================
-- DONE! The missing columns have been added.
-- ============================================






