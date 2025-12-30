/**
 * Real-time subscription utility for Supabase
 * This module provides real-time synchronization between Supabase and the website
 * Changes in Supabase will automatically reflect on the site
 */

import { supabase } from './supabase';

export interface RealtimeSubscription {
  channel: any;
  unsubscribe: () => void;
}

/**
 * Subscribe to real-time changes for a specific table
 * @param tableName - Name of the table to subscribe to
 * @param callback - Callback function to handle changes
 * @param filter - Optional filter (e.g., { user_id: 'xxx' })
 * @returns Subscription object with unsubscribe method
 */
export function subscribeToTable(
  tableName: string,
  callback: (payload: any) => void,
  filter?: Record<string, any>
): RealtimeSubscription {
  try {
    const channelName = `realtime:${tableName}${filter ? `:${JSON.stringify(filter)}` : ''}`;
    
    const channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        {
          event: '*', // Listen to all events: INSERT, UPDATE, DELETE
          schema: 'public',
          table: tableName,
          filter: filter ? Object.entries(filter).map(([key, value]) => `${key}=eq.${value}`).join('&') : undefined
        },
        (payload) => {
          console.log(`🔄 Real-time update for ${tableName}:`, payload.eventType, payload);
          callback(payload);
        }
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.log(`✅ Subscribed to real-time updates for ${tableName}`);
        } else if (status === 'CHANNEL_ERROR') {
          console.error(`❌ Error subscribing to ${tableName}`);
        }
      });

    return {
      channel,
      unsubscribe: () => {
        try {
          supabase.removeChannel(channel);
          console.log(`🔌 Unsubscribed from ${tableName}`);
        } catch (error) {
          console.error(`Error unsubscribing from ${tableName}:`, error);
        }
      }
    };
  } catch (error) {
    console.error(`Error setting up subscription for ${tableName}:`, error);
    return {
      channel: null,
      unsubscribe: () => {}
    };
  }
}

/**
 * Subscribe to multiple tables at once
 * @param subscriptions - Array of subscription configs
 * @returns Array of subscription objects
 */
export function subscribeToMultiple(
  subscriptions: Array<{
    table: string;
    callback: (payload: any) => void;
    filter?: Record<string, any>;
  }>
): RealtimeSubscription[] {
  return subscriptions.map(sub => 
    subscribeToTable(sub.table, sub.callback, sub.filter)
  );
}

/**
 * Subscribe to user-specific data changes
 * @param userId - User ID to filter by
 * @param callbacks - Object with table names as keys and callbacks as values
 * @returns Array of subscription objects
 */
export function subscribeToUserData(
  userId: string,
  callbacks: Record<string, (payload: any) => void>
): RealtimeSubscription[] {
  const subscriptions: RealtimeSubscription[] = [];
  
  Object.entries(callbacks).forEach(([table, callback]) => {
    // Determine the filter key based on table name
    let filterKey = 'user_id';
    if (table === 'profiles') {
      filterKey = 'id';
    }
    
    subscriptions.push(
      subscribeToTable(table, callback, { [filterKey]: userId })
    );
  });
  
  return subscriptions;
}

/**
 * Cleanup all subscriptions
 * @param subscriptions - Array of subscription objects to cleanup
 */
export function cleanupSubscriptions(subscriptions: RealtimeSubscription[]): void {
  subscriptions.forEach(sub => {
    if (sub && sub.unsubscribe) {
      sub.unsubscribe();
    }
  });
}







