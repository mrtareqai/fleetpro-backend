import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'

// نضيف الحقول المطلوبة على Request
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string
        username: string
        role: string
        tenantId: string | null
      }
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'fleetpro_super_secret_dev_key'

/**
 * Auth Middleware
 * يتحقق من وجود وصلاحية الـ JWT Token
 * ويستخرج tenantId من داخل الـ Token فقط (لا يثق بالعميل)
 */
export function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'التوثيق مطلوب. يرجى تسجيل الدخول.' })
  }

  const token = authHeader.split(' ')[1]

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as {
      id: string
      username: string
      role: string
      tenantId: string | null
    }

    // حقن بيانات المستخدم في الـ Request
    req.user = {
      id: decoded.id,
      username: decoded.username,
      role: decoded.role,
      tenantId: decoded.tenantId,
    }

    next()
  } catch (error) {
    return next(error) // سيتم التقاطه في errorHandler (JWT errors)
  }
}

/**
 * Middleware للتأكد من أن المستخدم ينتمي لشركة (ليس TopOwner بدون tenant)
 */
export function requireTenant(req: Request, res: Response, next: NextFunction) {
  if (!req.user?.tenantId) {
    return res.status(403).json({ error: 'هذا الإجراء يتطلب الانتماء لشركة.' })
  }
  next()
}

/**
 * Middleware للتأكد من أن المستخدم هو TopOwner
 */
export function requireTopOwner(req: Request, res: Response, next: NextFunction) {
  if (req.user?.role !== 'topowner') {
    return res.status(403).json({ error: 'هذا الإجراء يتطلب صلاحيات المسؤول الأعلى.' })
  }
  next()
}

/**
 * Middleware للتحقق من أن المستخدم يمتلك أحد الأدوار المحددة (RBAC)
 */
export function requireRole(roles: string[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'التوثيق مطلوب.' })
    }
    if (req.user.role === 'topowner') {
       return next() // TopOwner له الصلاحية دائماً على كل شيء (في حال تم استخدامه)
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'الصلاحيات غير كافية لإتمام هذا الإجراء.' })
    }
    next()
  }
}
