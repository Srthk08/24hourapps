-- SQL Script to Remove Order Menu System from Database
-- Run this script in your Supabase SQL editor to completely remove the Order Menu System product

-- 1. Delete product plans associated with Order Menu System
DELETE FROM public.product_plans 
WHERE product_id IN (
    SELECT id FROM public.products WHERE slug = 'order-menu-system'
);

-- 2. Delete the Order Menu System product
DELETE FROM public.products 
WHERE slug = 'order-menu-system';

-- 3. Verify deletion (should return 0 rows)
SELECT * FROM public.products WHERE slug = 'order-menu-system';








