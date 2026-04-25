import { Router } from 'express';
import type { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../db';
import { requireAuth } from '../middleware/requireAuth';
import type { AuthRequest } from '../middleware/requireAuth';

export const historyRouter = Router();

historyRouter.use(requireAuth);

const addSchema = z.object({ text: z.string().min(1).max(500) });

// GET /api/history
historyRouter.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  const items = await prisma.history.findMany({
    where: { userId: req.userId! },
    orderBy: { createdAt: 'desc' },
    take: 100,
  });
  res.json(items);
});

// POST /api/history
historyRouter.post('/', async (req: AuthRequest, res: Response): Promise<void> => {
  const parsed = addSchema.safeParse(req.body);
  if (!parsed.success) {
    res.status(400).json({ error: 'Gecersiz veri.' });
    return;
  }

  const item = await prisma.history.create({
    data: { userId: req.userId!, text: parsed.data.text },
  });
  res.status(201).json(item);
});

// DELETE /api/history/:id
historyRouter.delete('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  const { id } = req.params as { id: string };

  const item = await prisma.history.findUnique({ where: { id } });
  if (!item || item.userId !== req.userId) {
    res.status(404).json({ error: 'Bulunamadi.' });
    return;
  }

  await prisma.history.delete({ where: { id } });
  res.status(204).end();
});
