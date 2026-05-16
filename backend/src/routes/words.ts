import { Router } from 'express';
import type { Request, Response } from 'express';
import { prisma } from '../db';
import type { Prisma } from '../../generated/prisma/client';
import { videoUrl } from '../utils/videoUrl';

export const wordsRouter = Router();

interface ManifestCache {
  data: Record<string, string>;
  builtAt: number;
}
let manifestCache: ManifestCache | null = null;
const MANIFEST_TTL_MS = 5 * 60 * 1000; // 5 dakika

function asString(val: unknown): string | undefined {
  if (typeof val === 'string') return val;
  if (Array.isArray(val)) return val[0] as string | undefined;
  return undefined;
}

function trLower(s: string): string {
  return s
    .replace(/İ/g, 'i').replace(/I/g, 'ı')
    .replace(/Ğ/g, 'ğ').replace(/Ü/g, 'ü')
    .replace(/Ş/g, 'ş').replace(/Ö/g, 'ö')
    .replace(/Ç/g, 'ç').toLowerCase();
}

function manifestKeys(word: string): string[] {
  const stripped = word.replace(/\s*\(.*?\)/g, '').trim();
  return stripped
    .split(',')
    .map(p => trLower(p.trim()))
    .filter(p => p.length > 0 && !p.includes(' '));
}

// GET /api/words/manifest
wordsRouter.get('/manifest', async (_req: Request, res: Response): Promise<void> => {
  if (manifestCache && Date.now() - manifestCache.builtAt < MANIFEST_TTL_MS) {
    res.json({ words: manifestCache.data });
    return;
  }

  try {
    const all = await prisma.word.findMany({
      select: { word: true, videoFilename: true, cdnVideoUrl: true },
    });

    const manifest: Record<string, string> = {};
    for (const w of all) {
      const url = videoUrl(w);
      for (const key of manifestKeys(w.word)) manifest[key] = url;
    }

    manifestCache = { data: manifest, builtAt: Date.now() };
    res.json({ words: manifest });
  } catch (err) {
    console.error('[words]:', err);
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// GET /api/words?letter=A&q=ara&page=1&limit=50
wordsRouter.get('/', async (req: Request, res: Response): Promise<void> => {
  const letter = asString(req.query['letter']);
  const q = asString(req.query['q']);
  const page = Math.max(1, parseInt(asString(req.query['page']) ?? '1', 10));
  const limit = Math.min(200, Math.max(1, parseInt(asString(req.query['limit']) ?? '50', 10)));
  const skip = (page - 1) * limit;

  const where: Prisma.WordWhereInput = {};
  if (letter) where.letter = letter.toUpperCase();
  if (q) where.word = { contains: q, mode: 'insensitive' };

  try {
    const [words, total] = await Promise.all([
      prisma.word.findMany({
        where,
        select: {
          id: true, wordId: true, word: true, letter: true,
          meaningEn: true, videoFilename: true, cdnVideoUrl: true,
        },
        orderBy: { word: 'asc' },
        skip,
        take: limit,
      }),
      prisma.word.count({ where }),
    ]);

    res.json({
      data: words.map(w => ({
        id: w.id,
        wordId: w.wordId,
        word: w.word,
        letter: w.letter,
        meaningEn: w.meaningEn,
        videoUrl: videoUrl(w),
      })),
      total,
      page,
      limit,
      pages: Math.ceil(total / limit),
    });
  } catch (err) {
    console.error('[words]:', err);
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});

// GET /api/words/:id
wordsRouter.get('/:id', async (req: Request, res: Response): Promise<void> => {
  const id = parseInt(String(req.params['id'] ?? ''), 10);
  if (isNaN(id)) { res.status(400).json({ error: 'Gecersiz ID.' }); return; }

  try {
    const word = await prisma.word.findUnique({ where: { id } });
    if (!word) { res.status(404).json({ error: 'Kelime bulunamadi.' }); return; }

    res.json({
      id: word.id,
      wordId: word.wordId,
      word: word.word,
      letter: word.letter,
      meaningEn: word.meaningEn,
      allVideos: word.allVideos,
      detailUrl: word.detailUrl,
      videoUrl: videoUrl(word),
    });
  } catch (err) {
    console.error('[words]:', err);
    res.status(500).json({ error: 'Sunucu hatasi.' });
  }
});
