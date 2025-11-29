# 📋 Product Pricing Database Setup Guide

## Overview
This guide explains how to set up the product pricing database in Supabase to store project pricing information.

## 🚀 Quick Start

### Step 1: Open Supabase Dashboard
1. Go to **https://supabase.com/dashboard**
2. **Sign in** to your account
3. **Select your project**

### Step 2: Open SQL Editor
1. In the left sidebar, click **SQL Editor**
2. Click **New Query** button (top right)

### Step 3: Run the SQL File
1. Open the file: `PRODUCT_PRICING_SETUP.sql`
2. **Select ALL** the content (Ctrl+A)
3. **Copy** it (Ctrl+C)
4. **Paste** into the Supabase SQL Editor
5. Click **Run** button (or press `Ctrl+Enter`)

### Step 4: Verify Setup
After running, verify the tables were created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('products', 'product_plans', 'cart_items', 'orders', 'order_items');
```

You should see:
- ✅ `products`
- ✅ `product_plans`
- ✅ `cart_items`
- ✅ `orders`
- ✅ `order_items`

## 📊 Database Schema

### 1. Products Table
Stores product/service information:
- `id` - Unique identifier (UUID)
- `name` - Product name
- `slug` - URL-friendly identifier (unique)
- `description` - Full description
- `short_description` - Brief description
- `category` - Product category ('restaurant', 'mobile', 'tv', 'web')
- `base_price` - Starting price (NUMERIC)
- `featured_image` - Main product image URL
- `gallery` - Array of additional image URLs
- `features` - Array of feature tags
- `is_active` - Whether product is active
- `sort_order` - Display order
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp

### 2. Product Plans Table
Stores different pricing plans for each product:
- `id` - Unique identifier (UUID)
- `product_id` - Reference to products table
- `name` - Plan name (e.g., "Basic Plan", "Pro Plan")
- `description` - Plan description
- `price` - Plan price (NUMERIC)
- `features` - Array of plan features
- `delivery_days` - Estimated delivery time
- `is_popular` - Whether this is the popular/recommended plan
- `sort_order` - Display order
- `created_at` - Creation timestamp

### 3. Cart Items Table
Stores items in user shopping carts:
- `id` - Unique identifier (UUID)
- `user_id` - Reference to profiles table
- `product_id` - Reference to products table
- `plan_id` - Reference to product_plans table
- `quantity` - Item quantity
- `custom_requirements` - JSON object for custom requirements
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp

### 4. Orders Table
Stores customer orders:
- `id` - Unique identifier (UUID)
- `user_id` - Reference to profiles table
- `order_number` - Unique order number (auto-generated)
- `status` - Order status ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')
- `total_amount` - Total order amount
- `payment_status` - Payment status ('pending', 'paid', 'failed', 'refunded')
- `payment_method` - Payment method used
- `notes` - Additional notes
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp

### 5. Order Items Table
Stores individual items within an order:
- `id` - Unique identifier (UUID)
- `order_id` - Reference to orders table
- `product_id` - Reference to products table
- `plan_id` - Reference to product_plans table
- `quantity` - Item quantity
- `unit_price` - Price per unit at time of order
- `total_price` - Total price for this item
- `custom_requirements` - JSON object for custom requirements
- `created_at` - Creation timestamp

## 📝 Sample Data Included

The SQL file includes sample data for 5 products:

1. **Restaurant Menu System** - ₹25,000
   - Features: QR Code Menu, Online Ordering, Real-time Updates
   - Plans: Basic (₹25,000), Pro (₹35,000), Enterprise (₹50,000)

2. **Android TV App** - ₹9,900
   - Features: Custom Design, Content Management, Remote Control Support
   - Plans: Standard (₹9,900), Pro (₹29,900), Pro Gold (₹44,900)

3. **Streaming Mobile App** - ₹55,000
   - Features: Live Streaming, Video on Demand, User Authentication
   - Plans: Basic (₹55,000), Pro (₹85,000), Enterprise (₹120,000)

4. **Restaurant Website** - ₹25,000
   - Features: Responsive Design, Online Reservations, Menu Showcase
   - Plans: Standard (₹25,000), Premium (₹40,000), Enterprise (₹60,000)

5. **Order Menu System** - ₹999
   - Features: Order Management, Digital Menu Integration, Real-time Tracking
   - Plan: Common Plan (₹999)

## 🔧 Common Operations

### View All Products
```sql
SELECT * FROM public.products WHERE is_active = true ORDER BY sort_order;
```

### View Product Plans
```sql
SELECT p.name as product_name, pp.name as plan_name, pp.price, pp.features
FROM public.product_plans pp
JOIN public.products p ON pp.product_id = p.id
WHERE p.is_active = true
ORDER BY p.sort_order, pp.sort_order;
```

### Update Product Price
```sql
UPDATE public.products 
SET base_price = 30000.00, updated_at = NOW()
WHERE slug = 'restaurant-menu-system';
```

### Update Plan Price
```sql
UPDATE public.product_plans 
SET price = 30000.00
WHERE product_id = (SELECT id FROM products WHERE slug = 'restaurant-menu-system') 
AND name = 'Basic Plan';
```

### Add New Product
```sql
INSERT INTO public.products (
    name, slug, description, short_description, category, base_price, 
    featured_image, features, is_active, sort_order
) VALUES (
    'New Product Name',
    'new-product-slug',
    'Full product description',
    'Short description',
    'web',  -- or 'restaurant', 'mobile', 'tv'
    15000.00,
    '/images/products/new-product.jpg',
    ARRAY['Feature 1', 'Feature 2', 'Feature 3'],
    true,
    6
);
```

### Add Plan to Product
```sql
INSERT INTO public.product_plans (
    product_id, name, description, price, features, delivery_days, is_popular, sort_order
) VALUES (
    (SELECT id FROM products WHERE slug = 'product-slug'),
    'New Plan Name',
    'Plan description',
    20000.00,
    ARRAY['Feature 1', 'Feature 2'],
    7,
    false,
    1
);
```

### Deactivate a Product (Soft Delete)
```sql
UPDATE public.products 
SET is_active = false, updated_at = NOW()
WHERE slug = 'product-slug';
```

### Reactivate a Product
```sql
UPDATE public.products 
SET is_active = true, updated_at = NOW()
WHERE slug = 'product-slug';
```

## 🔒 Security (RLS Policies)

The database uses Row Level Security (RLS) to ensure:

- ✅ **Public Access**: Everyone can view active products and all product plans
- ✅ **User Access**: Authenticated users can manage their own cart and orders
- ✅ **Admin Access**: Only admins can:
  - View all products (including inactive)
  - Create, update, and delete products
  - Manage product plans
  - View all orders

## ⚠️ Important Notes

1. **Currency**: All prices are stored in NUMERIC format (e.g., 25000.00 for ₹25,000)
2. **Images**: Update image paths to match your actual image locations
3. **Slugs**: Product slugs must be unique and URL-friendly
4. **Categories**: Must be one of: 'restaurant', 'mobile', 'tv', 'web'
5. **Order Numbers**: Automatically generated using the `generate_order_number()` function
6. **Timestamps**: `created_at` and `updated_at` are automatically managed by triggers

## 🐛 Troubleshooting

### Issue: "relation already exists"
**Solution**: The tables already exist. You can either:
- Drop existing tables first (be careful - this deletes data!)
- Or skip the CREATE TABLE statements and only run the data insertion

### Issue: "permission denied"
**Solution**: 
- Make sure you're logged in as project owner
- Or use the service role key for admin operations

### Issue: "duplicate key value violates unique constraint"
**Solution**: The sample data already exists. The SQL uses `ON CONFLICT DO NOTHING` to prevent errors, but you may want to update existing records instead.

### Issue: Sample data not appearing
**Solution**: 
1. Check if products were inserted:
   ```sql
   SELECT * FROM public.products;
   ```
2. Check if plans were inserted:
   ```sql
   SELECT * FROM public.product_plans;
   ```
3. If products exist but plans don't, run the plan insertion section separately

## 📚 Related Files

- `PRODUCT_PRICING_SETUP.sql` - Main SQL setup file
- `src/lib/supabase.ts` - TypeScript interfaces and functions
- `PRODUCT_SYNC_GUIDE.md` - Guide for syncing products with the frontend

## ✅ Verification Checklist

After running the SQL, verify:

- [ ] All 5 tables created successfully
- [ ] Sample products inserted (5 products)
- [ ] Sample plans inserted (multiple plans per product)
- [ ] Indexes created for performance
- [ ] RLS policies enabled
- [ ] Triggers working (updated_at auto-update)
- [ ] Permissions granted correctly

## 🎯 Next Steps

1. **Update Images**: Replace placeholder image paths with actual image URLs
2. **Customize Pricing**: Update prices to match your requirements
3. **Add More Products**: Insert additional products as needed
4. **Test Frontend**: Verify products display correctly on your website
5. **Set Up Admin Panel**: Create admin interface to manage products

---

**Need Help?** Check the main `SUPABASE_DATABASE_SETUP.sql` file for user account setup, or refer to `HOW_TO_RUN_SQL.md` for general SQL execution instructions.

