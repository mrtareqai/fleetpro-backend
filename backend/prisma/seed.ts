import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // Clear existing data
  await prisma.expense.deleteMany()
  await prisma.transaction.deleteMany()
  await prisma.ticket.deleteMany()
  await prisma.reservation.deleteMany()
  await prisma.trip.deleteMany()
  await prisma.driver.deleteMany()
  await prisma.tripRoute.deleteMany()
  await prisma.agent.deleteMany()
  await prisma.branch.deleteMany()
  await prisma.vehicle.deleteMany()
  await prisma.appUser.deleteMany()
  await prisma.tenant.deleteMany()

  // Tenants
  await prisma.tenant.createMany({
    data: [
      {
        id: 't1',
        serverId: 'FLT-8XK92',
        name: 'شركة النقل الذهبي',
        ownerName: 'أحمد محمد علي',
        phone: '+966501234567',
        email: 'ahmed@golden-transport.com',
        telegramChatId: '123456789',
        isActive: true,
        createdAt: new Date('2024-01-15'),
      },
      {
        id: 't2',
        serverId: 'FLT-3PLQ7',
        name: 'شركة الأسطول السريع',
        ownerName: 'خالد عبدالله',
        phone: '+966502345678',
        email: 'khaled@fast-fleet.com',
        telegramChatId: '987654321',
        isActive: true,
        createdAt: new Date('2024-03-20'),
      },
      {
        id: 't3',
        serverId: 'FLT-5NWR4',
        name: 'شركة المسار الآمن',
        ownerName: 'سارة أحمد',
        phone: '+966503456789',
        email: 'sara@safe-path.com',
        telegramChatId: '456789123',
        isActive: false,
        createdAt: new Date('2024-06-10'),
      },
    ],
  })

  // Users
  await prisma.appUser.createMany({
    data: [
      { id: 'u0', username: 'topowner', password: 'mrtareq2008', role: 'topowner', displayName: 'المسؤول الأعلى' },
      { id: 'u1', tenantId: 't1', username: 'admin', password: 'password123', role: 'admin', mustChangePassword: true, displayName: 'أحمد محمد علي' },
      { id: 'u2', tenantId: 't1', username: 'operator', password: 'op123', role: 'operator', displayName: 'محمد السالم' },
      { id: 'u3', tenantId: 't1', username: 'driver1', password: 'dr123', role: 'driver', displayName: 'سائق ١' },
      { id: 'u4', tenantId: 't2', username: 'admin_t2', password: 'admin123', role: 'admin', displayName: 'خالد عبدالله' },
      { id: 'u5', tenantId: 't2', username: 'sara', password: 'sara123', role: 'operator', displayName: 'سارة محمد' },
      { id: 'u6', tenantId: 't3', username: 'admin_t3', password: 'admin123', role: 'admin', displayName: 'سارة أحمد' },
    ],
  })

  // Vehicles
  await prisma.vehicle.createMany({
    data: [
      { id: 1, tenantId: 't1', model: 'تويوتا كوستر 2023', manufactureDate: new Date('2023-01-15'), plateNumber: 'أ ب ج 1234', baseNumber: 'BS-001', cardNumber: 'CARD-001', issueDate: new Date('2023-02-01'), expiryDate: new Date('2025-12-31'), status: 'active' },
      { id: 2, tenantId: 't1', model: 'هيونداي يونيفرس 2022', manufactureDate: new Date('2022-06-20'), plateNumber: 'س ح ع 5678', baseNumber: 'BS-002', cardNumber: 'CARD-002', issueDate: new Date('2022-07-15'), expiryDate: new Date('2025-06-30'), status: 'active' },
      { id: 3, tenantId: 't1', model: 'مرسيدس سبرنتر 2021', manufactureDate: new Date('2021-03-10'), plateNumber: 'ن ه و 9012', baseNumber: 'BS-003', cardNumber: 'CARD-003', issueDate: new Date('2021-04-05'), expiryDate: new Date('2024-12-31'), status: 'inactive' },
      { id: 4, tenantId: 't1', model: 'كينج لونج 2020', manufactureDate: new Date('2020-09-05'), plateNumber: 'ل م ك 3456', baseNumber: 'BS-004', cardNumber: 'CARD-004', issueDate: new Date('2020-10-01'), expiryDate: new Date('2024-01-15'), status: 'expired' },
      { id: 5, tenantId: 't1', model: 'يوتونج 2023', manufactureDate: new Date('2023-05-12'), plateNumber: 'ر ز ط 7890', baseNumber: 'BS-005', cardNumber: 'CARD-005', issueDate: new Date('2023-06-01'), expiryDate: new Date('2026-05-31'), status: 'active' },
      { id: 6, tenantId: 't2', model: 'تويوتا هايس 2024', manufactureDate: new Date('2024-01-01'), plateNumber: 'ع ف ص 1111', baseNumber: 'BS-101', cardNumber: 'CARD-101', issueDate: new Date('2024-02-01'), expiryDate: new Date('2027-01-31'), status: 'active' },
      { id: 7, tenantId: 't2', model: 'ميتسوبيشي روزا 2023', manufactureDate: new Date('2023-08-15'), plateNumber: 'ق ك ل 2222', baseNumber: 'BS-102', cardNumber: 'CARD-102', issueDate: new Date('2023-09-01'), expiryDate: new Date('2026-08-31'), status: 'active' },
    ]
  })

  // Branch
  await prisma.branch.createMany({
    data: [
      { id: 1, tenantId: 't1', name: 'الفرع الرئيسي', location: 'الرياض - حي العليا', isActive: true },
      { id: 2, tenantId: 't1', name: 'فرع المنطقة الشرقية', location: 'الدمام', isActive: true },
      { id: 3, tenantId: 't2', name: 'فرع مكة المكرمة', location: 'مكة', isActive: true },
    ]
  })

  // Agent
  await prisma.agent.createMany({
    data: [
      { id: 1, tenantId: 't1', name: 'وكالة الرحاب', phone: '+966500000001', branchId: 1, commission: 10.0, isActive: true },
      { id: 2, tenantId: 't1', name: 'وكالة السفر السريع', phone: '+966500000002', branchId: 2, commission: 12.5, isActive: true },
    ]
  })

  // TripRoute
  await prisma.tripRoute.createMany({
    data: [
      { id: 1, tenantId: 't1', originCity: 'الرياض', destinationCity: 'جدة', stopsCount: 1, estimatedDuration: 600, basePrice: 150.0, branchId: 1, status: 'active' },
      { id: 2, tenantId: 't1', originCity: 'الدمام', destinationCity: 'الرياض', stopsCount: 0, estimatedDuration: 240, basePrice: 80.0, branchId: 1, agentId: 1, status: 'active' },
      { id: 3, tenantId: 't2', originCity: 'مكة', destinationCity: 'المدينة', stopsCount: 0, estimatedDuration: 260, basePrice: 60.0, status: 'active' },
    ]
  })

  // Driver
  await prisma.driver.createMany({
    data: [
      { id: 1, tenantId: 't1', name: 'عبدالله الحارثي', phone: '+966511234567', licenseNumber: 'DL-001-2023', licenseExpiry: new Date('2026-06-30'), status: 'active' },
      { id: 2, tenantId: 't1', name: 'محمد القحطاني', phone: '+966512345678', licenseNumber: 'DL-002-2023', licenseExpiry: new Date('2026-03-15'), status: 'active' },
      { id: 3, tenantId: 't1', name: 'سعيد الغامدي', phone: '+966513456789', licenseNumber: 'DL-003-2022', licenseExpiry: new Date('2025-12-31'), status: 'inactive' },
      { id: 4, tenantId: 't2', name: 'فهد العتيبي', phone: '+966514567890', licenseNumber: 'DL-101-2024', licenseExpiry: new Date('2027-01-15'), status: 'active' },
    ]
  })

  // Trip
  await prisma.trip.createMany({
    data: [
      { id: 1, tenantId: 't1', routeId: 1, vehicleId: 1, driverId: 1, departureTime: new Date(new Date().getTime() + 86400000), totalSeats: 45, availableSeats: 20, status: 'scheduled' },
      { id: 2, tenantId: 't1', routeId: 2, vehicleId: 2, driverId: 2, departureTime: new Date(new Date().getTime() + 172800000), totalSeats: 50, availableSeats: 50, status: 'scheduled' },
    ]
  })

  // Reservations
  await prisma.reservation.createMany({
    data: [
      { id: 1, tenantId: 't1', clientName: 'أحمد محمد', pickupDate: new Date('2025-01-15'), returnDate: new Date('2025-01-20'), destination: 'الرياض', status: 'active' },
      { id: 2, tenantId: 't1', clientName: 'فاطمة علي', pickupDate: new Date('2025-01-18'), returnDate: new Date('2025-01-22'), destination: 'جدة', status: 'completed' },
      { id: 3, tenantId: 't1', clientName: 'عبدالرحمن سعيد', pickupDate: new Date('2025-01-20'), returnDate: new Date('2025-01-25'), destination: 'الدمام', status: 'active' },
      { id: 4, tenantId: 't2', clientName: 'نورة خالد', pickupDate: new Date('2025-02-01'), returnDate: new Date('2025-02-05'), destination: 'مكة', status: 'active' },
    ]
  })

  // Tickets
  await prisma.ticket.createMany({
    data: [
      { id: 'TR-001', tenantId: 't1', ticketNumber: 'TK-10001', passengerName: 'أحمد محمد علي', trip: 'الرياض - جدة', tripDate: new Date('2025-01-15'), seatNumber: 'A12', time: '08:00', phone: '+966501234567', assignedUser: 'محمد السالم', issueDate: new Date('2025-01-10'), destination: 'الرياض', status: 'active' },
      { id: 'TR-002', tenantId: 't1', ticketNumber: 'TK-10002', passengerName: 'فاطمة عبدالله', trip: 'جدة - مكة', tripDate: new Date('2025-01-15'), seatNumber: 'B05', time: '10:30', phone: '+966502345678', assignedUser: 'محمد السالم', issueDate: new Date('2025-01-11'), destination: 'جدة', status: 'completed' },
      { id: 'TR-003', tenantId: 't1', ticketNumber: 'TK-10003', passengerName: 'عبدالرحمن سعيد', trip: 'الدمام - الرياض', tripDate: new Date('2025-01-16'), seatNumber: 'C08', time: '06:00', phone: '+966503456789', assignedUser: 'أحمد محمد علي', issueDate: new Date('2025-01-12'), destination: 'الدمام', status: 'active' },
      { id: 'TR-004', tenantId: 't1', ticketNumber: 'TK-10004', passengerName: 'نورة خالد', trip: 'الرياض - الدمام', tripDate: new Date('2025-01-16'), seatNumber: 'A15', time: '14:00', phone: '+966504567890', assignedUser: 'محمد السالم', issueDate: new Date('2025-01-13'), destination: 'الرياض', status: 'active' },
      { id: 'TR-005', tenantId: 't1', ticketNumber: 'TK-10005', passengerName: 'ليلى حسن', trip: 'مكة - المدينة', tripDate: new Date('2025-01-14'), seatNumber: 'D20', time: '16:00', phone: '+966505678901', assignedUser: 'أحمد محمد علي', issueDate: new Date('2025-01-09'), destination: 'مكة', status: 'completed' },
    ]
  })

  // Transactions
  await prisma.transaction.createMany({
    data: [
      { id: 1, tenantId: 't1', type: 'income', amount: 1500.0, category: 'booking', date: new Date(), description: 'إيرادات رحلة الرياض-جدة' },
      { id: 2, tenantId: 't1', type: 'expense', amount: 300.0, category: 'maintenance', date: new Date(), description: 'صيانة دورية للحافلة' },
    ]
  })

  // Expenses
  await prisma.expense.createMany({
    data: [
      { id: 1, tenantId: 't1', amount: 500.0, category: 'fuel', date: new Date(), description: 'تعبئة وقود ديزل', vehicleId: 1 },
      { id: 2, tenantId: 't1', amount: 150.0, category: 'supplies', date: new Date(), description: 'مستلزمات مكتبية (ورق، حبر)', branchId: 1 },
    ]
  })

  console.log('Seeding completed successfully!')
}

main()
  .catch(e => {
    console.error(e)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
