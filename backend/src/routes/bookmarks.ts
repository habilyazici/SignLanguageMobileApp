import { Router } from 'express';
import type { Response } from 'express';
import { prisma } from '../db';
import { videoUrl } from '../utils/videoUrl';
import { requireAuth } from '../middleware/requireAuth';
import type { AuthRequest } from '../middleware/requireAuth';

export const bookmarksRouter = Router();

bookmarksRouter.use(requireAuth);

// GET /api/bookmarks
bookmarksRouter.get('/', async (req: AuthRequest, res: Response): Promise<void> => {
  try {
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
      videoUrl: videoUrl(b.word),
      createdAt: b.createdAt,
    })));
  } catch (err) {
    console.error('[bookmarks]:', err);
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// POST /api/bookmarks/:wordId
bookmarksRouter.post('/:wordId', async (req: AuthRequest, res: Response): Promise<void> => {
  const wordId = parseInt(String(req.params['wordId'] ?? ''), 10);
  if (isNaN(wordId)) { res.status(400).json({ error: 'Gecersiz wordId.' }); return; }

  try {
    const bookmark = await prisma.bookmark.upsert({
      where: { userId_wordId: { userId: req.userId!, wordId } },
      update: {},
      create: { userId: req.userId!, wordId },
    });
    res.status(201).json(bookmark);
  } catch (err) {
    console.error('[bookmarks]:', err);
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// DELETE /api/bookmarks/:wordId
bookmarksRouter.delete('/:wordId', async (req: AuthRequest, res: Response): Promise<void> => {
  const wordId = parseInt(String(req.params['wordId'] ?? ''), 10);
  if (isNaN(wordId)) { res.status(400).json({ error: 'Gecersiz wordId.' }); return; }

  try {
    await prisma.bookmark.deleteMany({ where: { userId: req.userId!, wordId } });
    res.status(204).end();
  } catch (err) {
    console.error('[bookmarks]:', err);
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});
