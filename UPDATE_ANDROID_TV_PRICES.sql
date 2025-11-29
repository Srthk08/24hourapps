-- ============================================
-- UPDATE ANDROID TV APP PLAN PRICES
-- ============================================
-- Run this script in Supabase SQL Editor to update
-- Android TV App plan prices to the new GBP-based values
-- 
-- Display Prices (shown on frontend):
-- 1. Standard: £99.00
-- 2. Pro: £299.00
-- 3. Pro Gold: £449.00
--
-- Database Prices (stored in INR, converted at £1 = ₹100):
-- 1. Standard: ₹9,900 (from £99)
-- 2. Pro: ₹29,900 (from £299)
-- 3. Pro Gold: ₹44,900 (from £449)
-- ============================================

-- Update Standard Plan
UPDATE public.product_plans 
SET 
    name = 'Standard',
    price = 9900.00,
    description = 'Custom Android TV app with basic features',
    features = ARRAY['Custom Design', 'Content Management', 'Remote Control Support'],
    delivery_days = 14,
    is_popular = false,
    sort_order = 1
WHERE product_id = (SELECT id FROM public.products WHERE slug = 'android-tv-app')
AND (name = 'Standard Plan' OR name = 'Standard');

-- Update Premium Plan to Pro
UPDATE public.product_plans 
SET 
    name = 'Pro',
    price = 29900.00,
    description = 'Advanced features with analytics',
    features = ARRAY['All Standard Features', 'Advanced Analytics', 'Multi-user Support', 'Custom Integrations'],
    delivery_days = 14,
    is_popular = true,
    sort_order = 2
WHERE product_id = (SELECT id FROM public.products WHERE slug = 'android-tv-app')
AND (name = 'Premium Plan' OR name = 'Pro');

-- Update Enterprise Plan to Pro Gold
UPDATE public.product_plans 
SET 
    name = 'Pro Gold',
    price = 44900.00,
    description = 'Complete solution with dedicated support',
    features = ARRAY['All Pro Features', 'Dedicated Support', 'Custom Development', 'White-label Option'],
    delivery_days = 21,
    is_popular = false,
    sort_order = 3
WHERE product_id = (SELECT id FROM public.products WHERE slug = 'android-tv-app')
AND (name = 'Enterprise Plan' OR name = 'Pro Gold');

-- Update base product price to match lowest plan
UPDATE public.products 
SET base_price = 9900.00, updated_at = NOW()
WHERE slug = 'android-tv-app';

-- ============================================
-- VERIFICATION QUERY
-- ============================================
-- Run this to verify the updates were successful
SELECT 
    pp.name as plan_name,
    pp.price as price_inr,
    CASE 
        WHEN pp.name = 'Standard' THEN '£99.00'
        WHEN pp.name = 'Pro' THEN '£299.00'
        WHEN pp.name = 'Pro Gold' THEN '£449.00'
        ELSE '₹' || pp.price::text
    END as display_price,
    pp.description,
    pp.delivery_days,
    pp.is_popular,
    pp.sort_order
FROM public.product_plans pp
JOIN public.products p ON pp.product_id = p.id
WHERE p.slug = 'android-tv-app'
ORDER BY pp.sort_order;

