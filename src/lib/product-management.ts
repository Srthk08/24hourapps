/**
 * Product Management Helper
 * 
 * This file provides easy access to product management functions.
 * Use these functions to manage products in Supabase from admin interfaces.
 * 
 * IMPORTANT: Changes in Supabase will automatically reflect on the site
 * after the next build (for static sites) or immediately (for dynamic sites).
 */

import {
  createProduct,
  updateProduct,
  deleteProduct,
  restoreProduct,
  getAllProducts,
  getProductPlans,
  getProducts as getSupabaseProducts,
  getProductBySlug as getSupabaseProductBySlug,
  type Product
} from './supabase';

/**
 * Product Management API
 * 
 * Example usage:
 * 
 * // Create a new product
 * const newProduct = await ProductManager.create({
 *   name: 'New Product',
 *   slug: 'new-product',
 *   description: 'Product description',
 *   category: 'web',
 *   base_price: 10000,
 *   ...
 * });
 * 
 * // Update a product
 * await ProductManager.update('product-id', { base_price: 15000 });
 * 
 * // Delete (deactivate) a product
 * await ProductManager.delete('product-id');
 * 
 * // Restore a deactivated product
 * await ProductManager.restore('product-id');
 */
export const ProductManager = {
  /**
   * Get all active products (used by the site)
   */
  getAll: getSupabaseProducts,

  /**
   * Get all products including inactive ones (for admin)
   */
  getAllIncludingInactive: () => getAllProducts(true),

  /**
   * Get a product by slug
   */
  getBySlug: getSupabaseProductBySlug,

  /**
   * Get product plans
   */
  getPlans: getProductPlans,

  /**
   * Create a new product
   */
  create: createProduct,

  /**
   * Update an existing product
   */
  update: updateProduct,

  /**
   * Delete a product (soft delete by default - sets is_active to false)
   * Set forceDelete to true for permanent deletion
   */
  delete: (productId: string, forceDelete: boolean = false) => 
    deleteProduct(productId, forceDelete),

  /**
   * Restore a deactivated product
   */
  restore: restoreProduct,
};

/**
 * Export types for TypeScript
 */
export type { Product };






