-- ============================================
-- SUPABASE PRODUCT PRICING DATABASE SETUP
-- ============================================
-- Run these queries in your Supabase SQL Editor
-- to create tables for storing project pricing data
-- ============================================

-- ============================================
-- 1. PRODUCTS TABLE
-- ============================================
-- This table stores product/service information with pricing

CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL,
    short_description TEXT,
    category TEXT NOT NULL CHECK (category IN ('restaurant', 'mobile', 'tv', 'web')),
    base_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    featured_image TEXT,
    gallery TEXT[] DEFAULT '{}',
    features TEXT[] DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT true,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for products table
CREATE INDEX IF NOT EXISTS idx_products_slug ON public.products(slug);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category);
CREATE INDEX IF NOT EXISTS idx_products_is_active ON public.products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_sort_order ON public.products(sort_order);

-- Enable Row Level Security (RLS)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Products are viewable by everyone" ON public.products;
DROP POLICY IF EXISTS "Admins can insert products" ON public.products;
DROP POLICY IF EXISTS "Admins can update products" ON public.products;
DROP POLICY IF EXISTS "Admins can delete products" ON public.products;

-- RLS Policies for products table
-- Everyone can view active products
CREATE POLICY "Products are viewable by everyone"
    ON public.products
    FOR SELECT
    USING (is_active = true);

-- Admins can view all products (including inactive)
CREATE POLICY "Admins can view all products"
    ON public.products
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can insert products
CREATE POLICY "Admins can insert products"
    ON public.products
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update products
CREATE POLICY "Admins can update products"
    ON public.products
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can delete products
CREATE POLICY "Admins can delete products"
    ON public.products
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 2. PRODUCT PLANS TABLE
-- ============================================
-- This table stores different pricing plans for each product

CREATE TABLE IF NOT EXISTS public.product_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    features TEXT[] DEFAULT '{}',
    delivery_days INTEGER NOT NULL DEFAULT 1,
    is_popular BOOLEAN NOT NULL DEFAULT false,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for product_plans table
CREATE INDEX IF NOT EXISTS idx_product_plans_product_id ON public.product_plans(product_id);
CREATE INDEX IF NOT EXISTS idx_product_plans_sort_order ON public.product_plans(sort_order);
CREATE INDEX IF NOT EXISTS idx_product_plans_is_popular ON public.product_plans(is_popular);

-- Enable Row Level Security (RLS)
ALTER TABLE public.product_plans ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Product plans are viewable by everyone" ON public.product_plans;
DROP POLICY IF EXISTS "Admins can manage product plans" ON public.product_plans;

-- RLS Policies for product_plans table
-- Everyone can view product plans
CREATE POLICY "Product plans are viewable by everyone"
    ON public.product_plans
    FOR SELECT
    USING (true);

-- Admins can manage product plans
CREATE POLICY "Admins can manage product plans"
    ON public.product_plans
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 3. CART ITEMS TABLE
-- ============================================
-- This table stores items in user shopping carts

CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.product_plans(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    custom_requirements JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, product_id, plan_id)
);

-- Create indexes for cart_items table
CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON public.cart_items(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product_id ON public.cart_items(product_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_plan_id ON public.cart_items(plan_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can insert own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can update own cart items" ON public.cart_items;
DROP POLICY IF EXISTS "Users can delete own cart items" ON public.cart_items;

-- RLS Policies for cart_items table
-- Users can view their own cart items
CREATE POLICY "Users can view own cart items"
    ON public.cart_items
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own cart items
CREATE POLICY "Users can insert own cart items"
    ON public.cart_items
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own cart items
CREATE POLICY "Users can update own cart items"
    ON public.cart_items
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own cart items
CREATE POLICY "Users can delete own cart items"
    ON public.cart_items
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 4. ORDERS TABLE
-- ============================================
-- This table stores customer orders

CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    order_number TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0,
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    payment_method TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for orders table
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON public.orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON public.orders(payment_status);

-- Enable Row Level Security (RLS)
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own orders" ON public.orders;
DROP POLICY IF EXISTS "Users can insert own orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can view all orders" ON public.orders;
DROP POLICY IF EXISTS "Admins can update orders" ON public.orders;

-- RLS Policies for orders table
-- Users can view their own orders
CREATE POLICY "Users can view own orders"
    ON public.orders
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own orders
CREATE POLICY "Users can insert own orders"
    ON public.orders
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Admins can view all orders
CREATE POLICY "Admins can view all orders"
    ON public.orders
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admins can update orders
CREATE POLICY "Admins can update orders"
    ON public.orders
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 5. ORDER ITEMS TABLE
-- ============================================
-- This table stores individual items within an order

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.product_plans(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total_price NUMERIC(12, 2) NOT NULL DEFAULT 0,
    custom_requirements JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for order_items table
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON public.order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_order_items_plan_id ON public.order_items(plan_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own order items" ON public.order_items;
DROP POLICY IF EXISTS "Users can insert own order items" ON public.order_items;
DROP POLICY IF EXISTS "Admins can view all order items" ON public.order_items;

-- RLS Policies for order_items table
-- Users can view order items for their own orders
CREATE POLICY "Users can view own order items"
    ON public.order_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE id = order_items.order_id AND user_id = auth.uid()
        )
    );

-- Users can insert order items for their own orders
CREATE POLICY "Users can insert own order items"
    ON public.order_items
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE id = order_items.order_id AND user_id = auth.uid()
        )
    );

-- Admins can view all order items
CREATE POLICY "Admins can view all order items"
    ON public.order_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- ============================================
-- 6. TRIGGER: Update updated_at timestamp
-- ============================================

-- Create trigger for products table
DROP TRIGGER IF EXISTS update_products_updated_at ON public.products;
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Create trigger for cart_items table
DROP TRIGGER IF EXISTS update_cart_items_updated_at ON public.cart_items;
CREATE TRIGGER update_cart_items_updated_at
    BEFORE UPDATE ON public.cart_items
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Create trigger for orders table
DROP TRIGGER IF EXISTS update_orders_updated_at ON public.orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- 7. FUNCTION: Generate unique order number
-- ============================================

CREATE OR REPLACE FUNCTION public.generate_order_number()
RETURNS TEXT AS $$
DECLARE
    new_order_number TEXT;
    order_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate order number: ORD-YYYYMMDD-HHMMSS-RANDOM
        new_order_number := 'ORD-' || 
                           TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
                           TO_CHAR(NOW(), 'HH24MISS') || '-' ||
                           UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
        
        -- Check if order number already exists
        SELECT EXISTS(SELECT 1 FROM public.orders WHERE order_number = new_order_number) INTO order_exists;
        
        -- Exit loop if order number is unique
        EXIT WHEN NOT order_exists;
    END LOOP;
    
    RETURN new_order_number;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 8. GRANT PERMISSIONS
-- ============================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON public.products TO anon, authenticated;
GRANT SELECT ON public.product_plans TO anon, authenticated;
GRANT ALL ON public.cart_items TO authenticated;
GRANT ALL ON public.orders TO authenticated;
GRANT ALL ON public.order_items TO authenticated;
GRANT EXECUTE ON FUNCTION public.generate_order_number() TO authenticated;

-- ============================================
-- 9. SAMPLE DATA INSERTION
-- ============================================
-- Insert sample products based on the pricing page

-- Insert Restaurant Menu System
INSERT INTO public.products (
    name, slug, description, short_description, category, base_price, 
    featured_image, features, is_active, sort_order
) VALUES (
    'Restaurant Menu System',
    'restaurant-menu-system',
    'Digital menu system with QR code integration and online ordering',
    'Digital menu system with QR code integration and online ordering',
    'restaurant',
    25000.00,
    '/images/products/restaurant-menu-system.jpg',
    ARRAY['QR Code Menu', 'Online Ordering', 'Real-time Updates'],
    true,
    1
) ON CONFLICT (slug) DO NOTHING;

-- Insert Android TV App
-- Update base price if product already exists
UPDATE public.products 
SET base_price = 9900.00, updated_at = NOW()
WHERE slug = 'android-tv-app';

INSERT INTO public.products (
    name, slug, description, short_description, category, base_price, 
    featured_image, features, is_active, sort_order
) VALUES (
    'Android TV App',
    'android-tv-app',
    'Custom Android TV applications with content management',
    'Custom Android TV applications with content management',
    'tv',
    9900.00,
    '/images/products/android-tv-app.jpg',
    ARRAY['Custom Design', 'Content Management', 'Remote Control Support'],
    true,
    2
) ON CONFLICT (slug) DO NOTHING;

-- Insert Streaming Mobile App
INSERT INTO public.products (
    name, slug, description, short_description, category, base_price, 
    featured_image, features, is_active, sort_order
) VALUES (
    'Streaming Mobile App',
    'streaming-mobile-app',
    'Professional streaming apps for iOS and Android',
    'Professional streaming apps for iOS and Android',
    'mobile',
    55000.00,
    '/images/products/streaming-mobile-app.jpg',
    ARRAY['Live Streaming', 'Video on Demand', 'User Authentication'],
    true,
    3
) ON CONFLICT (slug) DO NOTHING;

-- Insert Restaurant Website
INSERT INTO public.products (
    name, slug, description, short_description, category, base_price, 
    featured_image, features, is_active, sort_order
) VALUES (
    'Restaurant Website',
    'restaurant-website',
    'Professional restaurant websites with reservations',
    'Professional restaurant websites with reservations',
    'web',
    25000.00,
    '/images/products/restaurant-website.jpg',
    ARRAY['Responsive Design', 'Online Reservations', 'Menu Showcase'],
    true,
    4
) ON CONFLICT (slug) DO NOTHING;

-- Insert Order Menu System
INSERT INTO public.products (
    name, slug, description, short_description, category, base_price, 
    featured_image, features, is_active, sort_order
) VALUES (
    'Order Menu System',
    'order-menu-system',
    'Complete order management system with digital menu integration',
    'Complete order management system with digital menu integration',
    'restaurant',
    999.00,
    '/images/products/order-menu-system.jpg',
    ARRAY['Order Management', 'Digital Menu Integration', 'Real-time Tracking'],
    true,
    5
) ON CONFLICT (slug) DO NOTHING;

-- ============================================
-- 10. INSERT SAMPLE PRODUCT PLANS
-- ============================================

-- Get product IDs (assuming they were just inserted)
DO $$
DECLARE
    restaurant_menu_id UUID;
    android_tv_id UUID;
    streaming_app_id UUID;
    restaurant_website_id UUID;
    order_menu_id UUID;
BEGIN
    -- Get product IDs
    SELECT id INTO restaurant_menu_id FROM public.products WHERE slug = 'restaurant-menu-system';
    SELECT id INTO android_tv_id FROM public.products WHERE slug = 'android-tv-app';
    SELECT id INTO streaming_app_id FROM public.products WHERE slug = 'streaming-mobile-app';
    SELECT id INTO restaurant_website_id FROM public.products WHERE slug = 'restaurant-website';
    SELECT id INTO order_menu_id FROM public.products WHERE slug = 'order-menu-system';

    -- Insert plans for Restaurant Menu System
    IF restaurant_menu_id IS NOT NULL THEN
        INSERT INTO public.product_plans (product_id, name, description, price, features, delivery_days, is_popular, sort_order)
        VALUES 
        (restaurant_menu_id, 'Basic Plan', 'Essential QR code menu features', 25000.00, ARRAY['QR Code Menu', 'Basic Online Ordering'], 7, false, 1),
        (restaurant_menu_id, 'Pro Plan', 'Advanced features with real-time updates', 35000.00, ARRAY['QR Code Menu', 'Online Ordering', 'Real-time Updates', 'Analytics'], 7, true, 2),
        (restaurant_menu_id, 'Enterprise Plan', 'Complete solution with custom features', 50000.00, ARRAY['All Pro Features', 'Custom Branding', 'Priority Support', 'API Access'], 14, false, 3)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Insert plans for Android TV App
    IF android_tv_id IS NOT NULL THEN
        -- Update existing plans if they exist
        UPDATE public.product_plans 
        SET name = 'Standard', 
            description = 'Custom Android TV app with basic features',
            price = 9900.00,
            features = ARRAY['Custom Design', 'Content Management', 'Remote Control Support'],
            delivery_days = 14,
            is_popular = false,
            sort_order = 1,
            updated_at = NOW()
        WHERE product_id = android_tv_id AND (name = 'Standard Plan' OR name = 'Standard');
        
        UPDATE public.product_plans 
        SET name = 'Pro', 
            description = 'Advanced features with analytics',
            price = 29900.00,
            features = ARRAY['All Standard Features', 'Advanced Analytics', 'Multi-user Support', 'Custom Integrations'],
            delivery_days = 14,
            is_popular = true,
            sort_order = 2,
            updated_at = NOW()
        WHERE product_id = android_tv_id AND (name = 'Premium Plan' OR name = 'Pro');
        
        UPDATE public.product_plans 
        SET name = 'Pro Gold', 
            description = 'Complete solution with dedicated support',
            price = 44900.00,
            features = ARRAY['All Pro Features', 'Dedicated Support', 'Custom Development', 'White-label Option'],
            delivery_days = 21,
            is_popular = false,
            sort_order = 3,
            updated_at = NOW()
        WHERE product_id = android_tv_id AND (name = 'Enterprise Plan' OR name = 'Pro Gold');
        
        -- Insert new plans if they don't exist
        INSERT INTO public.product_plans (product_id, name, description, price, features, delivery_days, is_popular, sort_order)
        VALUES 
        (android_tv_id, 'Standard', 'Custom Android TV app with basic features', 9900.00, ARRAY['Custom Design', 'Content Management', 'Remote Control Support'], 14, false, 1),
        (android_tv_id, 'Pro', 'Advanced features with analytics', 29900.00, ARRAY['All Standard Features', 'Advanced Analytics', 'Multi-user Support', 'Custom Integrations'], 14, true, 2),
        (android_tv_id, 'Pro Gold', 'Complete solution with dedicated support', 44900.00, ARRAY['All Pro Features', 'Dedicated Support', 'Custom Development', 'White-label Option'], 21, false, 3)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Insert plans for Streaming Mobile App
    IF streaming_app_id IS NOT NULL THEN
        INSERT INTO public.product_plans (product_id, name, description, price, features, delivery_days, is_popular, sort_order)
        VALUES 
        (streaming_app_id, 'Basic Plan', 'Streaming app for iOS and Android', 55000.00, ARRAY['Live Streaming', 'Video on Demand', 'User Authentication'], 21, false, 1),
        (streaming_app_id, 'Pro Plan', 'Advanced streaming with monetization', 85000.00, ARRAY['All Basic Features', 'Subscription Management', 'Payment Integration', 'Analytics'], 21, true, 2),
        (streaming_app_id, 'Enterprise Plan', 'Complete streaming platform', 120000.00, ARRAY['All Pro Features', 'Multi-platform Support', 'CDN Integration', '24/7 Support'], 30, false, 3)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Insert plans for Restaurant Website
    IF restaurant_website_id IS NOT NULL THEN
        INSERT INTO public.product_plans (product_id, name, description, price, features, delivery_days, is_popular, sort_order)
        VALUES 
        (restaurant_website_id, 'Standard Plan', 'Professional restaurant website', 25000.00, ARRAY['Responsive Design', 'Online Reservations', 'Menu Showcase'], 7, false, 1),
        (restaurant_website_id, 'Premium Plan', 'Advanced website with SEO optimization', 40000.00, ARRAY['All Standard Features', 'SEO Optimization', 'Social Media Integration', 'Analytics'], 7, true, 2),
        (restaurant_website_id, 'Enterprise Plan', 'Complete solution with custom features', 60000.00, ARRAY['All Premium Features', 'Custom Development', 'E-commerce Integration', 'Priority Support'], 14, false, 3)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Insert plan for Order Menu System (single plan at ₹999)
    IF order_menu_id IS NOT NULL THEN
        INSERT INTO public.product_plans (product_id, name, description, price, features, delivery_days, is_popular, sort_order)
        VALUES 
        (order_menu_id, 'Common Plan', 'Complete order management system', 999.00, ARRAY['Order Management', 'Digital Menu Integration', 'Real-time Tracking', 'Payment Integration'], 1, true, 1)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- ============================================
-- NOTES:
-- ============================================
-- 1. After running these queries, verify tables were created:
--    SELECT table_name FROM information_schema.tables 
--    WHERE table_schema = 'public' 
--    AND table_name IN ('products', 'product_plans', 'cart_items', 'orders', 'order_items');
--
-- 2. Verify sample data was inserted:
--    SELECT * FROM public.products;
--    SELECT * FROM public.product_plans;
--
-- 3. To update pricing, use:
--    UPDATE public.products SET base_price = 30000.00 WHERE slug = 'restaurant-menu-system';
--    UPDATE public.product_plans SET price = 30000.00 WHERE product_id = (SELECT id FROM products WHERE slug = 'restaurant-menu-system') AND name = 'Basic Plan';
--
-- 4. To add a new product:
--    INSERT INTO public.products (name, slug, description, short_description, category, base_price, featured_image, features, is_active, sort_order)
--    VALUES ('Product Name', 'product-slug', 'Description', 'Short description', 'category', 10000.00, '/image.jpg', ARRAY['Feature 1', 'Feature 2'], true, 6);
--
-- 5. RLS policies ensure:
--    - All users can view active products and plans
--    - Only authenticated users can manage their cart and orders
--    - Only admins can manage products and view all orders
--
-- ============================================

