import { Request, Response } from 'express'
import jwt from 'jsonwebtoken'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()
const JWT_SECRET = process.env.JWT_SECRET || 'fleetpro_super_secret_dev_key'

export const login = async (req: Request, res: Response) => {
  const { username, password } = req.body

  const user = await prisma.appUser.findFirst({
    where: { username },
    include: { tenant: true },
  })

  if (!user || user.password !== password) {
    return res.status(401).json({ error: 'بيانات الدخول غير صحيحة' })
  }

  if (!user.isActive) {
    return res.status(403).json({ error: 'الحساب معطل. تواصل مع الإدارة.' })
  }

  if (user.tenant && !user.tenant.isActive) {
    return res.status(403).json({ error: 'اشتراك الشركة متوقف.' })
  }

  const token = jwt.sign(
    {
      id: user.id,
      username: user.username,
      role: user.role,
      tenantId: user.tenantId,
    },
    JWT_SECRET,
    { expiresIn: '7d' }
  )

  res.json({
    message: 'تم تسجيل الدخول بنجاح',
    token,
    user: {
      id: user.id,
      username: user.username,
      role: user.role,
      displayName: user.displayName,
      tenantId: user.tenantId,
      companyName: user.tenant?.name,
      mustChangePassword: user.mustChangePassword,
    },
  })
}

export const changePassword = async (req: Request, res: Response) => {
  const { currentPassword, newPassword } = req.body
  const userId = req.user?.id

  if (!userId) {
    return res.status(401).json({ error: 'غير مصرح' })
  }

  const user = await prisma.appUser.findUnique({
    where: { id: userId }
  })

  if (!user || user.password !== currentPassword) {
    return res.status(400).json({ error: 'كلمة المرور الحالية غير صحيحة' })
  }

  await prisma.appUser.update({
    where: { id: userId },
    data: { 
      password: newPassword,
      mustChangePassword: false 
    }
  })

  res.json({ message: 'تم تغيير كلمة المرور بنجاح' })
}

export const checkTenant = async (req: Request, res: Response) => {
  const { serverId } = req.params

  if (!serverId) {
    return res.status(400).json({ error: 'معرف الشركة مطلوب' })
  }

  const tenant = await prisma.tenant.findUnique({
    where: { serverId }
  })

  if (!tenant) {
    return res.status(404).json({ error: 'الشركة غير موجودة' })
  }

  res.json({ name: tenant.name })
}
