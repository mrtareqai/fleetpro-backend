import { Request, Response, NextFunction } from 'express'
import { ZodSchema } from 'zod'

/**
 * Middleware للتحقق من المدخلات باستخدام Zod Schema
 * يمكن تحديد أي جزء من الطلب يتم التحقق منه (body, query, params)
 */
export function validate(schema: ZodSchema, source: 'body' | 'query' | 'params' = 'body') {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req[source])
    if (!result.success) {
      return next(result.error) // سيتم التقاطه في errorHandler
    }
    // استبدال البيانات الأصلية بالبيانات المحولة (parsed)
    ;(req as any)[source] = result.data
    next()
  }
}
