// Products data with Supabase integration and fallback to mock data
import { supabase, getProducts as getSupabaseProducts, getProductBySlug as getSupabaseProductBySlug } from './supabase';

export interface Product {
  id: string;
  name: string;
  slug: string;
  description: string;
  short_description: string;
  category: 'restaurant' | 'mobile' | 'tv' | 'web';
  base_price: number;
  featured_image: string;
  gallery: string[];
  features: string[];
  is_active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

// Mock products data - Fallback when Supabase is unavailable
const mockProducts: Product[] = [
  {
    id: '1',
    name: 'Restaurant Menu System',
    slug: 'restaurant-menu-system',
    description: 'Digital menu system with QR code integration, online ordering, and real-time updates. Perfect for restaurants looking to modernize their customer experience.',
    short_description: 'Digital menu system with QR code integration and online ordering',
    category: 'restaurant',
    base_price: 25000,
    featured_image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&h=300&fit=crop&crop=center',
    gallery: [],
    features: ['QR Code Menu', 'Online Ordering', 'Real-time Updates', 'Payment Integration', 'Analytics Dashboard'],
    is_active: true,
    sort_order: 1,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '2',
    name: 'Android TV App',
    slug: 'android-tv-app',
    description: 'Custom Android TV applications with beautiful UI, content management, and remote control support. Perfect for streaming services and media companies.',
    short_description: 'Custom Android TV applications with content management',
    category: 'tv',
    base_price: 9900,
    featured_image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=300&fit=crop&crop=center',
    gallery: [],
    features: ['Custom Design', 'Content Management', 'Remote Control Support', 'User Authentication', 'Analytics'],
    is_active: true,
    sort_order: 2,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '3',
    name: 'Streaming Mobile App',
    slug: 'streaming-mobile-app',
    description: 'Professional streaming applications for iOS and Android with advanced features like live streaming, video on demand, and monetization options.',
    short_description: 'Professional streaming apps for iOS and Android',
    category: 'mobile',
    base_price: 55000,
    featured_image: 'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=400&h=300&fit=crop&crop=center',
    gallery: [],
    features: ['Live Streaming', 'Video on Demand', 'User Authentication', 'Payment Integration', 'Push Notifications'],
    is_active: true,
    sort_order: 3,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: '4',
    name: 'Restaurant Website',
    slug: 'restaurant-website',
    description: 'Beautiful, responsive restaurant websites with online reservation system, menu showcase, and social media integration. SEO optimized for local search.',
    short_description: 'Professional restaurant websites with reservations',
    category: 'web',
    base_price: 25000,
    featured_image: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400&h=300&fit=crop&crop=center',
    gallery: [],
    features: ['Responsive Design', 'Online Reservations', 'Menu Showcase', 'SEO Optimization', 'Social Media Integration'],
    is_active: true,
    sort_order: 4,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
];

/**
 * Get products from Supabase, fallback to mock data if Supabase fails
 * This ensures the site works even if Supabase is unavailable
 */
export const getProducts = async (): Promise<Product[]> => {
  try {
    // Try to fetch from Supabase first
    const supabaseProducts = await getSupabaseProducts();
    
    // Filter out Order Menu System if it exists
    const filteredProducts = supabaseProducts ? supabaseProducts.filter(p => p.slug !== 'order-menu-system') : [];
    
    // If we got products from Supabase, use them
    if (filteredProducts && filteredProducts.length > 0) {
      console.log(`✅ Loaded ${filteredProducts.length} products from Supabase`);
      return filteredProducts;
    }
    
    // If Supabase returned empty array, fallback to mock data
    console.log('⚠️ No products in Supabase, using fallback mock data');
    return mockProducts;
  } catch (error) {
    // If Supabase fails, use mock data to maintain site functionality
    console.error('❌ Error fetching from Supabase, using fallback mock data:', error);
    return mockProducts;
  }
};

/**
 * Get product by slug from Supabase, fallback to mock data if not found
 */
export const getProductBySlug = async (slug: string): Promise<Product | null> => {
  try {
    // Try to fetch from Supabase first
    const supabaseProduct = await getSupabaseProductBySlug(slug);
    
    if (supabaseProduct) {
      return supabaseProduct as Product;
    }
    
    // Fallback to mock data
    return mockProducts.find(product => product.slug === slug) || null;
  } catch (error) {
    // If Supabase fails, use mock data
    console.error('Error fetching product from Supabase, using fallback:', error);
    return mockProducts.find(product => product.slug === slug) || null;
  }
};

/**
 * Get products by category
 */
export const getProductsByCategory = async (category: string): Promise<Product[]> => {
  const products = await getProducts();
  return products.filter(product => product.category === category);
};

/**
 * Get product plans from Supabase, fallback to default plans if not found
 */
export const getProductPlans = async (productId: string) => {
  try {
    // Check if this is Android TV App by getting product slug from Supabase or mock data
    let isAndroidTVApp = false;
    try {
      // Try to get product from Supabase
      const { data: productData } = await supabase
        .from('products')
        .select('slug')
        .eq('id', productId)
        .single();
      
      if (productData && productData.slug === 'android-tv-app') {
        isAndroidTVApp = true;
      } else {
        // Check mock data as fallback
        const mockProduct = mockProducts.find(p => p.slug === 'android-tv-app');
        if (mockProduct && mockProduct.id === productId) {
          isAndroidTVApp = true;
        }
      }
    } catch (e) {
      // If we can't determine, continue with normal flow
    }
    
    // If this is Android TV App, return the updated plan data directly from code
    if (isAndroidTVApp) {
      return [
        {
          id: '1',
          product_id: productId,
          name: 'Standard',
          description: 'Lifetime access with basic customization features',
          price: 9900.00,
          features: [
            'Unlimited Customers',
            'Name, Logo, Background/Wallpaper or Theme Image Customization',
            'Free Panel to Change DNS or Portal Address anytime',
            'Single Portals/DNS'
          ],
          delivery_days: 0,
          is_popular: false,
          sort_order: 1,
          created_at: new Date().toISOString()
        },
        {
          id: '2',
          product_id: productId,
          name: 'Pro',
          description: 'Lifetime access - Everything in Standard plus advanced features',
          price: 29900.00,
          features: [
            'Everything in Standard',
            'Unlimited DNS/Portals',
            'Intro Video',
            'Get All Future Updates in £19 Only'
          ],
          delivery_days: 0,
          is_popular: true,
          sort_order: 2,
          created_at: new Date().toISOString()
        },
        {
          id: '3',
          product_id: productId,
          name: 'Pro Gold',
          description: 'Lifetime access - Everything in Pro plus zero-cost future updates',
          price: 44900.00,
          features: [
            'Everything in Pro',
            'All Future updates at ZERO cost'
          ],
          delivery_days: 0,
          is_popular: false,
          sort_order: 3,
          created_at: new Date().toISOString()
        }
      ];
    }
    
    // Import getProductPlans from supabase
    const { getProductPlans: getSupabasePlans } = await import('./supabase');
    
    // Try to fetch from Supabase first
    const supabasePlans = await getSupabasePlans(productId);
    
    // If we got plans from Supabase and it's NOT Android TV App, use them
    // (Android TV App plans are overridden above with new content)
    if (supabasePlans && supabasePlans.length > 0 && !isAndroidTVApp) {
      return supabasePlans;
    }
    
    // Default plans for other products
    return [
      {
        id: '1',
        product_id: productId,
        name: 'Basic Plan',
        description: 'Essential features for small businesses',
        price: 15000,
        features: ['Basic Features', 'Email Support'],
        delivery_days: 1,
        is_popular: false,
        sort_order: 1,
        created_at: new Date().toISOString()
      },
      {
        id: '2',
        product_id: productId,
        name: 'Pro Plan',
        description: 'Advanced features for growing businesses',
        price: 25000,
        features: ['All Basic Features', 'Advanced Features', 'Priority Support'],
        delivery_days: 1,
        is_popular: true,
        sort_order: 2,
        created_at: new Date().toISOString()
      },
      {
        id: '3',
        product_id: productId,
        name: 'Enterprise Plan',
        description: 'Complete solution for large enterprises',
        price: 50000,
        features: ['All Pro Features', 'Custom Development', '24/7 Support', 'Dedicated Manager'],
        delivery_days: 2,
        is_popular: false,
        sort_order: 3,
        created_at: new Date().toISOString()
      }
    ];
  } catch (error) {
    // If Supabase fails, use default plans
    console.error('Error fetching product plans from Supabase, using fallback:', error);
    
    // Default plans for other products
    return [
      {
        id: '1',
        product_id: productId,
        name: 'Basic Plan',
        description: 'Essential features for small businesses',
        price: 15000,
        features: ['Basic Features', 'Email Support'],
        delivery_days: 1,
        is_popular: false,
        sort_order: 1,
        created_at: new Date().toISOString()
      },
      {
        id: '2',
        product_id: productId,
        name: 'Pro Plan',
        description: 'Advanced features for growing businesses',
        price: 25000,
        features: ['All Basic Features', 'Advanced Features', 'Priority Support'],
        delivery_days: 1,
        is_popular: true,
        sort_order: 2,
        created_at: new Date().toISOString()
      },
      {
        id: '3',
        product_id: productId,
        name: 'Enterprise Plan',
        description: 'Complete solution for large enterprises',
        price: 50000,
        features: ['All Pro Features', 'Custom Development', '24/7 Support', 'Dedicated Manager'],
        delivery_days: 2,
        is_popular: false,
        sort_order: 3,
        created_at: new Date().toISOString()
      }
    ];
  }
};