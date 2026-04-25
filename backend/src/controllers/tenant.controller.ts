import { Request, Response } from 'express'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

// ═══════════════════════════════════════════════
//  ROUTES
// ═══════════════════════════════════════════════
export const getRoutes = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const routes = await prisma.tripRoute.findMany({
    where: { tenantId },
    include: {
      branch: { select: { id: true, name: true } },
      agent: { select: { id: true, name: true } },
    },
  })
  res.json(routes)
}

// ═══════════════════════════════════════════════
//  TRIPS
// ═══════════════════════════════════════════════
export const getTrips = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const trips = await prisma.trip.findMany({
    where: { tenantId },
    include: {
      route: true,
      vehicle: true,
      driver: true,
    },
  })
  res.json(trips)
}

export const createTrip = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { routeId, vehicleId, driverId, departureTime, totalSeats } = req.body

  const trip = await prisma.trip.create({
    data: {
      tenantId,
      routeId: Number(routeId),
      vehicleId: Number(vehicleId),
      driverId: Number(driverId),
      departureTime: new Date(departureTime),
      totalSeats: Number(totalSeats),
      availableSeats: Number(totalSeats),
      status: 'scheduled',
    },
    include: { route: true, vehicle: true, driver: true },
  })
  res.status(201).json(trip)
}

export const updateTrip = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const { status, availableSeats } = req.body

  const trip = await prisma.trip.updateMany({
    where: { id: Number(id), tenantId },
    data: {
      ...(status && { status }),
      ...(availableSeats !== undefined && { availableSeats: Number(availableSeats) }),
    },
  })
  res.json(trip)
}

export const deleteTrip = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.trip.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  VEHICLES
// ═══════════════════════════════════════════════
export const getVehicles = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const vehicles = await prisma.vehicle.findMany({ where: { tenantId } })
  res.json(vehicles)
}

export const createVehicle = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const data = req.body
  const vehicle = await prisma.vehicle.create({
    data: { ...data, tenantId, manufactureDate: new Date(data.manufactureDate), issueDate: new Date(data.issueDate), expiryDate: new Date(data.expiryDate) }
  })
  res.status(201).json(vehicle)
}

export const updateVehicle = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const vehicle = await prisma.vehicle.updateMany({ where: { id: Number(id), tenantId }, data: req.body })
  res.json(vehicle)
}

export const deleteVehicle = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.vehicle.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  DRIVERS
// ═══════════════════════════════════════════════
export const getDrivers = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const drivers = await prisma.driver.findMany({ where: { tenantId } })
  res.json(drivers)
}

export const createDriver = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const data = req.body
  const driver = await prisma.driver.create({
    data: { ...data, tenantId, licenseExpiry: new Date(data.licenseExpiry) }
  })
  res.status(201).json(driver)
}

export const updateDriver = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const driver = await prisma.driver.updateMany({ where: { id: Number(id), tenantId }, data: req.body })
  res.json(driver)
}

export const deleteDriver = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.driver.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  BOOKINGS / RESERVATIONS
// ═══════════════════════════════════════════════
export const getBookings = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const bookings = await prisma.reservation.findMany({ where: { tenantId } })
  res.json(bookings)
}

export const createBooking = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const data = req.body
  const booking = await prisma.reservation.create({
    data: { ...data, tenantId, pickupDate: new Date(data.pickupDate), returnDate: new Date(data.returnDate) }
  })
  res.status(201).json(booking)
}

export const updateBooking = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const data = req.body
  const booking = await prisma.reservation.updateMany({
    where: { id: Number(id), tenantId },
    data: { ...data, ...(data.pickupDate && { pickupDate: new Date(data.pickupDate) }), ...(data.returnDate && { returnDate: new Date(data.returnDate) }) }
  })
  res.json(booking)
}

export const deleteBooking = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.reservation.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  TICKETS & SEAT RESERVATION LOGIC
// ═══════════════════════════════════════════════
export const getTickets = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const tickets = await prisma.ticket.findMany({ where: { tenantId } })
  res.json(tickets)
}

export const bookTicket = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { tripId, passengerName, phone, seatNumber, destination } = req.body
  const assignedUser = req.user!.username

  // 1. Transaction to atomically check availability, decrement seats, and create ticket
  const result = await prisma.$transaction(async (tx) => {
    // 1a. Fetch trip with lock to prevent race conditions
    // Prisma does not support FOR UPDATE in findUnique out of the box unless using raw queries.
    // However, we can use an optimistic concurrency check or update-if-available.
    // The safest way in Prisma is an update that includes a condition availableSeats > 0.

    const updatedTrip = await tx.trip.updateMany({
      where: {
        id: Number(tripId),
        tenantId,
        availableSeats: { gt: 0 }
      },
      data: {
        availableSeats: { decrement: 1 }
      }
    })

    if (updatedTrip.count === 0) {
      throw new Error('لا توجد مقاعد متاحة في هذه الرحلة أو الرحلة غير موجودة.')
    }

    // Now that the seat is secured, fetch the trip to get data for the ticket
    const trip = await tx.trip.findFirst({
      where: { id: Number(tripId) },
      include: { route: true }
    })

    // 1b. Create the ticket
    const ticket = await tx.ticket.create({
      data: {
        id: `TKT-${Date.now()}`,
        tenantId,
        ticketNumber: `T-${Math.floor(1000 + Math.random() * 9000)}`,
        passengerName,
        phone,
        seatNumber: seatNumber?.toString() || 'Any',
        trip: trip!.route.destinationCity,
        tripDate: trip!.departureTime,
        time: trip!.departureTime.toISOString().split('T')[1].substring(0, 5),
        assignedUser,
        destination: destination || trip!.route.destinationCity,
        issueDate: new Date(),
        status: 'active'
      }
    })

    return ticket
  })

  res.status(201).json(result)
}

// ═══════════════════════════════════════════════
//  BRANCHES
// ═══════════════════════════════════════════════
export const getBranches = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  res.json(await prisma.branch.findMany({ where: { tenantId } }))
}

export const createBranch = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const branch = await prisma.branch.create({ data: { ...req.body, tenantId } })
  res.status(201).json(branch)
}

export const updateBranch = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const branch = await prisma.branch.updateMany({ where: { id: Number(id), tenantId }, data: req.body })
  res.json(branch)
}

export const deleteBranch = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.branch.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  AGENTS
// ═══════════════════════════════════════════════
export const getAgents = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  res.json(await prisma.agent.findMany({ where: { tenantId } }))
}

export const createAgent = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const agent = await prisma.agent.create({ data: { ...req.body, tenantId } })
  res.status(201).json(agent)
}

export const updateAgent = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const agent = await prisma.agent.updateMany({ where: { id: Number(id), tenantId }, data: req.body })
  res.json(agent)
}

export const deleteAgent = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.agent.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  TRANSACTIONS
// ═══════════════════════════════════════════════
export const getTransactions = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  res.json(await prisma.transaction.findMany({ where: { tenantId }, orderBy: { date: 'desc' } }))
}

export const createTransaction = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const data = req.body
  const transaction = await prisma.transaction.create({
    data: { ...data, tenantId, date: new Date(data.date), amount: Number(data.amount) }
  })
  res.status(201).json(transaction)
}

export const updateTransaction = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const data = req.body
  const transaction = await prisma.transaction.updateMany({
    where: { id: Number(id), tenantId },
    data: { ...data, ...(data.date && { date: new Date(data.date) }), ...(data.amount !== undefined && { amount: Number(data.amount) }) }
  })
  res.json(transaction)
}

export const deleteTransaction = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.transaction.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  EXPENSES
// ═══════════════════════════════════════════════
export const getExpenses = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  res.json(await prisma.expense.findMany({ where: { tenantId }, orderBy: { date: 'desc' } }))
}

export const createExpense = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const data = req.body
  const expense = await prisma.expense.create({
    data: {
      ...data,
      tenantId,
      date: new Date(data.date),
      amount: Number(data.amount),
      vehicleId: data.vehicleId ? Number(data.vehicleId) : null,
      branchId: data.branchId ? Number(data.branchId) : null
    }
  })
  res.status(201).json(expense)
}

export const updateExpense = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const data = req.body
  const expense = await prisma.expense.updateMany({
    where: { id: Number(id), tenantId },
    data: {
      ...data,
      ...(data.date && { date: new Date(data.date) }),
      ...(data.amount !== undefined && { amount: Number(data.amount) }),
      ...(data.vehicleId !== undefined && { vehicleId: data.vehicleId ? Number(data.vehicleId) : null }),
      ...(data.branchId !== undefined && { branchId: data.branchId ? Number(data.branchId) : null })
    }
  })
  res.json(expense)
}

export const deleteExpense = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.expense.deleteMany({ where: { id: Number(id), tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  ACTIVITY LOGS / MOVEMENTS
// ═══════════════════════════════════════════════
export const getLogs = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const logs = await prisma.activityLog.findMany({ 
    where: { tenantId },
    orderBy: { timestamp: 'desc' },
    take: 100
  })
  res.json(logs)
}

// ═══════════════════════════════════════════════
//  NOTIFICATIONS
// ═══════════════════════════════════════════════
export const getNotifications = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const notifications = await prisma.notification.findMany({
    where: { tenantId },
    orderBy: { createdAt: 'desc' }
  })
  res.json(notifications)
}

export const markNotificationRead = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const notification = await prisma.notification.updateMany({
    where: { id: Number(id), tenantId },
    data: { isRead: true }
  })
  res.json(notification)
}

// ═══════════════════════════════════════════════
//  ROLES
// ═══════════════════════════════════════════════
export const getRoles = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const roles = await prisma.appRole.findMany({ where: { tenantId } })
  res.json(roles)
}

export const createRole = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { name, nameAr, permissions } = req.body
  const role = await prisma.appRole.create({
    data: {
      id: `role_${Date.now()}`,
      tenantId,
      name,
      nameAr: nameAr || name,
      permissions
    }
  })
  res.status(201).json(role)
}

export const updateRole = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const { name, nameAr, permissions } = req.body
  const role = await prisma.appRole.updateMany({
    where: { id, tenantId },
    data: { name, nameAr, permissions }
  })
  res.json(role)
}

export const deleteRole = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.appRole.deleteMany({ where: { id, tenantId } })
  res.json({ success: true })
}

// ═══════════════════════════════════════════════
//  USERS
// ═══════════════════════════════════════════════
export const getUsers = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const users = await prisma.appUser.findMany({ 
    where: { tenantId },
    select: {
      id: true,
      username: true,
      role: true,
      displayName: true,
      isActive: true,
      mustChangePassword: true,
      tenantId: true
    }
  })
  res.json(users)
}

export const createUser = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { username, password, role, displayName, isActive } = req.body
  try {
    const user = await prisma.appUser.create({
      data: {
        id: `u_${Date.now()}`,
        tenantId,
        username,
        password,
        role,
        displayName: displayName || username,
        isActive: isActive !== undefined ? isActive : true,
        mustChangePassword: true // Always true for new users
      }
    })
    res.status(201).json({ id: user.id, username: user.username, role: user.role, isActive: user.isActive })
  } catch (error: any) {
    if (error.code === 'P2002') {
      res.status(400).json({ error: 'اسم المستخدم مسجل مسبقاً' })
    } else {
      res.status(500).json({ error: 'حدث خطأ داخلي' })
    }
  }
}

export const updateUser = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  const { displayName, role, isActive, password } = req.body

  const data: any = { displayName, role, isActive }
  if (password && password.trim() !== '') {
    data.password = password
    data.mustChangePassword = true
  }

  const user = await prisma.appUser.updateMany({
    where: { id, tenantId },
    data
  })
  res.json(user)
}

export const deleteUser = async (req: Request, res: Response) => {
  const tenantId = req.user!.tenantId!
  const { id } = req.params
  await prisma.appUser.deleteMany({ where: { id, tenantId } })
  res.json({ success: true })
}
