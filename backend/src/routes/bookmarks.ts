import { Router } from 'express';
import type { Response } from 'express';
import { prisma } from '../db';
import { requireAuth } from '../middleware/requireAuth';
import type { AuthRequest } from '../middleware/requireAuth';

export const bookmarksRouter = Router();

bookmarksRouter.use(requireAuth);

// GET /api/bookmarks — kullanicinin kaydettikleri
bookmarksRouter.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  const items = await prisma.bookmark.findMany({
    where: { userId: req.userId! },
    include: {
      word: {
        select: { id: true, word: true, letter: true, meaningEn: true, videoFilename: true, cdnVideoUrl: true },
      },
    },
    orderBy: { createdAt: 'desc' },
  });

  res.json(items.map(b => ({
    id: b.id,
    wordId: b.word.id,
    word: b.word.word,
    letter: b.word.letter,
    meaningEn: b.word.meaningEn,
    videoUrl: b.word.videoFilename
      ? `${process.env['BASE_URL']}/videos/${b.word.videoFilename}`
      : b.word.cdnVideoUrl,
    createdAt: b.createdAt,
  })));
});

// POST /api/bookmarks/:wordId — kaydet
bookmarksRouter.post('/:wordId', async (req: AuthRequest, res: Response): Promise<void> => {
  const wordId = parseInt(req.params['wordId'] ?? '', 10);
  if (isNaN(wordId)) { res.status(400).json({ error: 'Gecersiz wordId.' }); return; }

  const bookmark = await prisma.bookmark.upsert({
    where: { userId_wordId: { userId: req.userId!, wordId } },
    update: {},
    create: { userId: req.userId!, wordId },
  });

  res.status(201).json(bookmark);
});

// DELETE /api/bookmarks/:wordId — kaydi sil
bookmarksRouter.delete('/:wordId', async (req: AuthRequest, res: Response): Promise<void> => {
  const wordId = parseInt(req.params['wordId'] ?? '', 10);
  if (isNaN(wordId)) { res.status(400).json({ error: 'Gecersiz wordId.' }); return; }

  await prisma.bookmark.deleteMany({
    where: { userId: req.userId!, wordId },
  });

  res.status(204).end();
});
