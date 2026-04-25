import dotenv from 'dotenv'
import path from 'path'

// 1. تحميل .env الأساسي (إذا وجد) دون الكتابة فوق المتغيرات الموجودة فعلياً في النظام
dotenv.config({ path: path.resolve(__dirname, '../.env') })
// 2. تحميل ملف البيئة المخصص (dev أو production)
const envFile = process.env.NODE_ENV === 'production' ? '.env.production' : '.env.dev'
dotenv.config({ path: path.resolve(__dirname, `../${envFile}`) })

import express, { Request, Response } from 'express'
import cors from 'cors'
import { errorHandler } from './middlewares/errorHandler'

// استيراد مسارات التطبيق
import authRoutes from './routes/auth.routes'
import tenantRoutes from './routes/tenant.routes'
import adminRoutes from './routes/admin.routes'

const app = express()
const CORS_ORIGIN = process.env.CORS_ORIGIN || '*'

// ═══════════════════════════════════════════════
//  GLOBAL MIDDLEWARES
// ═══════════════════════════════════════════════

app.use(cors({
  origin: CORS_ORIGIN === '*' ? true : CORS_ORIGIN.split(','),
  credentials: true,
}))
app.use(express.json())

// ═══════════════════════════════════════════════
//  PUBLIC ROUTES (لا تحتاج توثيق)
// ═══════════════════════════════════════════════

app.get('/', (req: Request, res: Response) => {
  res.json({
    message: 'FleetPro API is running',
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0',
  })
})

// ═══════════════════════════════════════════════
//  API ROUTES
// ═══════════════════════════════════════════════

app.use('/api/auth', authRoutes)
app.use('/api', tenantRoutes)
app.use('/api/admin', adminRoutes)

// ═══════════════════════════════════════════════
//  GLOBAL ERROR HANDLER (يجب أن يكون الأخير)
// ═══════════════════════════════════════════════

app.use(errorHandler)

// ═══════════════════════════════════════════════
//  START SERVER
// ═══════════════════════════════════════════════

const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`🚀 FleetPro API running on http://localhost:${PORT}`)
  console.log(`📦 Environment: ${process.env.NODE_ENV || 'development'}`)
  console.log(`🔐 CORS Origin: ${CORS_ORIGIN}`)
})