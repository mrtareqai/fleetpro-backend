import 'dart:math';

// ══════════════════════════════════════════════════
//  DATA MODELS
// ══════════════════════════════════════════════════

class Tenant {
  final String id;
  final String serverId;
  String name;
  String ownerName;
  String phone;
  String email;
  String? telegramChatId;
  bool isActive;
  final DateTime createdAt;

  Tenant({
    required this.id,
    required this.serverId,
    required this.name,
    required this.ownerName,
    required this.phone,
    required this.email,
    this.telegramChatId,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AppUser {
  final String id;
  final String? tenantId;
  String username;
  String password;
  final String role; // 'topowner', 'admin', 'operator', 'driver'
  bool mustChangePassword;
  bool isActive;
  String displayName;

  AppUser({
    required this.id,
    this.tenantId,
    required this.username,
    required this.password,
    required this.role,
    this.mustChangePassword = false,
    this.isActive = true,
    required this.displayName,
  });
}

class Vehicle {
  final int id;
  final String tenantId;
  String model;
  DateTime manufactureDate;
  String plateNumber;
  String baseNumber;
  String cardNumber;
  DateTime issueDate;
  DateTime expiryDate;
  String status; // 'active', 'inactive', 'expired'

  Vehicle({
    required this.id,
    required this.tenantId,
    required this.model,
    required this.manufactureDate,
    required this.plateNumber,
    required this.baseNumber,
    required this.cardNumber,
    required this.issueDate,
    required this.expiryDate,
    this.status = 'active',
  });
}

class Reservation {
  final int id;
  final String tenantId;
  String clientName;
  DateTime pickupDate;
  DateTime returnDate;
  String destination;
  String status;

  Reservation({
    required this.id,
    required this.tenantId,
    required this.clientName,
    required this.pickupDate,
    required this.returnDate,
    required this.destination,
    this.status = 'active',
  });
}

class Ticket {
  final String id;
  final String tenantId;
  String ticketNumber;
  String passengerName;
  String trip;
  DateTime tripDate;
  String seatNumber;
  String time;
  String phone;
  String assignedUser;
  DateTime issueDate;
  String destination;
  String status;

  Ticket({
    required this.id,
    required this.tenantId,
    required this.ticketNumber,
    required this.passengerName,
    required this.trip,
    required this.tripDate,
    required this.seatNumber,
    required this.time,
    required this.phone,
    required this.assignedUser,
    required this.issueDate,
    required this.destination,
    this.status = 'active',
  });
}

class Driver {
  final int id;
  final String tenantId;
  String name;
  String phone;
  String licenseNumber;
  DateTime licenseExpiry;
  String status;

  Driver({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    required this.licenseExpiry,
    this.status = 'active',
  });
}

class ActivityLog {
  final String id;
  final String? tenantId;
  final String? userId;
  final String action;
  final String description;
  final DateTime timestamp;
  final String? ipAddress;
  final String type; // 'create', 'update', 'delete', 'login', 'security'
  final String? userName;
  final String? icon;

  ActivityLog({
    required this.id,
    this.tenantId,
    this.userId,
    required this.action,
    required this.description,
    required this.timestamp,
    this.ipAddress,
    required this.type,
    this.userName,
    this.icon,
  });
}

class BlockedIp {
  final String ipAddress;
  int failedAttempts;
  bool isBlocked;
  DateTime? blockedUntil;
  String? reason;
  final DateTime createdAt;

  BlockedIp({
    required this.ipAddress,
    this.failedAttempts = 0,
    this.isBlocked = false,
    this.blockedUntil,
    this.reason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AppRole {
  final String id;
  String name;
  String nameAr;
  final String? tenantId;
  List<String> permissions;

  AppRole({
    required this.id,
    required this.name,
    required this.nameAr,
    this.tenantId,
    required this.permissions,
  });
}

class TripRoute {
  final int id;
  final String tenantId;
  String originCity;
  String destinationCity;
  int stopsCount;
  int estimatedDuration;
  double basePrice;
  int? branchId;
  int? agentId;
  final String status;

  TripRoute({
    required this.id,
    required this.tenantId,
    required this.originCity,
    required this.destinationCity,
    this.stopsCount = 0,
    required this.estimatedDuration,
    required this.basePrice,
    this.branchId,
    this.agentId,
    this.status = 'active',
  });
}

class Branch {
  final int id;
  final String tenantId;
  String name;
  String location;
  bool isActive;

  Branch({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.location,
    this.isActive = true,
  });
}

class Agent {
  final int id;
  final String tenantId;
  String name;
  String phone;
  int? branchId;
  double commission;
  bool isActive;

  Agent({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.phone,
    this.branchId,
    this.commission = 0.0,
    this.isActive = true,
  });
}

class Trip {
  final int id;
  final String tenantId;
  int routeId;
  int vehicleId;
  int driverId;
  DateTime departureTime;
  int totalSeats;
  int availableSeats;
  String status;

  Trip({
    required this.id,
    required this.tenantId,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    required this.departureTime,
    required this.totalSeats,
    required this.availableSeats,
    this.status = 'scheduled',
  });
}

class Transaction {
  final int id;
  final String tenantId;
  final String type; // 'income', 'expense'
  final double amount;
  final String category; // 'booking', 'refund', 'maintenance', 'salary', etc.
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.tenantId,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });
}

class Expense {
  final int id;
  final String tenantId;
  final double amount;
  final String category; // 'fuel', 'maintenance', 'supplies', 'other'
  final DateTime date;
  final String description;
  final int? vehicleId;
  final int? branchId;

  Expense({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.vehicleId,
    this.branchId,
  });
}

// ══════════════════════════════════════════════════
//  MOCK DATA
// ══════════════════════════════════════════════════

class MockData {
  static final Random _random = Random();

  // ─── Tenants ───
  static final List<Tenant> tenants = [
    Tenant(
      id: 't1',
      serverId: 'FLT-8XK92',
      name: 'شركة النقل الذهبي',
      ownerName: 'أحمد محمد علي',
      phone: '+966501234567',
      email: 'ahmed@golden-transport.com',
      telegramChatId: '123456789',
      isActive: true,
      createdAt: DateTime(2024, 1, 15),
    ),
    Tenant(
      id: 't2',
      serverId: 'FLT-3PLQ7',
      name: 'شركة الأسطول السريع',
      ownerName: 'خالد عبدالله',
      phone: '+966502345678',
      email: 'khaled@fast-fleet.com',
      telegramChatId: '987654321',
      isActive: true,
      createdAt: DateTime(2024, 3, 20),
    ),
    Tenant(
      id: 't3',
      serverId: 'FLT-5NWR4',
      name: 'شركة المسار الآمن',
      ownerName: 'سارة أحمد',
      phone: '+966503456789',
      email: 'sara@safe-path.com',
      telegramChatId: '456789123',
      isActive: false,
      createdAt: DateTime(2024, 6, 10),
    ),
  ];

  // ─── Users ───
  static final List<AppUser> users = [
    // TopOwner
    AppUser(
      id: 'u0',
      tenantId: null,
      username: 'topowner',
      password: 'mrtareq2008',
      role: 'topowner',
      mustChangePassword: false,
      displayName: 'المسؤول الأعلى',
    ),
    // Company 1 users
    AppUser(
      id: 'u1',
      tenantId: 't1',
      username: 'admin',
      password: 'password123',
      role: 'admin',
      mustChangePassword: true,
      displayName: 'أحمد محمد علي',
    ),
    AppUser(
      id: 'u2',
      tenantId: 't1',
      username: 'operator',
      password: 'op123',
      role: 'operator',
      mustChangePassword: false,
      displayName: 'محمد السالم',
    ),
    AppUser(
      id: 'u3',
      tenantId: 't1',
      username: 'driver1',
      password: 'dr123',
      role: 'driver',
      mustChangePassword: false,
      displayName: 'سائق ١',
    ),
    // Company 2 users
    AppUser(
      id: 'u4',
      tenantId: 't2',
      username: 'admin',
      password: 'admin123',
      role: 'admin',
      mustChangePassword: false,
      displayName: 'خالد عبدالله',
    ),
    AppUser(
      id: 'u5',
      tenantId: 't2',
      username: 'sara',
      password: 'sara123',
      role: 'operator',
      mustChangePassword: false,
      displayName: 'سارة محمد',
    ),
    // Company 3 users
    AppUser(
      id: 'u6',
      tenantId: 't3',
      username: 'admin',
      password: 'admin123',
      role: 'admin',
      mustChangePassword: false,
      displayName: 'سارة أحمد',
    ),
  ];

  // ─── Vehicles ───
  static final List<Vehicle> vehicles = [
    Vehicle(
      id: 1,
      tenantId: 't1',
      model: 'تويوتا كوستر 2023',
      manufactureDate: DateTime(2023, 1, 15),
      plateNumber: 'أ ب ج 1234',
      baseNumber: 'BS-001',
      cardNumber: 'CARD-001',
      issueDate: DateTime(2023, 2, 1),
      expiryDate: DateTime(2025, 12, 31),
      status: 'active',
    ),
    Vehicle(
      id: 2,
      tenantId: 't1',
      model: 'هيونداي يونيفرس 2022',
      manufactureDate: DateTime(2022, 6, 20),
      plateNumber: 'س ح ع 5678',
      baseNumber: 'BS-002',
      cardNumber: 'CARD-002',
      issueDate: DateTime(2022, 7, 15),
      expiryDate: DateTime(2025, 6, 30),
      status: 'active',
    ),
    Vehicle(
      id: 3,
      tenantId: 't1',
      model: 'مرسيدس سبرنتر 2021',
      manufactureDate: DateTime(2021, 3, 10),
      plateNumber: 'ن ه و 9012',
      baseNumber: 'BS-003',
      cardNumber: 'CARD-003',
      issueDate: DateTime(2021, 4, 5),
      expiryDate: DateTime(2024, 12, 31),
      status: 'inactive',
    ),
    Vehicle(
      id: 4,
      tenantId: 't1',
      model: 'كينج لونج 2020',
      manufactureDate: DateTime(2020, 9, 5),
      plateNumber: 'ل م ك 3456',
      baseNumber: 'BS-004',
      cardNumber: 'CARD-004',
      issueDate: DateTime(2020, 10, 1),
      expiryDate: DateTime(2024, 1, 15),
      status: 'expired',
    ),
    Vehicle(
      id: 5,
      tenantId: 't1',
      model: 'يوتونج 2023',
      manufactureDate: DateTime(2023, 5, 12),
      plateNumber: 'ر ز ط 7890',
      baseNumber: 'BS-005',
      cardNumber: 'CARD-005',
      issueDate: DateTime(2023, 6, 1),
      expiryDate: DateTime(2026, 5, 31),
      status: 'active',
    ),
    // Company 2 vehicles
    Vehicle(
      id: 6,
      tenantId: 't2',
      model: 'تويوتا هايس 2024',
      manufactureDate: DateTime(2024, 1, 1),
      plateNumber: 'ع ف ص 1111',
      baseNumber: 'BS-101',
      cardNumber: 'CARD-101',
      issueDate: DateTime(2024, 2, 1),
      expiryDate: DateTime(2027, 1, 31),
      status: 'active',
    ),
    Vehicle(
      id: 7,
      tenantId: 't2',
      model: 'ميتسوبيشي روزا 2023',
      manufactureDate: DateTime(2023, 8, 15),
      plateNumber: 'ق ك ل 2222',
      baseNumber: 'BS-102',
      cardNumber: 'CARD-102',
      issueDate: DateTime(2023, 9, 1),
      expiryDate: DateTime(2026, 8, 31),
      status: 'active',
    ),
  ];

  // ─── Reservations ───
  static final List<Reservation> reservations = [
    Reservation(
      id: 1,
      tenantId: 't1',
      clientName: 'أحمد محمد',
      pickupDate: DateTime(2025, 1, 15),
      returnDate: DateTime(2025, 1, 20),
      destination: 'الرياض',
      status: 'active',
    ),
    Reservation(
      id: 2,
      tenantId: 't1',
      clientName: 'فاطمة علي',
      pickupDate: DateTime(2025, 1, 18),
      returnDate: DateTime(2025, 1, 22),
      destination: 'جدة',
      status: 'completed',
    ),
    Reservation(
      id: 3,
      tenantId: 't1',
      clientName: 'عبدالرحمن سعيد',
      pickupDate: DateTime(2025, 1, 20),
      returnDate: DateTime(2025, 1, 25),
      destination: 'الدمام',
      status: 'active',
    ),
    Reservation(
      id: 4,
      tenantId: 't2',
      clientName: 'نورة خالد',
      pickupDate: DateTime(2025, 2, 1),
      returnDate: DateTime(2025, 2, 5),
      destination: 'مكة',
      status: 'active',
    ),
  ];

  // ─── Tickets ───
  static final List<Ticket> tickets = [
    Ticket(
      id: 'TR-001',
      tenantId: 't1',
      ticketNumber: 'TK-10001',
      passengerName: 'أحمد محمد علي',
      trip: 'الرياض - جدة',
      tripDate: DateTime(2025, 1, 15),
      seatNumber: 'A12',
      time: '08:00',
      phone: '+966501234567',
      assignedUser: 'محمد السالم',
      issueDate: DateTime(2025, 1, 10),
      destination: 'الرياض',
      status: 'active',
    ),
    Ticket(
      id: 'TR-002',
      tenantId: 't1',
      ticketNumber: 'TK-10002',
      passengerName: 'فاطمة عبدالله',
      trip: 'جدة - مكة',
      tripDate: DateTime(2025, 1, 15),
      seatNumber: 'B05',
      time: '10:30',
      phone: '+966502345678',
      assignedUser: 'محمد السالم',
      issueDate: DateTime(2025, 1, 11),
      destination: 'جدة',
      status: 'completed',
    ),
    Ticket(
      id: 'TR-003',
      tenantId: 't1',
      ticketNumber: 'TK-10003',
      passengerName: 'عبدالرحمن سعيد',
      trip: 'الدمام - الرياض',
      tripDate: DateTime(2025, 1, 16),
      seatNumber: 'C08',
      time: '06:00',
      phone: '+966503456789',
      assignedUser: 'أحمد محمد علي',
      issueDate: DateTime(2025, 1, 12),
      destination: 'الدمام',
      status: 'active',
    ),
    Ticket(
      id: 'TR-004',
      tenantId: 't1',
      ticketNumber: 'TK-10004',
      passengerName: 'نورة خالد',
      trip: 'الرياض - الدمام',
      tripDate: DateTime(2025, 1, 16),
      seatNumber: 'A15',
      time: '14:00',
      phone: '+966504567890',
      assignedUser: 'محمد السالم',
      issueDate: DateTime(2025, 1, 13),
      destination: 'الرياض',
      status: 'active',
    ),
    Ticket(
      id: 'TR-005',
      tenantId: 't1',
      ticketNumber: 'TK-10005',
      passengerName: 'ليلى حسن',
      trip: 'مكة - المدينة',
      tripDate: DateTime(2025, 1, 14),
      seatNumber: 'D20',
      time: '16:00',
      phone: '+966505678901',
      assignedUser: 'أحمد محمد علي',
      issueDate: DateTime(2025, 1, 9),
      destination: 'مكة',
      status: 'completed',
    ),
  ];

  // ─── Drivers ───
  static final List<Driver> drivers = [
    Driver(
      id: 1,
      tenantId: 't1',
      name: 'عبدالله الحارثي',
      phone: '+966511234567',
      licenseNumber: 'DL-001-2023',
      licenseExpiry: DateTime(2026, 6, 30),
      status: 'active',
    ),
    Driver(
      id: 2,
      tenantId: 't1',
      name: 'محمد القحطاني',
      phone: '+966512345678',
      licenseNumber: 'DL-002-2023',
      licenseExpiry: DateTime(2026, 3, 15),
      status: 'active',
    ),
    Driver(
      id: 3,
      tenantId: 't1',
      name: 'سعيد الغامدي',
      phone: '+966513456789',
      licenseNumber: 'DL-003-2022',
      licenseExpiry: DateTime(2025, 12, 31),
      status: 'inactive',
    ),
    Driver(
      id: 4,
      tenantId: 't2',
      name: 'فهد العتيبي',
      phone: '+966514567890',
      licenseNumber: 'DL-101-2024',
      licenseExpiry: DateTime(2027, 1, 15),
      status: 'active',
    ),
  ];

  // ─── Activity Logs ───
  static final List<ActivityLog> activityLogs = [
    ActivityLog(
      id: 'al1',
      tenantId: 't1',
      userId: 'u1',
      action: 'create_reservation',
      description: 'New reservation for customer Ahmed Mohamed',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: 'create',
      userName: 'admin',
      icon: '📅',
    ),
    ActivityLog(
      id: 'al2',
      tenantId: 't1',
      userId: 'u2',
      action: 'complete_ticket',
      description: 'Ticket #1234 completed',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: 'update',
      userName: 'operator',
      icon: '🎫',
    ),
    ActivityLog(
      id: 'al3',
      tenantId: 't1',
      userId: 'u3',
      action: 'update_movement',
      description: "Movement from Sana'a to Aden",
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      type: 'update',
      userName: 'driver',
      icon: '📍',
    ),
    ActivityLog(
      id: 'al4',
      tenantId: 't1',
      userId: 'u1',
      action: 'update_vehicle',
      description: 'Vehicle ABC-123 in maintenance',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      type: 'update',
      userName: 'admin',
      icon: '🚌',
    ),
    ActivityLog(
      id: 'al5',
      tenantId: 't1',
      userId: 'u1',
      action: 'create_driver',
      description: 'New driver added',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'create',
      userName: 'admin',
      icon: '👤',
    ),
    // Global system logs
    ActivityLog(
      id: 'al6',
      tenantId: null,
      userId: 'u0',
      action: 'deactivate_company',
      description: 'Company "شركة المسار الآمن" deactivated',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      type: 'security',
      userName: 'topowner',
      icon: '🏢',
    ),
    ActivityLog(
      id: 'al7',
      tenantId: null,
      userId: null,
      action: 'ip_blocked',
      description: 'IP 192.168.1.100 blocked after 8 failed attempts',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'security',
      userName: 'system',
      icon: '🛡️',
    ),
  ];

  // ─── Blocked IPs ───
  static final List<BlockedIp> blockedIps = [
    BlockedIp(
      ipAddress: '192.168.1.100',
      failedAttempts: 8,
      isBlocked: true,
      blockedUntil: DateTime.now().add(const Duration(hours: 24)),
      reason: 'محاولات دخول فاشلة متعددة',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    BlockedIp(
      ipAddress: '10.0.0.55',
      failedAttempts: 12,
      isBlocked: true,
      blockedUntil: DateTime.now().add(const Duration(hours: 48)),
      reason: 'محاولة اختراق مشتبه بها',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BlockedIp(
      ipAddress: '172.16.0.22',
      failedAttempts: 3,
      isBlocked: false,
      reason: null,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  // ─── Roles ───
  static final List<AppRole> roles = [
    AppRole(
      id: 'r1',
      name: 'Admin',
      nameAr: 'مدير',
      permissions: [
        'dashboard', 'fleet', 'reservations', 'tickets',
        'drivers', 'reports', 'settings', 'users', 'roles',
      ],
    ),
    AppRole(
      id: 'r2',
      name: 'Operator',
      nameAr: 'مشغّل',
      permissions: [
        'dashboard', 'reservations', 'tickets', 'drivers', 'reports',
      ],
    ),
    AppRole(
      id: 'r3',
      name: 'Driver',
      nameAr: 'سائق',
      permissions: ['dashboard'],
    ),
    AppRole(
      id: 'r4',
      name: 'Viewer',
      nameAr: 'مشاهد',
      permissions: ['dashboard', 'reports'],
    ),
  ];

  // ─── Routes ───
  static final List<TripRoute> routes = [
    TripRoute(
      id: 1,
      tenantId: 't1',
      originCity: 'الرياض',
      destinationCity: 'جدة',
      stopsCount: 1,
      estimatedDuration: 600,
      basePrice: 150.0,
      branchId: 1,
      status: 'active',
    ),
    TripRoute(
      id: 2,
      tenantId: 't1',
      originCity: 'الدمام',
      destinationCity: 'الرياض',
      stopsCount: 0,
      estimatedDuration: 240,
      basePrice: 80.0,
      branchId: 1,
      agentId: 1,
      status: 'active',
    ),
    TripRoute(
      id: 3,
      tenantId: 't2',
      originCity: 'مكة',
      destinationCity: 'المدينة',
      stopsCount: 0,
      estimatedDuration: 260,
      basePrice: 60.0,
      status: 'active',
    ),
  ];

  // ─── Branches ───
  static final List<Branch> branches = [
    Branch(id: 1, tenantId: 't1', name: 'الفرع الرئيسي', location: 'الرياض - حي العليا', isActive: true),
    Branch(id: 2, tenantId: 't1', name: 'فرع المنطقة الشرقية', location: 'الدمام', isActive: true),
    Branch(id: 3, tenantId: 't2', name: 'فرع مكة المكرمة', location: 'مكة', isActive: true),
  ];

  // ─── Agents ───
  static final List<Agent> agents = [
    Agent(id: 1, tenantId: 't1', name: 'وكالة الرحاب', phone: '+966500000001', branchId: 1, commission: 10.0, isActive: true),
    Agent(id: 2, tenantId: 't1', name: 'وكالة السفر السريع', phone: '+966500000002', branchId: 2, commission: 12.5, isActive: true),
  ];

  // ─── Trips ───
  static final List<Trip> trips = [
    Trip(
      id: 1,
      tenantId: 't1',
      routeId: 1,
      vehicleId: 1,
      driverId: 1,
      departureTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
      totalSeats: 45,
      availableSeats: 20,
      status: 'scheduled',
    ),
    Trip(
      id: 2,
      tenantId: 't1',
      routeId: 2,
      vehicleId: 2,
      driverId: 2,
      departureTime: DateTime.now().add(const Duration(days: 2)),
      totalSeats: 50,
      availableSeats: 50,
      status: 'scheduled',
    ),
  ];

  // ─── Transactions ───
  static final List<Transaction> transactions = [
    Transaction(id: 1, tenantId: 't1', type: 'income', amount: 1500.0, category: 'booking', date: DateTime.now().subtract(const Duration(days: 1)), description: 'إيرادات رحلة الرياض-جدة'),
    Transaction(id: 2, tenantId: 't1', type: 'expense', amount: 300.0, category: 'maintenance', date: DateTime.now().subtract(const Duration(hours: 5)), description: 'صيانة دورية للحافلة'),
  ];

  // ─── Expenses ───
  static final List<Expense> expenses = [
    Expense(id: 1, tenantId: 't1', amount: 500.0, category: 'fuel', date: DateTime.now().subtract(const Duration(days: 2)), description: 'تعبئة وقود ديزل', vehicleId: 1),
    Expense(id: 2, tenantId: 't1', amount: 150.0, category: 'supplies', date: DateTime.now().subtract(const Duration(days: 1)), description: 'مستلزمات مكتبية (ورق، حبر)', branchId: 1),
  ];

  // ─── Login attempts tracker (in-memory) ───
  static final Map<String, int> _loginAttempts = {};

  // ══════════════════════════════════════════════════
  //  HELPER METHODS
  // ══════════════════════════════════════════════════

  static Tenant? findTenantByServerId(String serverId) {
    try {
      return tenants.firstWhere(
        (t) => t.serverId.toLowerCase() == serverId.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns: 'success', 'wrong_credentials', 'server_not_found',
  /// 'company_inactive', 'ip_blocked', 'must_change_password'
  static Map<String, dynamic> attemptLogin({
    required String username,
    required String password,
    String? serverId,
    String ipAddress = '127.0.0.1',
  }) {
    // Check if IP is blocked
    final blockedIp = blockedIps.where(
      (b) => b.ipAddress == ipAddress && b.isBlocked,
    );
    if (blockedIp.isNotEmpty) {
      return {'status': 'ip_blocked', 'user': null, 'tenant': null};
    }

    // TopOwner login (no server_id)
    if (username.toLowerCase() == 'topowner') {
      final topOwner = users.firstWhere(
        (u) => u.username == 'topowner',
      );
      if (topOwner.password == password) {
        _loginAttempts[ipAddress] = 0;
        _addAuditLog(
          action: 'login_success',
          description: 'TopOwner logged in',
          userName: 'topowner',
          type: 'login',
        );
        return {'status': 'success', 'user': topOwner, 'tenant': null};
      } else {
        return _handleFailedLogin(ipAddress);
      }
    }

    // Regular user login
    if (serverId == null || serverId.isEmpty) {
      return {'status': 'server_not_found', 'user': null, 'tenant': null};
    }

    final tenant = findTenantByServerId(serverId);
    if (tenant == null) {
      final result = _handleFailedLogin(ipAddress);
      result['status'] = result['status'] == 'ip_blocked'
          ? 'ip_blocked'
          : 'server_not_found';
      return result;
    }

    if (!tenant.isActive) {
      return {'status': 'company_inactive', 'user': null, 'tenant': tenant};
    }

    // Find user within tenant
    AppUser? user;
    try {
      user = users.firstWhere(
        (u) =>
            u.tenantId == tenant.id &&
            u.username.toLowerCase() == username.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      user = null;
    }

    if (user == null) {
      return _handleFailedLogin(ipAddress);
    }

    if (!user.isActive) {
      return {'status': 'wrong_credentials', 'user': null, 'tenant': tenant};
    }

    // Success
    _loginAttempts[ipAddress] = 0;
    _addAuditLog(
      tenantId: tenant.id,
      action: 'login_success',
      description: '${user.displayName} logged in',
      userName: user.username,
      type: 'login',
    );

    if (user.mustChangePassword) {
      return {'status': 'must_change_password', 'user': user, 'tenant': tenant};
    }

    return {'status': 'success', 'user': user, 'tenant': tenant};
  }

  static Map<String, dynamic> _handleFailedLogin(String ipAddress) {
    _loginAttempts[ipAddress] = (_loginAttempts[ipAddress] ?? 0) + 1;
    final attempts = _loginAttempts[ipAddress]!;

    if (attempts >= 8) {
      // Block IP
      blockedIps.add(BlockedIp(
        ipAddress: ipAddress,
        failedAttempts: attempts,
        isBlocked: true,
        blockedUntil: DateTime.now().add(const Duration(hours: 24)),
        reason: 'محاولات دخول فاشلة متعددة ($attempts محاولة)',
      ));
      _addAuditLog(
        action: 'ip_blocked',
        description: 'IP $ipAddress blocked after $attempts failed attempts',
        type: 'security',
      );
      return {
        'status': 'ip_blocked',
        'user': null,
        'tenant': null,
        'attempts': attempts,
      };
    }

    return {
      'status': 'wrong_credentials',
      'user': null,
      'tenant': null,
      'attempts': attempts,
      'remaining': 8 - attempts,
    };
  }

  static void _addAuditLog({
    String? tenantId,
    required String action,
    required String description,
    String? userName,
    required String type,
  }) {
    activityLogs.insert(
      0,
      ActivityLog(
        id: 'al${activityLogs.length + 1}',
        tenantId: tenantId,
        action: action,
        description: description,
        timestamp: DateTime.now(),
        type: type,
        userName: userName ?? 'system',
        icon: _getIconForAction(action),
      ),
    );
  }

  static String _getIconForAction(String action) {
    if (action.contains('login')) return '🔐';
    if (action.contains('block')) return '🛡️';
    if (action.contains('company') || action.contains('tenant')) return '🏢';
    if (action.contains('vehicle')) return '🚌';
    if (action.contains('driver')) return '👤';
    if (action.contains('reservation')) return '📅';
    if (action.contains('ticket')) return '🎫';
    if (action.contains('password')) return '🔑';
    return '📋';
  }

  static String generateServerId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final segment1 = List.generate(
      5,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
    return 'FLT-$segment1';
  }

  // ─── Stats helpers ───

  static int vehicleCountForTenant(String tenantId) =>
      vehicles.where((v) => v.tenantId == tenantId).length;

  static int driverCountForTenant(String tenantId) =>
      drivers.where((d) => d.tenantId == tenantId).length;

  static int activeReservationsForTenant(String tenantId) =>
      reservations
          .where((r) => r.tenantId == tenantId && r.status == 'active')
          .length;

  static int ticketCountForTenant(String tenantId) =>
      tickets.where((t) => t.tenantId == tenantId).length;

  static Map<String, int> fleetStatusForTenant(String tenantId) {
    final tenantVehicles =
        vehicles.where((v) => v.tenantId == tenantId).toList();
    return {
      'active': tenantVehicles.where((v) => v.status == 'active').length,
      'inactive': tenantVehicles.where((v) => v.status == 'inactive').length,
      'expired': tenantVehicles.where((v) => v.status == 'expired').length,
    };
  }

  static List<ActivityLog> activitiesForTenant(String tenantId) =>
      activityLogs.where((a) => a.tenantId == tenantId).toList();

  static List<ActivityLog> globalActivities() => activityLogs;

  // Chart data (monthly)
  static List<double> monthlyData() => [3, 7, 12, 8, 15, 22];
  static List<String> monthLabelsAr() =>
      ['نوفمبر', 'ديسمبر', 'يناير', 'فبراير', 'مارس', 'أبريل'];
  static List<String> monthLabelsEn() =>
      ['Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr'];

  // Chart data (weekly)
  static List<double> weeklyData() => [5, 8, 12, 18, 28, 15, 10];
  static List<String> weekDaysAr() =>
      ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  static List<String> weekDaysEn() =>
      ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
}
