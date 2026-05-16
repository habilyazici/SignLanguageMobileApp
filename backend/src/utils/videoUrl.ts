import { config } from '../config';

/**
 * Kelime kaydından video URL'i üretir.
 * Lokal dosya varsa statik sunucudan servis eder, yoksa CDN'e düşer.
 */
export function videoUrl(word: { videoFilename: string | null; cdnVideoUrl: string }): string {
  if (word.videoFilename) {
    return `${config.baseUrl}/videos/${encodeURIComponent(word.videoFilename)}`;
  }
  return word.cdnVideoUrl;
}
