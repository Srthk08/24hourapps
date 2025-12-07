// shared data store for user sync

export interface UserOrder {
  id: string;
  orderNumber: string;
  userId: string;
  customerName: string;
  customerEmail: string;
  serviceName: string;
  serviceType: string;
  status: 'cart' | 'pending' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  paymentStatus: 'pending' | 'paid' | 'failed' | 'refunded';
  amount: number;
  currency: string;
  requirements: {
    primaryColor: string;
    secondaryColor: string;
    accentColor: string;
    textColor: string;
    customName: string;
    logo?: string;
    features: string[];
    description: string;
  };
  timeline: OrderTimeline[];
  createdAt: string;
  updatedAt: string;
}

export interface OrderTimeline {
  id: string;
  status: string;
  message: string;
  timestamp: string;
  updatedBy: string;
}

export interface UserSupportTicket {
  id: string;
  ticketNumber: string;
  userId: string;
  customerName: string;
  customerEmail: string;
  subject: string;
  description: string;
  priority: 'low' | 'medium' | 'high' | 'urgent';
  status: 'open' | 'in_progress' | 'resolved' | 'closed';
  category: 'technical' | 'billing' | 'general' | 'feature_request';
  assignedTo?: string;
  createdAt: string;
  updatedAt: string;
  lastResponseAt?: string;
  adminReplies?: AdminReply[];
}

export interface AdminReply {
  message: string;
  timestamp: string;
  adminName: string;
}

export interface UserPayment {
  id: string;
  orderId: string;
  customerEmail: string;
  amount: number;
  currency: string;
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  paymentMethod: string;
  transactionId?: string;
  createdAt: string;
}

export interface UserAccount {
  id: string;
  email: string;
  fullName: string;
  phone?: string;
  companyName?: string;
  role: 'customer' | 'admin' | 'developer' | 'support' | 'menu_operator';
  status: 'active' | 'inactive' | 'suspended' | 'pending_verification';
  avatarUrl?: string;
  lastLoginAt?: string;
  loginCount: number;
  createdAt: string;
  updatedAt: string;
}

export class SharedDataStore {
  private static instance: SharedDataStore;
  private orders: UserOrder[] = [];
  private supportTickets: UserSupportTicket[] = [];
  private payments: UserPayment[] = [];
  private users: UserAccount[] = [];

  private constructor() {
    this.loadFromStorage();
    this.syncWithSimpleAuth();
  }

  public static getInstance(): SharedDataStore {
    if (!SharedDataStore.instance) {
      SharedDataStore.instance = new SharedDataStore();
    }
    return SharedDataStore.instance;
  }

  private loadFromStorage(): void {
    try {
      const storedOrders = localStorage.getItem('shared-orders');
      const storedTickets = localStorage.getItem('shared-tickets');
      const storedPayments = localStorage.getItem('shared-payments');
      const storedUsers = localStorage.getItem('shared-users');

      if (storedOrders) this.orders = JSON.parse(storedOrders);
      if (storedTickets) this.supportTickets = JSON.parse(storedTickets);
      if (storedPayments) this.payments = JSON.parse(storedPayments);
      if (storedUsers) this.users = JSON.parse(storedUsers);
    } catch (error) {
      console.error('Error loading shared data:', error);
    }
  }

  private saveToStorage(): void {
    try {
      localStorage.setItem('shared-orders', JSON.stringify(this.orders));
      localStorage.setItem('shared-tickets', JSON.stringify(this.supportTickets));
      localStorage.setItem('shared-payments', JSON.stringify(this.payments));
      localStorage.setItem('shared-users', JSON.stringify(this.users));
    } catch (error) {
      console.error('Error saving shared data:', error);
    }
  }

  private syncWithSimpleAuth(): void {
    try {
      const authUsers = localStorage.getItem('simple-auth-users');
      if (authUsers) {
        const parsedUsers = JSON.parse(authUsers);
        parsedUsers.forEach((authUser: any) => {
          const existingUser = this.users.find(u => u.email === authUser.email);
          if (!existingUser) {
            const newUser: UserAccount = {
              id: authUser.id || `user-${Date.now()}`,
              email: authUser.email,
              fullName: authUser.fullName || 'User',
              phone: authUser.phone,
              companyName: authUser.companyName,
              role: 'customer',
              status: 'active',
              avatarUrl: authUser.avatarUrl,
              lastLoginAt: authUser.lastLoginAt,
              loginCount: authUser.loginCount || 1,
              createdAt: authUser.createdAt || new Date().toISOString(),
              updatedAt: new Date().toISOString()
            };
            this.users.push(newUser);
          }
        });
        this.saveToStorage();
      }
    } catch (error) {
      console.error('Error syncing with simple-auth:', error);
    }
  }

  public createOrder(orderData: Omit<UserOrder, 'id' | 'orderNumber' | 'createdAt' | 'updatedAt' | 'timeline'>): UserOrder {
    const order: UserOrder = {
      ...orderData,
      id: `order-${Date.now()}`,
      orderNumber: `ORD-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      timeline: [{
        id: `timeline-${Date.now()}`,
        status: orderData.status,
        message: 'Order created',
        timestamp: new Date().toISOString(),
        updatedBy: 'system'
      }]
    };

    this.orders.push(order);
    this.saveToStorage();
    return order;
  }

  public updateOrderStatus(orderId: string, newStatus: UserOrder['status'], message: string): boolean {
    const order = this.orders.find(o => o.id === orderId);
    if (order) {
      order.status = newStatus;
      order.updatedAt = new Date().toISOString();
      order.timeline.push({
        id: `timeline-${Date.now()}`,
        status: newStatus,
        message,
        timestamp: new Date().toISOString(),
        updatedBy: 'admin'
      });
      this.saveToStorage();
      return true;
    }
    return false;
  }

  public getOrders(): UserOrder[] {
    return [...this.orders];
  }

  public getOrdersByStatus(status: UserOrder['status']): UserOrder[] {
    return this.orders.filter(order => order.status === status);
  }

  public getOrdersByUser(userId: string): UserOrder[] {
    return this.orders.filter(order => order.userId === userId);
  }

  public createSupportTicket(ticketData: Omit<UserSupportTicket, 'id' | 'ticketNumber' | 'createdAt' | 'updatedAt'>): UserSupportTicket {
    const ticket: UserSupportTicket = {
      ...ticketData,
      id: `ticket-${Date.now()}`,
      ticketNumber: `TKT-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    this.supportTickets.push(ticket);
    this.saveToStorage();
    return ticket;
  }

  public updateTicketStatus(ticketId: string, newStatus: UserSupportTicket['status'], message?: string): boolean {
    const ticket = this.supportTickets.find(t => t.id === ticketId);
    if (ticket) {
      ticket.status = newStatus;
      ticket.updatedAt = new Date().toISOString();
      if (message) {
        ticket.lastResponseAt = new Date().toISOString();
      }
      this.saveToStorage();
      return true;
    }
    return false;
  }

  public updateTicket(ticketId: string, updates: Partial<UserSupportTicket> & { adminReply?: AdminReply }): boolean {
    const ticket = this.supportTickets.find(t => t.id === ticketId);
    if (ticket) {
      if (updates.status) {
        ticket.status = updates.status;
      }
      
      if (updates.adminReply) {
        if (!ticket.adminReplies) {
          ticket.adminReplies = [];
        }
        ticket.adminReplies.push(updates.adminReply);
        ticket.lastResponseAt = new Date().toISOString();
        this.sendTicketUpdateNotification(ticket, updates.adminReply, updates.status);
      }
      
      ticket.updatedAt = new Date().toISOString();
      this.saveToStorage();
      return true;
    }
    return false;
  }

  private sendTicketUpdateNotification(ticket: UserSupportTicket, adminReply: AdminReply, newStatus?: string): void {
    try {
      const notification = {
        to: ticket.customerEmail,
        subject: `Update on Your Support Ticket #${ticket.ticketNumber}`,
        message: this.createNotificationMessage(ticket, adminReply, newStatus),
        timestamp: new Date().toISOString(),
        ticketId: ticket.id,
        status: newStatus || ticket.status
      };

      this.storeNotification(notification);
      this.showBrowserNotification(ticket, adminReply, newStatus);
      this.sendRealEmailNotification(ticket, adminReply, newStatus);
      
      console.log(`Notification sent to ${ticket.customerEmail} for ticket #${ticket.ticketNumber}`);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  }

  private async sendRealEmailNotification(ticket: UserSupportTicket, adminReply: AdminReply, newStatus?: string): Promise<void> {
    try {
      const { sendEmail, emailTemplates } = await import('./email-config');
      const template = emailTemplates.supportTicketUpdate;
      let subject = template.subject;
      let body = template.body;
      
      const variables = {
        '{{ticketNumber}}': ticket.ticketNumber,
        '{{customerName}}': ticket.customerName,
        '{{subject}}': ticket.subject,
        '{{status}}': newStatus || ticket.status,
        '{{adminReply}}': adminReply.message,
        '{{replyDate}}': new Date(adminReply.timestamp).toLocaleString(),
        '{{adminName}}': adminReply.adminName
      };
      
      Object.entries(variables).forEach(([key, value]) => {
        subject = subject.replace(key, value);
        body = body.replace(key, value);
      });
      
      const emailSent = await sendEmail(ticket.customerEmail, subject, body);
      
      if (emailSent) {
        console.log('Email sent');
      } else {
        console.log('Email service not configured');
      }
    } catch (error) {
      console.error('Error sending email:', error);
    }
  }

  private createNotificationMessage(ticket: UserSupportTicket, adminReply: AdminReply, newStatus?: string): string {
    let message = `Hello ${ticket.customerName},\n\n`;
    
    if (newStatus && newStatus !== ticket.status) {
      message += `Your support ticket #${ticket.ticketNumber} status has been updated to: ${newStatus.replace('_', ' ').toUpperCase()}\n\n`;
    }
    
    message += `Admin Reply:\n${adminReply.message}\n\n`;
    message += `Ticket Details:\n`;
    message += `Subject: ${ticket.subject}\n`;
    message += `Priority: ${ticket.priority}\n`;
    message += `Status: ${newStatus || ticket.status}\n\n`;
    message += `You can view the full details and reply in your support dashboard.\n\n`;
    message += `Best regards,\nDevExpress Support Team`;
    
    return message;
  }

  private storeNotification(notification: any): void {
    try {
      const notifications = JSON.parse(localStorage.getItem('user-notifications') || '[]');
      notifications.unshift(notification);
      
      if (notifications.length > 50) {
        notifications.splice(50);
      }
      
      localStorage.setItem('user-notifications', JSON.stringify(notifications));
    } catch (error) {
      console.error('Error storing notification:', error);
    }
  }

  private showBrowserNotification(ticket: UserSupportTicket, adminReply: AdminReply, newStatus?: string): void {
    if ('Notification' in window && Notification.permission === 'granted') {
      const title = `Ticket #${ticket.ticketNumber} Updated`;
      const body = `Admin replied: ${adminReply.message.substring(0, 100)}${adminReply.message.length > 100 ? '...' : ''}`;
      
      new Notification(title, {
        body: body,
        icon: '/favicon.ico',
        tag: ticket.id
      });
    }
  }

  public getUserNotifications(userEmail: string): any[] {
    try {
      const notifications = JSON.parse(localStorage.getItem('user-notifications') || '[]');
      return notifications.filter(n => n.to === userEmail);
    } catch (error) {
      console.error('Error getting notifications:', error);
      return [];
    }
  }

  public markNotificationAsRead(notificationId: string): void {
    try {
      const notifications = JSON.parse(localStorage.getItem('user-notifications') || '[]');
      const notification = notifications.find(n => n.timestamp === notificationId);
      if (notification) {
        notification.read = true;
        localStorage.setItem('user-notifications', JSON.stringify(notifications));
      }
    } catch (error) {
      console.error('Error marking notification as read:', error);
    }
  }

  public getTicketsByUser(userEmail: string): UserSupportTicket[] {
    return this.supportTickets.filter(ticket => ticket.customerEmail === userEmail);
  }

  public getSupportTickets(): UserSupportTicket[] {
    return [...this.supportTickets];
  }

  public getTicketsByStatus(status: UserSupportTicket['status']): UserSupportTicket[] {
    return this.supportTickets.filter(ticket => ticket.status === status);
  }

  public createPayment(paymentData: Omit<UserPayment, 'id' | 'createdAt'>): UserPayment {
    const payment: UserPayment = {
      ...paymentData,
      id: `payment-${Date.now()}`,
      createdAt: new Date().toISOString()
    };

    this.payments.push(payment);
    this.saveToStorage();
    return payment;
  }

  public updatePaymentStatus(paymentId: string, newStatus: UserPayment['status']): boolean {
    const payment = this.payments.find(p => p.id === paymentId);
    if (payment) {
      payment.status = newStatus;
      this.saveToStorage();
      return true;
    }
    return false;
  }

  public getPayments(): UserPayment[] {
    return [...this.payments];
  }

  public getPaymentsByStatus(status: UserPayment['status']): UserPayment[] {
    return this.payments.filter(payment => payment.status === status);
  }

  public createUser(userData: Omit<UserAccount, 'id' | 'createdAt' | 'updatedAt'>): UserAccount {
    const user: UserAccount = {
      ...userData,
      id: `user-${Date.now()}`,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    this.users.push(user);
    this.saveToStorage();
    return user;
  }

  public updateUser(userId: string, updates: Partial<UserAccount>): boolean {
    const user = this.users.find(u => u.id === userId);
    if (user) {
      Object.assign(user, updates);
      user.updatedAt = new Date().toISOString();
      this.saveToStorage();
      return true;
    }
    return false;
  }

  public getUsers(): UserAccount[] {
    return [...this.users];
  }

  public getUserById(userId: string): UserAccount | undefined {
    return this.users.find(u => u.id === userId);
  }

  public getUserByEmail(email: string): UserAccount | undefined {
    return this.users.find(u => u.email === email);
  }

  public deleteUser(userId: string): boolean {
    const userIndex = this.users.findIndex(u => u.id === userId);
    if (userIndex !== -1) {
      this.users.splice(userIndex, 1);
      this.saveToStorage();
      return true;
    }
    return false;
  }

  public getStats() {
    const now = new Date();
    const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
    const oneMonthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    return {
      totalUsers: this.users.length,
      activeUsers: this.users.filter(u => u.status === 'active').length,
      totalOrders: this.orders.length,
      pendingOrders: this.orders.filter(o => o.status === 'pending').length,
      cartOrders: this.orders.filter(o => o.status === 'cart').length,
      completedOrders: this.orders.filter(o => o.status === 'completed').length,
      totalRevenue: this.payments.filter(p => p.status === 'completed').reduce((sum, p) => sum + p.amount, 0),
      monthlyRevenue: this.payments.filter(p => p.status === 'completed' && new Date(p.createdAt) >= oneMonthAgo).reduce((sum, p) => sum + p.amount, 0),
      weeklyRevenue: this.payments.filter(p => p.status === 'completed' && new Date(p.createdAt) >= oneWeekAgo).reduce((sum, p) => sum + p.amount, 0),
      openTickets: this.supportTickets.filter(t => t.status === 'open').length,
      highPriorityTickets: this.supportTickets.filter(t => t.priority === 'high' || t.priority === 'urgent').length,
      pendingPayments: this.payments.filter(p => p.status === 'pending').length
    };
  }

  public clearAllData(): void {
    this.orders = [];
    this.supportTickets = [];
    this.payments = [];
    this.users = [];
    this.saveToStorage();
  }

  public exportOrdersToCSV(): string {
    if (this.orders.length === 0) return "No orders to export";
    
    const headers = ['Order ID', 'Customer', 'Service', 'Status', 'Payment Status', 'Amount', 'Date'];
    const rows = this.orders.map(order => [
      order.orderNumber,
      order.customerName,
      order.serviceName,
      order.status,
      order.paymentStatus,
      order.amount,
      new Date(order.createdAt).toLocaleDateString()
    ]);
    
    return [headers, ...rows].map(row => row.join(',')).join('\n');
  }
}

export const sharedDataStore = SharedDataStore.getInstance();
