-- ============================================
-- AUTO-CONFIRM USERS SQL
-- ============================================
-- This script auto-confirms all existing users
-- and sets up a trigger to auto-confirm new users
-- 
-- ⚠️ WARNING: This bypasses email confirmation
-- Only use for development/testing!
-- ============================================

-- Step 1: Auto-confirm all existing users
UPDATE auth.users
SET email_confirmed_at = COALESCE(email_confirmed_at, NOW())
WHERE email_confirmed_at IS NULL;

-- Step 2: Create function to auto-confirm new users
CREATE OR REPLACE FUNCTION public.auto_confirm_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Auto-confirm email when user is created
  NEW.email_confirmed_at = COALESCE(NEW.email_confirmed_at, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_created_auto_confirm ON auth.users;

-- Step 4: Create trigger to auto-confirm on user creation
CREATE TRIGGER on_auth_user_created_auto_confirm
  BEFORE INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.auto_confirm_new_user();

-- ============================================
-- ✅ Done! All users (existing and new) will be auto-confirmed
-- ============================================
-- 
-- To remove auto-confirmation later:
-- DROP TRIGGER IF EXISTS on_auth_user_created_auto_confirm ON auth.users;
-- DROP FUNCTION IF EXISTS public.auto_confirm_new_user();
-- ============================================







