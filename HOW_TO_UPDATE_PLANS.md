# How to Update Android TV App Plans

## Step 1: Run the SQL Update Script

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to **SQL Editor** (left sidebar)
4. Open the file `UPDATE_ANDROID_TV_PRICES.sql`
5. Copy the entire SQL script
6. Paste it into the SQL Editor
7. Click **Run** or press `Ctrl+Enter`

## Step 2: Verify the Update

After running the script, run this verification query in the SQL Editor:

```sql
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
    pp.features,
    pp.delivery_days,
    pp.is_popular,
    pp.sort_order
FROM public.product_plans pp
JOIN public.products p ON pp.product_id = p.id
WHERE p.slug = 'android-tv-app'
ORDER BY pp.sort_order;
```

You should see:
- **Standard**: £99.00 with features: Unlimited Customers, Name/Logo/Background customization, Free Panel, Single Portals/DNS
- **Pro**: £299.00 with features: Everything in Standard, Unlimited DNS/Portals, Intro Video, Future Updates in £19
- **Pro Gold**: £449.00 with features: Everything in Pro, All Future updates at ZERO cost

## Step 3: Clear Browser Cache

After updating the database:
1. Hard refresh your browser: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
2. Or clear browser cache and reload the page

## Step 4: Check the Frontend

1. Navigate to the Android TV App product page
2. You should see the updated plan features and descriptions
3. The customization form should show/hide Intro Video based on the selected plan

## Troubleshooting

If you still see old content:
1. Check if the SQL script ran successfully (no errors in SQL Editor)
2. Verify the data in Supabase using the verification query above
3. Clear browser cache completely
4. Check browser console for any errors
5. Make sure you're looking at the correct product (android-tv-app)







