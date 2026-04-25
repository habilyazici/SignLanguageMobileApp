import './config';
import express from 'express';
import type { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import path from 'path';
import { config } from './config';
import { authRouter } from './routes/auth';
import { wordsRouter } from './routes/words';
import { historyRouter } from './routes/history';
import { bookmarksRouter } from './routes/bookmarks';

const app = express();

app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));
app.use(cors());
app.use(express.json());

app.use('/videos', express.static(path.join(process.cwd(), 'public', 'videos')));

app.use('/api/auth', authRouter);
app.use('/api/words', wordsRouter);
app.use('/api/history', historyRouter);
app.use('/api/bookmarks', bookmarksRouter);

app.get('/health', (_req, res) => res.json({ ok: true }));

// Global error handler
app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
  console.error(err);
  res.status(500).json({ error: 'Sunucu hatasi.' });
});

app.listen(config.port, () => {
  console.log(`Server: http://localhost:${config.port}`);
});
