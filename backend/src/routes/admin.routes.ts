import { Router } from 'express'
import { asyncHandler } from '../middlewares/errorHandler'
import { authMiddleware, requireTopOwner } from '../middlewares/authMiddleware'
import * as adminController from '../controllers/admin.controller'

const router = Router()

// جميع مسارات هذا الـ Router تتطلب توثيق وأن يكون المستخدم TopOwner
router.use(authMiddleware, requireTopOwner)

router.get('/tenants', asyncHandler(adminController.getTenants))

export default router
