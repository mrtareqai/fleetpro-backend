import { Request, Response, NextFunction } from 'express'
import { ZodError } from 'zod'

/**
 * Global Error Handler Middleware
 * يجب أن يكون آخر middleware في سلسلة Express
 */
export function errorHandler(err: any, req: Request, res: Response, next: NextFunction) {
  console.error('🔥 Error:', err)

  // Zod Validation Error
  if (err instanceof ZodError || (err && err.issues && err.name === 'ZodError')) {
    return res.status(400).json({
      error: 'Validation Error',
      details: (err.issues || err.errors || []).map((e: any) => ({
        field: e.path?.join('.') || 'unknown',
        message: e.message,
      })),
    })
  }

  // JWT Error
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ error: 'رمز التوثيق غير صالح' })
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ error: 'انتهت صلاحية رمز التوثيق' })
  }

  // Prisma Error
  if (err.code && err.code.startsWith('P')) {
    return res.status(400).json({
      error: 'Database Error',
      details: err.message,
    })
  }

  // Default Error
  const statusCode = err.statusCode || 500
  res.status(statusCode).json({
    error: err.message || 'Internal Server Error',
  })
}

/**
 * Async Handler لتغليف الدوال بدل تكرار try/catch
 */
export function asyncHandler(fn: (req: Request, res: Response, next: NextFunction) => Promise<any>) {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}
