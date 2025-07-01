import { ConversionDirection, ConversionProgress } from '@/lib/converter';
import { ConversionResult } from '@/types/music';

export async function convertPlaylist(
  playlistId: string,
  playlistName: string,
  direction: ConversionDirection,
  onProgress?: (progress: ConversionProgress) => void
): Promise<ConversionResult> {
  const response = await fetch('/api/convert', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      playlistId,
      playlistName,
      direction,
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Conversion failed');
  }

  return response.json();
}