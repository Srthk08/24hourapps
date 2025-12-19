import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://tguopyxmlfxcalhfitob.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRndW9weXhtbGZ4Y2FsaGZpdG9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQyMTk3NDQsImV4cCI6MjA3OTc5NTc0NH0.GUtJWVu8i6NWoleXI_Fd-ePM4vOFQtulyk1kqZgPgRM';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const PRODUCT_TYPE_MAP = {
  'restaurant-website': 'restaurant-website',
  'streaming-mobile-app': 'streaming-mobile-app', 
  'android-tv-app': 'android-tv-app',
  'restaurant-menu-system': 'restaurant-menu-system',
  'order-menu-system': 'restaurant-menu-system' // Alias for order menu system
};

export async function saveCustomizationForm(formData, productType) {
  try {
    console.log('Saving customization form...', { formData, productType });

    if (productType === 'order-menu-system') {
      return await saveOMSCustomization(formData);
    }

    const dbProductType = PRODUCT_TYPE_MAP[productType] || productType;

    const dbData = {
      product_type: dbProductType,
      product_name: formData.productName || formData.product_name || 'Unknown Product',
      product_price: formData.productPrice || formData.product_price || '₹0',
      project_name: formData.projectName || formData.project_name || '',
      contact_person: formData.contactPerson || formData.contact_person || '',
      app_name: formData.appName || formData.app_name || '',
      product_description: formData.productDescription || formData.product_description || '',
      restaurant_name: formData.restaurantName || formData.restaurant_name || null,
      cuisine_type: formData.cuisineType || formData.cuisine_type || null,
      logo_url: formData.logoUrl || formData.logo_url || null,
      logo_filename: formData.logoFilename || formData.logo_filename || null,
      logo_mime_type: formData.logoMimeType || formData.logo_mime_type || null,
      logo_size: formData.logoSize || formData.logo_size || null,
      contact_email: formData.email || formData.contact_email || formData.contactEmail || '',
      contact_phone: formData.phone || formData.contact_phone || formData.contactPhone || '',
      primary_color: formData.primaryColor || formData.primary_color || '#3B82F6',
      secondary_color: formData.secondaryColor || formData.secondary_color || '#10B981',
      accent_color: formData.accentColor || formData.accent_color || '#F59E0B',
      text_color: formData.textColor || formData.text_color || '#1F2937',
      additional_requirements: formData.additionalRequirements || formData.additional_requirements || '',
      menu_items: formData.menuItems || formData.menu_items || [],
      restaurant_address: formData.restaurantAddress || formData.restaurant_address || null,
      owner_name: formData.ownerName || formData.owner_name || null,
      status: 'pending'
    };

    console.log('Inserting customization form...');
    const { data, error } = await supabase
      .from('customization_forms')
      .insert(dbData)
      .select()
      .single();

    if (error) {
      console.error('Error inserting form:', error);
      return { success: false, error: error.message, data: null };
    }

    console.log('Form inserted:', data);
    return { success: true, error: null, data: data };

  } catch (error) {
    console.error('Error saving form:', error);
    return { success: false, error: error.message, data: null };
  }
}

export async function getCustomizationsByEmail(email) {
  try {
    console.log('Getting customizations for:', email);

    const { data, error } = await supabase
      .from('customization_forms')
      .select('*')
      .eq('contact_email', email)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error fetching customizations:', error);
      return { success: false, error: error.message, data: [] };
    }

    return { success: true, error: null, data: data };

  } catch (error) {
    console.error('Error fetching customizations:', error);
    return { success: false, error: error.message, data: [] };
  }
}

export async function getCustomizationById(id) {
  try {
    console.log('Getting customization:', id);

    const { data, error } = await supabase
      .from('customization_forms')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      console.error('Error fetching customization:', error);
      return { success: false, error: error.message, data: null };
    }

    return { success: true, error: null, data: data };

  } catch (error) {
    console.error('Error fetching customization:', error);
    return { success: false, error: error.message, data: null };
  }
}

export async function updateCustomizationStatus(id, status, adminNotes = null) {
  try {
    console.log('Updating status:', { id, status, adminNotes });

    const updateData = { status };
    if (adminNotes) {
      updateData.admin_notes = adminNotes;
    }

    const { data, error } = await supabase
      .from('customization_forms')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      console.error('Error updating status:', error);
      return { success: false, error: error.message, data: null };
    }

    return { success: true, error: null, data: data };

  } catch (error) {
    console.error('Error updating status:', error);
    return { success: false, error: error.message, data: null };
  }
}

export async function deleteCustomization(id) {
  try {
    console.log('Deleting customization:', id);

    const { error } = await supabase
      .from('customization_forms')
      .delete()
      .eq('id', id);

    if (error) {
      console.error('Error deleting:', error);
      return { success: false, error: error.message };
    }

    return { success: true, error: null };

  } catch (error) {
    console.error('Error deleting:', error);
    return { success: false, error: error.message };
  }
}

export async function checkDuplicate(email, productType) {
  try {
    console.log('Checking duplicate:', { email, productType });

    const dbProductType = PRODUCT_TYPE_MAP[productType] || productType;

    const { data, error } = await supabase
      .from('customization_forms')
      .select('id, created_at')
      .eq('contact_email', email)
      .eq('product_type', dbProductType)
      .single();

    if (error && error.code !== 'PGRST116') {
      console.error('Error checking duplicate:', error);
      return { success: false, error: error.message, isDuplicate: false };
    }

    const isDuplicate = !!data;
    return { success: true, error: null, isDuplicate: isDuplicate, data: data };

  } catch (error) {
    console.error('Error checking duplicate:', error);
    return { success: false, error: error.message, isDuplicate: false };
  }
}

export async function getAllCustomizations(filters = {}) {
  try {
    console.log('Getting all customizations:', filters);

    let query = supabase
      .from('customization_forms')
      .select('*')
      .order('created_at', { ascending: false });

    if (filters.status) {
      query = query.eq('status', filters.status);
    }
    if (filters.product_type) {
      query = query.eq('product_type', filters.product_type);
    }
    if (filters.limit) {
      query = query.limit(filters.limit);
    }

    const { data, error } = await query;

    if (error) {
      console.error('Error fetching customizations:', error);
      return { success: false, error: error.message, data: [] };
    }

    return { success: true, error: null, data: data };

  } catch (error) {
    console.error('Error fetching customizations:', error);
    return { success: false, error: error.message, data: [] };
  }
}

export default {
  saveCustomizationForm,
  saveOMSCustomization,
  getCustomizationsByEmail,
  getCustomizationById,
  updateCustomizationStatus,
  deleteCustomization,
  checkDuplicate,
  getAllCustomizations
};

export async function saveOMSCustomization(formData) {
  try {
    console.log('Saving OMS customization...', { formData });

    const { data, error } = await supabase.rpc('upsert_oms_customization', {
      p_user_email: formData.email || formData.contact_email || formData.contactEmail || '',
      p_project_name: formData.projectName || formData.project_name || '',
      p_restaurant_name: formData.restaurantName || formData.restaurant_name || 'Default Restaurant',
      p_owner_name: formData.ownerName || formData.owner_name || formData.contactPerson || formData.contact_person || '',
      p_restaurant_address: formData.restaurantAddress || formData.restaurant_address || 'Not provided',
      p_contact_person: formData.contactPerson || formData.contact_person || '',
      p_phone_number: formData.phone || formData.contact_phone || formData.contactPhone || '',
      p_user_id: null,
      p_logo_url: formData.logoUrl || formData.logo_url || null,
      p_logo_filename: formData.logoFilename || formData.logo_filename || null,
      p_logo_size: formData.logoSize || formData.logo_size || null,
      p_menu_categories: formData.menuCategories || formData.menu_categories || [],
      p_menu_items: formData.menuItems || formData.menu_items || [],
      p_primary_color: formData.primaryColor || formData.primary_color || '#3B82F6',
      p_secondary_color: formData.secondaryColor || formData.secondary_color || '#10B981',
      p_accent_color: formData.accentColor || formData.accent_color || '#F59E0B',
      p_text_color: formData.textColor || formData.text_color || '#1F2937',
      p_additional_requirements: formData.additionalRequirements || formData.additional_requirements || ''
    });

    if (error) {
      console.error('Error inserting OMS customization:', error);
      return { success: false, error: error.message, data: null };
    }

    if (data && data.length > 0) {
      const result = data[0];
      
      if (result.is_duplicate) {
        console.log('Duplicate detected:', result.message);
        return { 
          success: true, 
          error: null, 
          data: { id: result.data_id },
          isUpdate: false,
          isDuplicate: true,
          message: result.message
        };
      } else {
        console.log('OMS customization saved, ID:', result.data_id);
        return { 
          success: true, 
          error: null, 
          data: { id: result.data_id },
          isUpdate: false,
          isDuplicate: false,
          message: result.message
        };
      }
    } else {
      console.error('No data returned from OMS function');
      return { success: false, error: 'No data returned from OMS function', data: null };
    }

  } catch (error) {
    console.error('Error saving OMS customization:', error);
    return { success: false, error: error.message, data: null };
  }
}
