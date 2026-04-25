import { Router } from 'express'
import { asyncHandler } from '../middlewares/errorHandler'
import { authMiddleware, requireTenant, requireRole } from '../middlewares/authMiddleware'
import * as tenantController from '../controllers/tenant.controller'

const router = Router()

// جميع مسارات هذا الـ Router تتطلب توثيق وانتماء لشركة
router.use(authMiddleware, requireTenant)

const adminManager = requireRole(['admin', 'manager'])
const anyStaff = requireRole(['admin', 'manager', 'agent', 'driver'])

// ═══════════════════════════════════════════════
//  ROUTES
// ═══════════════════════════════════════════════
router.get('/routes', asyncHandler(tenantController.getRoutes))

// ═══════════════════════════════════════════════
//  TRIPS
// ═══════════════════════════════════════════════
router.get('/trips', asyncHandler(tenantController.getTrips))
router.post('/trips', adminManager, asyncHandler(tenantController.createTrip))
router.put('/trips/:id', adminManager, asyncHandler(tenantController.updateTrip))
router.delete('/trips/:id', adminManager, asyncHandler(tenantController.deleteTrip))

// ═══════════════════════════════════════════════
//  VEHICLES
// ═══════════════════════════════════════════════
router.get('/vehicles', asyncHandler(tenantController.getVehicles))
router.post('/vehicles', adminManager, asyncHandler(tenantController.createVehicle))
router.put('/vehicles/:id', adminManager, asyncHandler(tenantController.updateVehicle))
router.delete('/vehicles/:id', adminManager, asyncHandler(tenantController.deleteVehicle))

// ═══════════════════════════════════════════════
//  DRIVERS
// ═══════════════════════════════════════════════
router.get('/drivers', adminManager, asyncHandler(tenantController.getDrivers))
router.post('/drivers', adminManager, asyncHandler(tenantController.createDriver))
router.put('/drivers/:id', adminManager, asyncHandler(tenantController.updateDriver))
router.delete('/drivers/:id', adminManager, asyncHandler(tenantController.deleteDriver))

// ═══════════════════════════════════════════════
//  BOOKINGS / RESERVATIONS
// ═══════════════════════════════════════════════
router.get('/bookings', anyStaff, asyncHandler(tenantController.getBookings))
router.post('/bookings', anyStaff, asyncHandler(tenantController.createBooking))
router.put('/bookings/:id', anyStaff, asyncHandler(tenantController.updateBooking))
router.delete('/bookings/:id', anyStaff, asyncHandler(tenantController.deleteBooking))

// ═══════════════════════════════════════════════
//  TICKETS
// ═══════════════════════════════════════════════
router.get('/tickets', anyStaff, asyncHandler(tenantController.getTickets))
router.post('/tickets/book', anyStaff, asyncHandler(tenantController.bookTicket))

// ═══════════════════════════════════════════════
//  BRANCHES & AGENTS
// ═══════════════════════════════════════════════
router.get('/branches', adminManager, asyncHandler(tenantController.getBranches))
router.post('/branches', adminManager, asyncHandler(tenantController.createBranch))
router.put('/branches/:id', adminManager, asyncHandler(tenantController.updateBranch))
router.delete('/branches/:id', adminManager, asyncHandler(tenantController.deleteBranch))

router.get('/agents', adminManager, asyncHandler(tenantController.getAgents))
router.post('/agents', adminManager, asyncHandler(tenantController.createAgent))
router.put('/agents/:id', adminManager, asyncHandler(tenantController.updateAgent))
router.delete('/agents/:id', adminManager, asyncHandler(tenantController.deleteAgent))

// ═══════════════════════════════════════════════
//  TRANSACTIONS & EXPENSES
// ═══════════════════════════════════════════════
router.get('/transactions', adminManager, asyncHandler(tenantController.getTransactions))
router.post('/transactions', adminManager, asyncHandler(tenantController.createTransaction))
router.put('/transactions/:id', adminManager, asyncHandler(tenantController.updateTransaction))
router.delete('/transactions/:id', adminManager, asyncHandler(tenantController.deleteTransaction))

router.get('/expenses', adminManager, asyncHandler(tenantController.getExpenses))
router.post('/expenses', adminManager, asyncHandler(tenantController.createExpense))
router.put('/expenses/:id', adminManager, asyncHandler(tenantController.updateExpense))
router.delete('/expenses/:id', adminManager, asyncHandler(tenantController.deleteExpense))

// ═══════════════════════════════════════════════
//  LOGS & NOTIFICATIONS
// ═══════════════════════════════════════════════
router.get('/logs', adminManager, asyncHandler(tenantController.getLogs))
router.get('/notifications', anyStaff, asyncHandler(tenantController.getNotifications))
router.put('/notifications/:id/read', anyStaff, asyncHandler(tenantController.markNotificationRead))

// ═══════════════════════════════════════════════
//  ROLES
// ═══════════════════════════════════════════════
router.get('/roles', adminManager, asyncHandler(tenantController.getRoles))
router.post('/roles', adminManager, asyncHandler(tenantController.createRole))
router.put('/roles/:id', adminManager, asyncHandler(tenantController.updateRole))
router.delete('/roles/:id', adminManager, asyncHandler(tenantController.deleteRole))

// ═══════════════════════════════════════════════
//  USERS
// ═══════════════════════════════════════════════
router.get('/users', adminManager, asyncHandler(tenantController.getUsers))
router.post('/users', adminManager, asyncHandler(tenantController.createUser))
router.put('/users/:id', adminManager, asyncHandler(tenantController.updateUser))
router.delete('/users/:id', adminManager, asyncHandler(tenantController.deleteUser))

export default router
