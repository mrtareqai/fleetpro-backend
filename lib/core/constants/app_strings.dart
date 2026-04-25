class AppStrings {
  AppStrings._();

  static String get(String key, String locale) {
    final map = locale == 'ar' ? _ar : _en;
    return map[key] ?? _en[key] ?? key;
  }

  static const Map<String, String> _ar = {
    // ─── App ───
    'app_name': 'FleetPro',
    'app_subtitle': 'الإدارة',
    'management': 'إدارة النقل والأسطول',

    // ─── Auth ───
    'secure_login': 'تسجيل دخول آمن',
    'server_id': 'معرّف الخادم',
    'username': 'اسم المستخدم',
    'password': 'كلمة المرور',
    'login': 'تسجيل الدخول',
    'logout': 'تسجيل الخروج',
    'forgot_password': 'نسيت كلمة المرور؟',
    'demo_mode': 'وضع التجريبي - استخدم: admin / password123',
    'login_error': 'اسم المستخدم أو كلمة المرور غير صحيحة',
    'server_not_found': 'معرّف الخادم غير صحيح',
    'company_inactive': 'هذه الشركة معطلة حالياً',
    'ip_blocked': 'تم حظر عنوان IP الخاص بك بسبب محاولات دخول متعددة فاشلة',
    'attempts_warning': 'تحذير: متبقي {remaining} محاولات قبل حظر IP',
    'company_name': 'اسم الشركة',
    'change_password': 'تغيير كلمة المرور',
    'current_password': 'كلمة المرور الحالية',
    'new_password': 'كلمة المرور الجديدة',
    'confirm_password': 'تأكيد كلمة المرور',
    'force_change_title': 'يجب تغيير كلمة المرور',
    'force_change_subtitle': 'هذا هو تسجيل دخولك الأول. يرجى تغيير كلمة المرور للمتابعة.',
    'password_changed': 'تم تغيير كلمة المرور بنجاح',
    'password_mismatch': 'كلمات المرور غير متطابقة',
    'password_too_short': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    'field_required': 'هذا الحقل مطلوب',

    // ─── Sidebar ───
    'dashboard': 'لوحة التحكم',
    'reservations': 'الحجوزات',
    'tickets': 'التذاكر',
    'fleet': 'الأسطول',
    'drivers': 'السائقون',
    'reports': 'التقارير',
    'movement': 'سجل الحركة',
    'agency_supplies': 'مستلزمات الوكالة',
    'expenses': 'المصاريف',
    'transactions': 'المعاملات',
    'settings': 'الإعدادات',
    'administration': 'الإدارة',
    'routes': 'المسارات',
    'branches_agents': 'الفروع والوكلاء',
    'trips': 'الرحلات',
    'user_management': 'إدارة المستخدمين',
    'roles_permissions': 'الأدوار والصلاحيات',

    // ─── TopOwner Sidebar ───
    'companies': 'إدارة الشركات',
    'all_users': 'جميع المستخدمين',
    'firewall': 'جدار الحماية',
    'audit_logs': 'سجل النشاطات',
    'alerts': 'التنبيهات',

    // ─── Dashboard ───
    'dashboard_overview': 'نظرة عامة على لوحة التحكم',
    'total_vehicles': 'إجمالي المركبات',
    'total_drivers': 'إجمالي السائقين',
    'active_reservations': 'الحجوزات النشطة',
    'total_tickets': 'إجمالي التذاكر',
    'performance': 'الأداء',
    'active_transfers': 'الترحيلات النشطة',
    'change': 'تغيير',
    'upcoming': 'القادمة',
    'monthly_activity': 'اتجاه النشاط الشهري',
    'monthly_subtitle': 'الحجوزات والتذاكر والترحيلات',
    'fleet_status': 'حالة الأسطول',
    'fleet_distribution': 'توزيع حالات المركبات',
    'weekly_activity': 'النشاط الأسبوعي',
    'weekly_subtitle': 'النشاط خلال الأسبوع الحالي',
    'recent_activities': 'الأنشطة الأخيرة',
    'recent_subtitle': 'آخر التحديثات في النظام',
    'view_all': 'عرض الكل',
    'active': 'نشط',
    'inactive': 'غير نشط',
    'expired': 'منتهي',

    // ─── Tables ───
    'search': 'بحث...',
    'all': 'الكل',
    'filter': 'تصفية',
    'export_csv': 'تصدير CSV',
    'add': 'إضافة',
    'edit': 'تعديل',
    'delete': 'حذف',
    'clear': 'مسح',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'actions': 'الإجراءات',
    'status': 'الحالة',
    'id': 'المعرّف',
    'created': 'تم إنشاء',
    'updated': 'تم تحديث',
    'completed': 'مكتملة',
    'no_data': 'لا توجد بيانات',

    // ─── Fleet ───
    'fleet_management': 'إدارة الأسطول',
    'model': 'الموديل',
    'manufacture_date': 'تاريخ الصنع',
    'plate_number': 'اللوحة المعدنية',
    'base_number': 'رقم القاعدة',
    'card_number': 'رقم الكرت',
    'issue_date': 'تاريخ الإصدار',
    'expiry_date': 'تاريخ الانتهاء',
    'number': 'الرقم',

    // ─── Reservations ───
    'reservation_management': 'شاشة إدارة الحجوزات',
    'client': 'العميل',
    'pickup_date': 'تاريخ الاستلام',
    'return_date': 'تاريخ الإرجاع',
    'destination': 'الوجهة',

    // ─── Tickets ───
    'ticket_management': 'إدارة التذاكر',
    'passenger_name': 'اسم الراكب',
    'ticket_number': 'رقم التذكرة',
    'trip': 'الرحلة',
    'trip_date': 'تاريخ الرحلة',
    'seat_number': 'رقم الرحلة',
    'time': 'وقت',
    'phone': 'رقم الجوال',
    'assigned_to': 'المستخدم',

    // ─── Drivers ───
    'driver_management': 'إدارة السائقين',
    'driver_name': 'اسم السائق',
    'license_number': 'رقم الرخصة',
    'license_expiry': 'تاريخ انتهاء الرخصة',

    // ─── Routes ───
    'routes_management': 'إدارة المسارات',
    'origin_city': 'مدينة الانطلاق',
    'destination_city': 'مدينة الوصول',
    'stops_count': 'عدد المحطات',
    'estimated_duration': 'المدة (دقائق)',
    'base_price': 'السعر الأساسي',

    // ─── Branches & Agents ───
    'branches_management': 'إدارة الفروع',
    'agents_management': 'إدارة الوكلاء',
    'branch': 'الفرع',
    'agent': 'الوكيل',
    'location': 'الموقع',
    'commission': 'نسبة العمولة (%)',

    // ─── Trips ───
    'trips_management': 'إدارة الرحلات',
    'departure_time': 'وقت المغادرة',
    'total_seats': 'المقاعد',
    'available_seats': 'متاح',
    'route': 'المسار',
    'driver': 'السائق',
    'vehicle': 'المركبة',

    // ─── Transactions & Expenses ───
    'type': 'النوع',
    'amount': 'المبلغ',
    'category': 'التصنيف',
    'date': 'التاريخ',
    'description': 'الوصف',
    'income': 'دخل (إيراد)',
    'expense': 'مصروف',
    'fuel': 'وقود',
    'maintenance': 'صيانة',
    'supplies': 'مستلزمات',
    'other': 'أخرى',

    // ─── Companies (TopOwner) ───
    'company_management': 'إدارة الشركات',
    'owner_name': 'اسم المالك',
    'email': 'البريد الإلكتروني',
    'server_id_col': 'معرّف الخادم',
    'telegram_chat_id': 'Telegram Chat ID',
    'add_company': 'إضافة شركة',
    'edit_company': 'تعديل شركة',
    'activate': 'تفعيل',
    'deactivate': 'تعطيل',
    'initial_password': 'كلمة المرور الأولى',
    'generate_server_id': 'توليد معرّف الخادم تلقائياً',

    // ─── Firewall (TopOwner) ───
    'firewall_management': 'جدار الحماية',
    'ip_address': 'عنوان IP',
    'failed_attempts': 'المحاولات الفاشلة',
    'blocked': 'محظور',
    'not_blocked': 'غير محظور',
    'blocked_until': 'محظور حتى',
    'reason': 'السبب',
    'unblock': 'فك الحظر',
    'unblock_confirm': 'هل تريد فك الحظر عن هذا العنوان؟',

    // ─── Audit Logs ───
    'audit_log_title': 'سجل النشاطات',
    'action': 'الإجراء',
    'user': 'المستخدم',
    'details': 'التفاصيل',
    'timestamp': 'الوقت',

    // ─── Users ───
    'users_management': 'إدارة المستخدمين',
    'role': 'الدور',
    'add_user': 'إضافة مستخدم',

    // ─── Roles ───
    'roles_management': 'الأدوار والصلاحيات',
    'role_name': 'اسم الدور',
    'permissions': 'الصلاحيات',
    'add_role': 'إضافة دور',

    // ─── Settings ───
    'settings_title': 'الإعدادات',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'English',
    'theme': 'المظهر',
    'dark_mode': 'الوضع الداكن',
    'light_mode': 'الوضع الفاتح',
    'notifications': 'الإشعارات',
    'telegram_alerts': 'تنبيهات Telegram',
    'about': 'حول النظام',
    'version': 'الإصدار',

    // ─── TopOwner Dashboard ───
    'topowner_dashboard': 'لوحة تحكم المسؤول',
    'total_companies': 'إجمالي الشركات',
    'active_companies': 'الشركات النشطة',
    'inactive_companies': 'الشركات المعطلة',
    'blocked_ips': 'IPs المحظورة',
    'system_overview': 'نظرة عامة على النظام',
    'total_users': 'إجمالي المستخدمين',

    // ─── Reports ───
    'reports_title': 'التقارير',
    'coming_soon': 'قريباً...',
    'feature_coming_soon': 'هذه الميزة قيد التطوير',

    // ─── Time ───
    'minutes_ago': 'منذ {n} دقيقة',
    'hours_ago': 'منذ {n} ساعة',
    'just_now': 'الآن',
    'today': 'اليوم',

    // ─── Footer ───
    'copyright': '© FleetPro 2025 نظام - جميع الحقوق محفوظة',

    // ─── Misc ───
    'confirm_delete': 'هل أنت متأكد من حذف هذا العنصر؟',
    'success': 'تمت العملية بنجاح',
    'error': 'حدث خطأ',
    'telegram_alert_sent': '📢 تم إرسال تنبيه Telegram',
  };

  static const Map<String, String> _en = {
    // ─── App ───
    'app_name': 'FleetPro',
    'app_subtitle': 'Management',
    'management': 'Fleet & Transport Management',

    // ─── Auth ───
    'secure_login': 'Secure Login',
    'server_id': 'Server ID',
    'username': 'Username',
    'password': 'Password',
    'login': 'Login',
    'logout': 'Logout',
    'forgot_password': 'Forgot password?',
    'demo_mode': 'Demo Mode - Use: admin / password123',
    'login_error': 'Invalid username or password',
    'server_not_found': 'Invalid Server ID',
    'company_inactive': 'This company is currently deactivated',
    'ip_blocked': 'Your IP has been blocked due to multiple failed login attempts',
    'attempts_warning': 'Warning: {remaining} attempts remaining before IP block',
    'company_name': 'Company Name',
    'change_password': 'Change Password',
    'current_password': 'Current Password',
    'new_password': 'New Password',
    'confirm_password': 'Confirm Password',
    'force_change_title': 'Password Change Required',
    'force_change_subtitle': 'This is your first login. Please change your password to continue.',
    'password_changed': 'Password changed successfully',
    'password_mismatch': 'Passwords do not match',
    'password_too_short': 'Password must be at least 6 characters',
    'field_required': 'This field is required',

    // ─── Sidebar ───
    'dashboard': 'Dashboard',
    'reservations': 'Reservations',
    'tickets': 'Tickets',
    'fleet': 'Fleet',
    'drivers': 'Drivers',
    'reports': 'Reports',
    'movement': 'Movement Log',
    'agency_supplies': 'Agency Supplies',
    'expenses': 'Expenses',
    'transactions': 'Transactions',
    'settings': 'Settings',
    'administration': 'Administration',
    'routes': 'Routes',
    'branches_agents': 'Branches & Agents',
    'trips': 'Trips',
    'user_management': 'User Management',
    'roles_permissions': 'Roles & Permissions',

    // ─── TopOwner Sidebar ───
    'companies': 'Companies',
    'all_users': 'All Users',
    'firewall': 'Firewall',
    'audit_logs': 'Audit Logs',
    'alerts': 'Alerts',

    // ─── Dashboard ───
    'dashboard_overview': 'Dashboard Overview',
    'total_vehicles': 'Total Vehicles',
    'total_drivers': 'Total Drivers',
    'active_reservations': 'Active Reservations',
    'total_tickets': 'Total Tickets',
    'performance': 'Performance',
    'active_transfers': 'Active Transfers',
    'change': 'change',
    'upcoming': 'upcoming',
    'monthly_activity': 'Monthly Activity Trend',
    'monthly_subtitle': 'Reservations, Tickets & Transfers',
    'fleet_status': 'Fleet Status',
    'fleet_distribution': 'Vehicle status distribution',
    'weekly_activity': 'Weekly Activity',
    'weekly_subtitle': 'Activity during current week',
    'recent_activities': 'Recent Activities',
    'recent_subtitle': 'Latest system updates',
    'view_all': 'View All',
    'active': 'Active',
    'inactive': 'Inactive',
    'expired': 'Expired',

    // ─── Tables ───
    'search': 'Search...',
    'all': 'All',
    'filter': 'Filter',
    'export_csv': 'Export CSV',
    'add': 'Add',
    'edit': 'Edit',
    'delete': 'Delete',
    'clear': 'Clear',
    'save': 'Save',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'actions': 'Actions',
    'status': 'Status',
    'id': 'ID',
    'created': 'Created',
    'updated': 'Updated',
    'completed': 'Completed',
    'no_data': 'No data available',

    // ─── Fleet ───
    'fleet_management': 'Fleet Management',
    'model': 'Model',
    'manufacture_date': 'Manufacture Date',
    'plate_number': 'Plate Number',
    'base_number': 'Base Number',
    'card_number': 'Card Number',
    'issue_date': 'Issue Date',
    'expiry_date': 'Expiry Date',
    'number': 'Number',

    // ─── Reservations ───
    'reservation_management': 'Reservation Management',
    'client': 'Client',
    'pickup_date': 'Pickup Date',
    'return_date': 'Return Date',
    'destination': 'Destination',

    // ─── Tickets ───
    'ticket_management': 'Ticket Management',
    'passenger_name': 'Passenger Name',
    'ticket_number': 'Ticket Number',
    'trip': 'Trip',
    'trip_date': 'Trip Date',
    'seat_number': 'Seat Number',
    'time': 'Time',
    'phone': 'Phone',
    'assigned_to': 'Assigned To',

    // ─── Drivers ───
    'driver_management': 'Driver Management',
    'driver_name': 'Driver Name',
    'license_number': 'License Number',
    'license_expiry': 'License Expiry',

    // ─── Routes ───
    'routes_management': 'Routes Management',
    'origin_city': 'Origin City',
    'destination_city': 'Destination City',
    'stops_count': 'Stops Count',
    'estimated_duration': 'Duration (mins)',
    'base_price': 'Base Price',

    // ─── Branches & Agents ───
    'branches_management': 'Branches Management',
    'agents_management': 'Agents Management',
    'branch': 'Branch',
    'agent': 'Agent',
    'location': 'Location',
    'commission': 'Commission (%)',

    // ─── Trips ───
    'trips_management': 'Trips Management',
    'departure_time': 'Departure Time',
    'total_seats': 'Total Seats',
    'available_seats': 'Available',
    'route': 'Route',
    'driver': 'Driver',
    'vehicle': 'Vehicle',

    // ─── Transactions & Expenses ───
    'type': 'Type',
    'amount': 'Amount',
    'category': 'Category',
    'date': 'Date',
    'description': 'Description',
    'income': 'Income',
    'expense': 'Expense',
    'fuel': 'Fuel',
    'maintenance': 'Maintenance',
    'supplies': 'Supplies',
    'other': 'Other',

    // ─── Companies (TopOwner) ───
    'company_management': 'Company Management',
    'owner_name': 'Owner Name',
    'email': 'Email',
    'server_id_col': 'Server ID',
    'telegram_chat_id': 'Telegram Chat ID',
    'add_company': 'Add Company',
    'edit_company': 'Edit Company',
    'activate': 'Activate',
    'deactivate': 'Deactivate',
    'initial_password': 'Initial Password',
    'generate_server_id': 'Auto-generate Server ID',

    // ─── Firewall (TopOwner) ───
    'firewall_management': 'Firewall Management',
    'ip_address': 'IP Address',
    'failed_attempts': 'Failed Attempts',
    'blocked': 'Blocked',
    'not_blocked': 'Not Blocked',
    'blocked_until': 'Blocked Until',
    'reason': 'Reason',
    'unblock': 'Unblock',
    'unblock_confirm': 'Are you sure you want to unblock this IP?',

    // ─── Audit Logs ───
    'audit_log_title': 'Audit Logs',
    'action': 'Action',
    'user': 'User',
    'details': 'Details',
    'timestamp': 'Timestamp',

    // ─── Users ───
    'users_management': 'User Management',
    'role': 'Role',
    'add_user': 'Add User',

    // ─── Roles ───
    'roles_management': 'Roles & Permissions',
    'role_name': 'Role Name',
    'permissions': 'Permissions',
    'add_role': 'Add Role',

    // ─── Settings ───
    'settings_title': 'Settings',
    'language': 'Language',
    'arabic': 'العربية',
    'english': 'English',
    'theme': 'Theme',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'notifications': 'Notifications',
    'telegram_alerts': 'Telegram Alerts',
    'about': 'About System',
    'version': 'Version',

    // ─── TopOwner Dashboard ───
    'topowner_dashboard': 'Admin Control Panel',
    'total_companies': 'Total Companies',
    'active_companies': 'Active Companies',
    'inactive_companies': 'Inactive Companies',
    'blocked_ips': 'Blocked IPs',
    'system_overview': 'System Overview',
    'total_users': 'Total Users',

    // ─── Reports ───
    'reports_title': 'Reports',
    'coming_soon': 'Coming Soon...',
    'feature_coming_soon': 'This feature is under development',

    // ─── Time ───
    'minutes_ago': '{n} minutes ago',
    'hours_ago': '{n} hours ago',
    'just_now': 'Just now',
    'today': 'Today',

    // ─── Footer ───
    'copyright': '© FleetPro System 2025 - All rights reserved',

    // ─── Misc ───
    'confirm_delete': 'Are you sure you want to delete this item?',
    'success': 'Operation completed successfully',
    'error': 'An error occurred',
    'telegram_alert_sent': '📢 Telegram alert sent',
  };
}
