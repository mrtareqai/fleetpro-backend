import { Router } from 'express'
import rateLimit from 'express-rate-limit'
import { asyncHandler } from '../middlewares/errorHandler'
import { validate } from '../middlewares/validateMiddleware'
import { loginSchema } from '../validators/authValidators'
import { authMiddleware } from '../middlewares/authMiddleware'
import * as authController from '../controllers/auth.controller'

const router = Router()

// Rate limiting for login to prevent brute force
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // limit each IP to 10 login requests per windowMs
  message: { error: 'تم تجاوز الحد المسموح لمحاولات تسجيل الدخول. يرجى المحاولة بعد 15 دقيقة.' }
})

router.post('/login', loginLimiter, validate(loginSchema), asyncHandler(authController.login))
router.post('/change-password', authMiddleware, asyncHandler(authController.changePassword))
router.get('/tenant/:serverId', asyncHandler(authController.checkTenant))

export default router
