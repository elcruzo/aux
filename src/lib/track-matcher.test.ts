import { trackMatcher } from './track-matcher';
import { Track } from '@/types/music';

describe('TrackMatcher', () => {
  const createTrack = (overrides: Partial<Track> = {}): Track => ({
    id: '123',
    name: 'Test Track',
    artist: 'Test Artist',
    album: 'Test Album',
    duration: 180000,
    platform: 'spotify',
    ...overrides,
  });

  describe('matchByISRC', () => {
    it('should match tracks with identical ISRC codes', () => {
      const sourceTrack = createTrack({ isrc: 'USRC17607839' });
      const candidates = [
        createTrack({ id: '456', isrc: 'USRC17607839', platform: 'apple' }),
        createTrack({ id: '789', isrc: 'USRC17607840', platform: 'apple' }),
      ];

      const result = trackMatcher.matchByISRC(sourceTrack, candidates);

      expect(result.confidence).toBe('high');
      expect(result.matchType).toBe('isrc');
      expect(result.targetTrack?.id).toBe('456');
    });

    it('should return no match when ISRC not found', () => {
      const sourceTrack = createTrack({ isrc: 'USRC17607839' });
      const candidates = [
        createTrack({ id: '456', isrc: 'USRC17607840', platform: 'apple' }),
      ];

      const result = trackMatcher.matchByISRC(sourceTrack, candidates);

      expect(result.confidence).toBe('none');
      expect(result.targetTrack).toBeUndefined();
    });
  });

  describe('matchByMetadata', () => {
    it('should give high confidence for exact matches', () => {
      const sourceTrack = createTrack({
        name: 'Bohemian Rhapsody',
        artist: 'Queen',
        album: 'A Night at the Opera',
        duration: 354000,
      });

      const candidates = [
        createTrack({
          id: '456',
          name: 'Bohemian Rhapsody',
          artist: 'Queen',
          album: 'A Night at the Opera',
          duration: 354500,
          platform: 'apple',
        }),
      ];

      const result = trackMatcher.matchByMetadata(sourceTrack, candidates);

      expect(result.confidence).toBe('high');
      expect(result.matchType).toBe('search');
      expect(result.targetTrack?.id).toBe('456');
    });

    it('should handle case-insensitive matching', () => {
      const sourceTrack = createTrack({
        name: 'hello',
        artist: 'adele',
      });

      const candidates = [
        createTrack({
          id: '456',
          name: 'Hello',
          artist: 'Adele',
          platform: 'apple',
        }),
      ];

      const result = trackMatcher.matchByMetadata(sourceTrack, candidates);

      expect(result.confidence).toBe('high');
    });

    it('should handle special characters', () => {
      const sourceTrack = createTrack({
        name: "Don't Stop Me Now",
        artist: 'Queen',
      });

      const candidates = [
        createTrack({
          id: '456',
          name: 'Dont Stop Me Now',
          artist: 'Queen',
          platform: 'apple',
        }),
      ];

      const result = trackMatcher.matchByMetadata(sourceTrack, candidates);

      expect(['high', 'medium']).toContain(result.confidence);
    });

    it('should give medium confidence for partial matches', () => {
      const sourceTrack = createTrack({
        name: 'Wonderwall',
        artist: 'Oasis',
        album: "What's the Story Morning Glory?",
      });

      const candidates = [
        createTrack({
          id: '456',
          name: 'Wonderwall',
          artist: 'Oasis',
          album: 'Morning Glory',
          platform: 'apple',
        }),
      ];

      const result = trackMatcher.matchByMetadata(sourceTrack, candidates);

      expect(result.confidence).toBe('medium');
    });
  });

  describe('matchTrack', () => {
    it('should prefer ISRC match over metadata match', async () => {
      const sourceTrack = createTrack({
        name: 'Different Name',
        artist: 'Different Artist',
        isrc: 'USRC17607839',
      });

      const candidates = [
        createTrack({
          id: '456',
          name: 'Different Name',
          artist: 'Different Artist',
          platform: 'apple',
        }),
        createTrack({
          id: '789',
          name: 'Totally Different',
          artist: 'Someone Else',
          isrc: 'USRC17607839',
          platform: 'apple',
        }),
      ];

      const result = await trackMatcher.matchTrack(sourceTrack, candidates);

      expect(result.targetTrack?.id).toBe('789');
      expect(result.matchType).toBe('isrc');
    });
  });
});