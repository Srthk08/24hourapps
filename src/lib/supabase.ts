import { createClient } from '@supabase/supabase-js';

const SUPABASE_CONFIG = {
  url: 'https://tguopyxmlfxcalhfitob.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRndW9weXhtbGZ4Y2FsaGZpdG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMTk3NDQsImV4cCI6MjA3OTc5NTc0NH0.GUtJWVu8i6NWoleXI_Fd-ePM4vOFQtulyk1kqZgPgRM'
};

const getEnvVar = (key: string): string => {
  if (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env[key]) {
    return import.meta.env[key];
  }
  
  if (typeof process !== 'undefined' && process.env && process.env[key]) {
    return process.env[key];
  }
  
  if (typeof window !== 'undefined' && window.__ENV__ && window.__ENV__[key]) {
    return window.__ENV__[key];
  }
  
  return '';
};

export const supabaseUrl = getEnvVar('VITE_SUPABASE_URL') || SUPABASE_CONFIG.url;
export const supabaseAnonKey = getEnvVar('VITE_SUPABASE_ANON_KEY') || SUPABASE_CONFIG.anonKey;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

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

export interface ProductPlan {
  id: string;
  product_id: string;
  name: string;
  description: string;
  price: number;
  features: string[];
  delivery_days: number;
  is_popular: boolean;
  sort_order: number;
  created_at: string;
}

export interface CartItem {
  id: string;
  user_id: string;
  product_id: string;
  plan_id: string;
  quantity: number;
  custom_requirements: Record<string, any>;
  created_at: string;
  updated_at: string;
  product?: Product;
  plan?: ProductPlan;
}

export interface Order {
  id: string;
  user_id: string;
  order_number: string;
  status: 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  total_amount: number;
  payment_status: 'pending' | 'paid' | 'failed' | 'refunded';
  payment_method?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface Profile {
  id: string;
  email: string;
  full_name?: string;
  phone?: string;
  company_name?: string;
  role: 'customer' | 'admin' | 'developer' | 'support' | 'menu_operator';
  status: 'active' | 'inactive' | 'suspended' | 'pending_verification';
  username?: string;
  avatar_url?: string;
  bio?: string;
  website?: string;
  location?: string;
  timezone?: string;
  language?: string;
  preferences?: Record<string, any>;
  last_login_at?: string;
  login_count?: number;
  created_at: string;
  updated_at: string;
}

export class SupabaseAuth {
  private static instance: SupabaseAuth;
  private currentUser: Profile | null = null;
  private currentSession: any = null;

  private constructor() {
    this.initializeAuth();
  }

  public static getInstance(): SupabaseAuth {
    if (!SupabaseAuth.instance) {
      SupabaseAuth.instance = new SupabaseAuth();
    }
    return SupabaseAuth.instance;
  }

  private async initializeAuth() {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (session) {
        this.currentSession = session;
        await this.loadUserProfile(session.user.id);
      }

      supabase.auth.onAuthStateChange(async (event, session) => {
        console.log('Auth state changed:', event, session?.user?.email);
        
        if (event === 'SIGNED_IN' && session) {
          this.currentSession = session;
          await this.loadUserProfile(session.user.id);
          this.dispatchAuthEvent('auth-state-changed');
        } else if (event === 'SIGNED_OUT') {
          this.currentUser = null;
          this.currentSession = null;
          this.dispatchAuthEvent('auth-state-changed');
        } else if (event === 'TOKEN_REFRESHED' && session) {
          this.currentSession = session;
          await this.loadUserProfile(session.user.id);
        }
      });
    } catch (error) {
      console.error('Error initializing auth:', error);
    }
  }

  private async loadUserProfile(userId: string) {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        console.error('Error loading user profile:', error);
        return;
      }

      this.currentUser = data;
      console.log('User profile loaded:', data.email);
    } catch (error) {
      console.error('Error in loadUserProfile:', error);
    }
  }

  private dispatchAuthEvent(eventName: string) {
    if (typeof window !== 'undefined') {
      window.dispatchEvent(new CustomEvent(eventName));
    }
  }

  async signUp(email: string, password: string, userData: Partial<Profile>) {
    try {
      console.log('Signing up user:', email);

      const { data: authData, error: authError } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: userData.full_name,
            phone: userData.phone,
            company_name: userData.company_name,
          }
        }
      });

      if (authError) {
        console.error('Auth signup error:', authError);
        throw authError;
      }

      if (authData.user) {
        console.log('User created in auth:', authData.user.id);

        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: authData.user.id,
            email: email,
            full_name: userData.full_name || '',
            phone: userData.phone || '',
            company_name: userData.company_name || '',
            role: userData.role || 'customer',
            status: 'pending_verification',
            username: userData.username || userData.full_name?.toLowerCase().replace(/\s+/g, '_'),
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString()
          });

        if (profileError) {
          console.error('Profile creation error:', profileError);
          await supabase.auth.admin.deleteUser(authData.user.id);
          throw profileError;
        }

        await this.logUserActivity(authData.user.id, 'user_signup', {
          email: email,
          full_name: userData.full_name
        });

        console.log('User profile created successfully');
        return authData;
      }

      throw new Error('Failed to create user');
    } catch (error) {
      console.error('Signup error:', error);
      throw error;
    }
  }

  async signIn(email: string, password: string) {
    try {
      console.log('Signing in user:', email);

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        console.error('Sign in error:', error);
        throw error;
      }

      if (data.user) {
        console.log('User signed in:', data.user.email);
        
        await this.loadUserProfile(data.user.id);
        await this.updateLoginInfo(data.user.id);
        await this.logUserActivity(data.user.id, 'user_login', {
          email: email,
          ip_address: await this.getClientIP()
        });

        this.dispatchAuthEvent('auth-state-changed');
        return data;
      }

      throw new Error('Sign in failed');
    } catch (error) {
      console.error('Sign in error:', error);
      throw error;
    }
  }

  async signOut() {
    try {
      if (this.currentUser) {
        await this.logUserActivity(this.currentUser.id, 'user_logout', {
          email: this.currentUser.email
        });
      }

      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error('Sign out error:', error);
        throw error;
      }

      this.currentUser = null;
      this.currentSession = null;
      this.dispatchAuthEvent('auth-state-changed');
      
      console.log('User signed out successfully');
    } catch (error) {
      console.error('Sign out error:', error);
      throw error;
    }
  }

  async getCurrentUser(): Promise<Profile | null> {
    try {
      if (this.currentUser) {
        return this.currentUser;
      }

      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await this.loadUserProfile(user.id);
        return this.currentUser;
      }

      return null;
    } catch (error) {
      console.error('Error getting current user:', error);
      return null;
    }
  }

  async isAuthenticated(): Promise<boolean> {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      return !!session;
    } catch (error) {
      console.error('Error checking authentication:', error);
      return false;
    }
  }

  async updateProfile(updates: Partial<Profile>): Promise<Profile> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        throw new Error('No authenticated user');
      }

      console.log('Updating profile for user:', user.email);

      const { data, error } = await supabase
        .from('profiles')
        .update({
          ...updates,
          updated_at: new Date().toISOString()
        })
        .eq('id', user.id)
        .select()
        .single();

      if (error) {
        console.error('Profile update error:', error);
        throw error;
      }

      this.currentUser = data;
      await this.logUserActivity(user.id, 'profile_updated', {
        updated_fields: Object.keys(updates)
      });

      console.log('Profile updated successfully');
      return data;
    } catch (error) {
      console.error('Profile update error:', error);
      throw error;
    }
  }

  async changePassword(currentPassword: string, newPassword: string) {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        throw new Error('No authenticated user');
      }

      console.log('Changing password for user:', user.email);

      const { error } = await supabase.auth.updateUser({
        password: newPassword
      });

      if (error) {
        console.error('Password change error:', error);
        throw error;
      }

      await this.logUserActivity(user.id, 'password_changed', {
        email: user.email
      });

      console.log('Password changed successfully');
    } catch (error) {
      console.error('Password change error:', error);
      throw error;
    }
  }

  async resetPassword(email: string) {
    try {
      console.log('Sending password reset for:', email);

      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${window.location.origin}/reset-password`
      });

      if (error) {
        console.error('Password reset error:', error);
        throw error;
      }

      console.log('Password reset email sent');
    } catch (error) {
      console.error('Password reset error:', error);
      throw error;
    }
  }

  async getUserProfile(userId: string): Promise<Profile | null> {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error) {
        console.error('Error fetching user profile:', error);
        return null;
      }

      return data;
    } catch (error) {
      console.error('Error in getUserProfile:', error);
      return null;
    }
  }

  async getAllUsers(): Promise<Profile[]> {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching all users:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Error in getAllUsers:', error);
      throw error;
    }
  }

  private async logUserActivity(userId: string, action: string, details: Record<string, any> = {}) {
    try {
      const { error } = await supabase
        .from('user_activity_log')
        .insert({
          user_id: userId,
          action: action,
          details: details,
          ip_address: await this.getClientIP(),
          user_agent: navigator.userAgent
        });

      if (error) {
        console.error('Error logging user activity:', error);
      }
    } catch (error) {
      console.error('Error in logUserActivity:', error);
    }
  }

  private async updateLoginInfo(userId: string) {
    try {
      const { data: currentProfile } = await supabase
        .from('profiles')
        .select('login_count')
        .eq('id', userId)
        .single();

      const currentCount = currentProfile?.login_count || 0;
      const newCount = currentCount + 1;

      const { error } = await supabase
        .from('profiles')
        .update({
          last_login_at: new Date().toISOString(),
          login_count: newCount,
          updated_at: new Date().toISOString()
        })
        .eq('id', userId);

      if (error) {
        console.error('Error updating login info:', error);
      }
    } catch (error) {
      console.error('Error in updateLoginInfo:', error);
    }
  }

  private async getClientIP(): Promise<string | null> {
    try {
      return '127.0.0.1';
    } catch (error) {
      return null;
    }
  }

  async getUserDashboardData(): Promise<any> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        throw new Error('No authenticated user');
      }

      const { data, error } = await supabase
        .from('user_dashboard_data')
        .select('*')
        .eq('id', user.id)
        .single();

      if (error) {
        console.error('Error fetching dashboard data:', error);
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Error in getUserDashboardData:', error);
      throw error;
    }
  }

  async getUserSessions(): Promise<any[]> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        throw new Error('No authenticated user');
      }

      const { data, error } = await supabase
        .from('user_sessions')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching user sessions:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Error in getUserSessions:', error);
      throw error;
    }
  }

  async getUserActivityLog(limit: number = 50): Promise<any[]> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        throw new Error('No authenticated user');
      }

      const { data, error } = await supabase
        .from('user_activity_log')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (error) {
        console.error('Error fetching user activity log:', error);
        throw error;
      }

      return data || [];
    } catch (error) {
      console.error('Error in getUserActivityLog:', error);
      throw error;
    }
  }
}

export const supabaseAuth = SupabaseAuth.getInstance();

export const signUp = async (email: string, password: string, userData: Partial<Profile>) => {
  return await supabaseAuth.signUp(email, password, userData);
};

export const signIn = async (email: string, password: string) => {
  return await supabaseAuth.signIn(email, password);
};

export const signOut = async () => {
  return await supabaseAuth.signOut();
};

export const getProducts = async () => {
  try {
    const { data, error } = await supabase
      .from('products')
      .select('*')
      .eq('is_active', true)
      .neq('slug', 'order-menu-system') // Exclude Order Menu System
      .order('sort_order');

    if (error) {
      console.error('Error fetching products:', error);
      return [];
    }
    return data as Product[];
  } catch (error) {
    console.error('Error in getProducts:', error);
    return [];
  }
};

export const getProductBySlug = async (slug: string) => {
  try {
    const { data, error } = await supabase
      .from('products')
      .select(`
        *,
        product_plans (*)
      `)
      .eq('slug', slug)
      .eq('is_active', true)
      .single();

    if (error) {
      console.error('Error fetching product by slug:', error);
      return null;
    }
    return data;
  } catch (error) {
    console.error('Error in getProductBySlug:', error);
    return null;
  }
};

export const getCartItems = async (userId: string) => {
  const { data, error } = await supabase
    .from('cart_items')
    .select(`
      *,
      product:products (*),
      plan:product_plans (*)
    `)
    .eq('user_id', userId);

  if (error) throw error;
  return data as CartItem[];
};

export const addToCart = async (userId: string, productId: string, planId: string, customRequirements = {}) => {
  const { data, error } = await supabase
    .from('cart_items')
    .upsert({
      user_id: userId,
      product_id: productId,
      plan_id: planId,
      custom_requirements: customRequirements,
      quantity: 1,
    })
    .select();

  if (error) throw error;
  return data;
};

export const removeFromCart = async (cartItemId: string) => {
  const { error } = await supabase
    .from('cart_items')
    .delete()
    .eq('id', cartItemId);

  if (error) throw error;
};

export const clearCart = async (userId: string) => {
  const { error } = await supabase
    .from('cart_items')
    .delete()
    .eq('user_id', userId);

  if (error) throw error;
};

export const createOrder = async (userId: string, cartItems: CartItem[], totalAmount: number) => {
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .insert({
      user_id: userId,
      total_amount: totalAmount,
      status: 'pending',
      payment_status: 'pending',
    })
    .select()
    .single();

  if (orderError) throw orderError;

  const orderItems = cartItems.map(item => ({
    order_id: order.id,
    product_id: item.product_id,
    plan_id: item.plan_id,
    quantity: item.quantity,
    unit_price: item.plan?.price || 0,
    total_price: (item.plan?.price || 0) * item.quantity,
    custom_requirements: item.custom_requirements,
  }));

  const { error: itemsError } = await supabase
    .from('order_items')
    .insert(orderItems);

  if (itemsError) throw itemsError;

  return order;
};

export const getUserOrders = async (userId: string) => {
  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      order_items (
        *,
        product:products (*),
        plan:product_plans (*)
      )
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) throw error;
  return data;
};

export const getUserProfile = async (userId: string) => {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();
    
    if (error) {
      console.error('Error fetching user profile:', error);
      return null;
    }
    
    return data;
  } catch (error) {
    console.error('Error in getUserProfile:', error);
    return null;
  }
};

// ============================================
// PRODUCT MANAGEMENT FUNCTIONS
// ============================================

/**
 * Get product plans from Supabase
 */
export const getProductPlans = async (productId: string) => {
  try {
    const { data, error } = await supabase
      .from('product_plans')
      .select('*')
      .eq('product_id', productId)
      .order('sort_order');

    if (error) {
      console.error('Error fetching product plans:', error);
      return [];
    }
    return data || [];
  } catch (error) {
    console.error('Error in getProductPlans:', error);
    return [];
  }
};

/**
 * Create a new product in Supabase
 */
export const createProduct = async (product: Partial<Product>) => {
  try {
    const { data, error } = await supabase
      .from('products')
      .insert({
        name: product.name,
        slug: product.slug,
        description: product.description,
        short_description: product.short_description,
        category: product.category,
        base_price: product.base_price,
        featured_image: product.featured_image,
        gallery: product.gallery || [],
        features: product.features || [],
        is_active: product.is_active !== undefined ? product.is_active : true,
        sort_order: product.sort_order || 0,
      })
      .select()
      .single();

    if (error) {
      console.error('Error creating product:', error);
      throw error;
    }
    return data;
  } catch (error) {
    console.error('Error in createProduct:', error);
    throw error;
  }
};

/**
 * Update an existing product in Supabase
 */
export const updateProduct = async (productId: string, updates: Partial<Product>) => {
  try {
    const { data, error } = await supabase
      .from('products')
      .update({
        ...updates,
        updated_at: new Date().toISOString(),
      })
      .eq('id', productId)
      .select()
      .single();

    if (error) {
      console.error('Error updating product:', error);
      throw error;
    }
    return data;
  } catch (error) {
    console.error('Error in updateProduct:', error);
    throw error;
  }
};

/**
 * Delete a product from Supabase (soft delete by setting is_active to false)
 * Or hard delete if forceDelete is true
 */
export const deleteProduct = async (productId: string, forceDelete: boolean = false) => {
  try {
    if (forceDelete) {
      // Hard delete - completely remove from database
      const { error } = await supabase
        .from('products')
        .delete()
        .eq('id', productId);

      if (error) {
        console.error('Error deleting product:', error);
        throw error;
      }
      return { success: true, message: 'Product deleted permanently' };
    } else {
      // Soft delete - set is_active to false
      const { data, error } = await supabase
        .from('products')
        .update({ is_active: false, updated_at: new Date().toISOString() })
        .eq('id', productId)
        .select()
        .single();

      if (error) {
        console.error('Error deactivating product:', error);
        throw error;
      }
      return { success: true, message: 'Product deactivated', data };
    }
  } catch (error) {
    console.error('Error in deleteProduct:', error);
    throw error;
  }
};

/**
 * Restore a deactivated product (set is_active to true)
 */
export const restoreProduct = async (productId: string) => {
  try {
    const { data, error } = await supabase
      .from('products')
      .update({ is_active: true, updated_at: new Date().toISOString() })
      .eq('id', productId)
      .select()
      .single();

    if (error) {
      console.error('Error restoring product:', error);
      throw error;
    }
    return data;
  } catch (error) {
    console.error('Error in restoreProduct:', error);
    throw error;
  }
};

/**
 * Get all products including inactive ones (for admin)
 */
export const getAllProducts = async (includeInactive: boolean = false) => {
  try {
    let query = supabase
      .from('products')
      .select('*')
      .order('sort_order');

    if (!includeInactive) {
      query = query.eq('is_active', true);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching all products:', error);
      return [];
    }
    return data as Product[];
  } catch (error) {
    console.error('Error in getAllProducts:', error);
    return [];
  }
};

export const updateUserProfile = async (updates: any) => {
  try {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      throw new Error('No authenticated user');
    }
    
    const { data, error } = await supabase
      .from('profiles')
      .update({
        ...updates,
        updated_at: new Date().toISOString()
      })
      .eq('id', user.id)
      .select()
      .single();
    
    if (error) {
      console.error('Profile update error:', error);
      throw error;
    }
    
    return data;
  } catch (error) {
    console.error('Error updating profile:', error);
    throw error;
  }
};