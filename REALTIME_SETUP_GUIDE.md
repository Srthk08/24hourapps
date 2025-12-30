# 🔄 Real-Time Setup Guide

## Problem
Prices are not updating on the website when you change them in Supabase.

## Solution
You need to enable real-time replication for your Supabase tables.

## Steps to Fix:

### Step 1: Enable Real-Time in Supabase

1. **Open Supabase Dashboard**
   - Go to https://supabase.com/dashboard
   - Select your project

2. **Open SQL Editor**
   - Click on **SQL Editor** in the left sidebar
   - Click **New Query**

3. **Run the Real-Time Setup SQL**
   - Open the file: `ENABLE_REALTIME.sql`
   - Copy ALL the content (Ctrl+A, Ctrl+C)
   - Paste into Supabase SQL Editor
   - Click **Run** (or press Ctrl+Enter)

4. **Verify Real-Time is Enabled**
   - Run this query to check:
   ```sql
   SELECT schemaname, tablename 
   FROM pg_publication_tables 
   WHERE pubname = 'supabase_realtime';
   ```
   - You should see: `products`, `product_plans`, `profiles`, `order_customizations`, `customization_forms`, `support_tickets`

### Step 2: Test the Updates

1. **Open your website** in a browser
2. **Open Browser Console** (F12 → Console tab)
3. **Change a price in Supabase**:
   - Go to Supabase → Table Editor → `products`
   - Edit a product's `base_price`
   - Save the change
4. **Watch the console** - You should see:
   - `🔄 Real-time update received for products: UPDATE`
   - `🔄 Updating product prices from Supabase...`
   - `✅ Updated price for [Product Name]: ₹[old] → ₹[new]`
5. **Check the website** - The price should update automatically with a green highlight animation

### Step 3: If Real-Time Still Doesn't Work

The code includes a **polling fallback** that checks for updates every 10 seconds. If real-time fails, prices will still update, just with a slight delay.

### Troubleshooting

**If prices still don't update:**

1. **Check Browser Console** for errors
2. **Verify Supabase Connection**:
   - Check if `window.supabase` exists in console
   - Try: `window.supabase.from('products').select('*').limit(1)`
3. **Check Real-Time Status**:
   - In Supabase Dashboard → Database → Replication
   - Verify tables are listed
4. **Manual Refresh**:
   - The page will automatically fetch latest prices on load
   - Refresh the page to see updates immediately

### What Changed

- ✅ Created `ENABLE_REALTIME.sql` - SQL to enable real-time replication
- ✅ Improved price update function - Better element finding
- ✅ Added polling fallback - Updates every 10 seconds if real-time fails
- ✅ Added better logging - Console shows what's happening
- ✅ Added visual feedback - Green animation when prices update

### Important Notes

- Real-time must be enabled in Supabase for instant updates
- If real-time is not enabled, polling will update prices every 10 seconds
- Prices are always fetched fresh on page load
- All changes are logged to browser console for debugging







