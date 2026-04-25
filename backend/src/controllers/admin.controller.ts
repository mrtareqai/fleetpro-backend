import { Request, Response } from 'express'
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export const getTenants = async (req: Request, res: Response) => {
  const tenants = await prisma.tenant.findMany({
    include: {
      _count: {
        select: { users: true, vehicles: true, trips: true },
      },
    },
  })
  res.json(tenants)
}
