import { Router } from 'express';
import type { Request, Response } from 'express';
import { z } from 'zod';
import { prisma } from '../db';
import { requireAuth } from '../middleware/requireAuth';
import type { AuthRequest } from '../middleware/requireAuth';

export const historyRouter = Router();

historyRouter.use(requireAuth);

const addSchema = z.object({ text: z.string().min(1).max(500) });

// GET /api/history?offset=0&limit=50
historyRouter.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  const limit = Math.min(parseInt(String(req.query['limit'] ?? '50'), 10) || 50, 100);
  const offset = Math.max(parseInt(String(req.query['offset'] ?? '0'), 10) || 0, 0);
  try {
    const items = await prisma.history.findMany({
      where: { userId: req.userId! },
      orderBy: { createdAt: 'desc' },
      take: limit,
      skip: offset,
    });
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// POST /api/history
historyRouter.post('/', async (req: AuthRequest, res: Response): Promise<void> => {
  const parsed = addSchema.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: 'Gecersiz veri.' }); return; }

  try {
    const item = await prisma.history.create({
      data: { userId: req.userId!, text: parsed.data.text },
    });
    res.status(201).json(item);
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// DELETE /api/history (all)
historyRouter.delete('/', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    await prisma.history.deleteMany({ where: { userId: req.userId! } });
    res.status(204).end();
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// DELETE /api/history/:id
historyRouter.delete('/:id', async (req: AuthRequest, res: Response): Promise<void> => {
  const id = String(req.params['id'] ?? '');

  try {
    const { count } = await prisma.history.deleteMany({
      where: { id, userId: req.userId! },
    });
    if (count === 0) {
      res.status(404).json({ error: 'Bulunamadi.' });
      return;
    }
    res.status(204).end();
  } catch (err) {
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});
