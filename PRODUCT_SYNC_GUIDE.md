# Product Synchronization Guide

## Overview

The project has been converted to use **Supabase as the primary data source** for products while maintaining **backward compatibility** with the existing flow.

## How It Works

### 1. **Products are fetched from Supabase**
   - The site now fetches products from Supabase database
   - If Supabase is unavailable, it falls back to mock data (ensuring the site always works)
   - Changes in Supabase will reflect on the site after the next build

### 2. **Bidirectional Synchronization**

#### ✅ Removing from Supabase → Removes from Site
- When you delete/deactivate a product in Supabase, it will **not appear** on the site after rebuild
- Use `is_active = false` for soft delete (recommended)
- Or permanently delete from Supabase database

#### ✅ Removing from Site Code → Can Sync to Supabase
- You can now use admin functions to delete products from Supabase
- See "Product Management Functions" below

## Product Management Functions

### Available Functions

All product management functions are available in:
- `src/lib/supabase.ts` - Core functions
- `src/lib/product-management.ts` - Helper wrapper (easier to use)

### Usage Examples

```typescript
import { ProductManager } from './lib/product-management';

// Get all active products
const products = await ProductManager.getAll();

// Get all products (including inactive)
const allProducts = await ProductManager.getAllIncludingInactive();

// Get a product by slug
const product = await ProductManager.getBySlug('order-menu-system');

// Create a new product
const newProduct = await ProductManager.create({
  name: 'New Product',
  slug: 'new-product',
  description: 'Product description',
  short_description: 'Short desc',
  category: 'web',
  base_price: 10000,
  featured_image: 'https://example.com/image.jpg',
  gallery: [],
  features: ['Feature 1', 'Feature 2'],
  is_active: true,
  sort_order: 1,
});

// Update a product
await ProductManager.update('product-id', {
  base_price: 15000,
  description: 'Updated description',
});

// Delete (deactivate) a product - Recommended
await ProductManager.delete('product-id'); // Soft delete

// Permanently delete a product
await ProductManager.delete('product-id', true); // Hard delete

// Restore a deactivated product
await ProductManager.restore('product-id');
```

## How Changes Reflect on the Site

### For Static Sites (Current Setup)
1. **Build Time**: Products are fetched from Supabase during `npm run build`
2. **Deployment**: After build, changes in Supabase require a new build to appear
3. **Fallback**: If Supabase fails during build, mock data is used

### For Dynamic Sites (If Converted)
1. **Runtime**: Products are fetched from Supabase when pages load
2. **Immediate**: Changes in Supabase appear immediately without rebuild
3. **Fallback**: If Supabase fails, mock data is used

## Current Flow (Maintained)

✅ **All existing functionality is preserved:**
- Products pages work exactly as before
- Product detail pages work as before
- Cart functionality unchanged
- All existing features continue to work

✅ **Backward Compatible:**
- If Supabase is unavailable, mock data is used
- Site continues to function normally
- No breaking changes

## Database Schema Requirements

Make sure your Supabase `products` table has these columns:

```sql
- id (uuid, primary key)
- name (text)
- slug (text, unique)
- description (text)
- short_description (text)
- category (text: 'restaurant' | 'mobile' | 'tv' | 'web')
- base_price (numeric)
- featured_image (text)
- gallery (jsonb or text[])
- features (jsonb or text[])
- is_active (boolean, default true)
- sort_order (integer)
- created_at (timestamp)
- updated_at (timestamp)
```

## Testing

1. **Test Supabase Connection:**
   ```bash
   npm run build
   # Check console for: "✅ Loaded X products from Supabase"
   ```

2. **Test Fallback:**
   - Temporarily break Supabase connection
   - Run build again
   - Should see: "⚠️ No products in Supabase, using fallback mock data"

3. **Test Product Management:**
   - Use ProductManager functions in admin interface
   - Verify changes appear after rebuild

## Next Steps (Optional)

If you want **real-time updates** without rebuilding:

1. Convert to hybrid mode in `astro.config.mjs`:
   ```js
   export default defineConfig({
     output: 'hybrid', // or 'server'
   });
   ```

2. Products will then fetch at runtime instead of build time

## Support

- All functions have error handling and fallbacks
- Console logs show what's happening
- Site always works even if Supabase fails






