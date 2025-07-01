import { Track, TrackMatch } from '@/types/music';

export class TrackMatcher {
  private normalizeString(str: string): string {
    return str
      .toLowerCase()
      .replace(/[^\w\s]/g, '') // Remove special characters
      .replace(/\s+/g, ' ') // Normalize whitespace
      .trim();
  }

  private calculateSimilarity(str1: string, str2: string): number {
    const normalized1 = this.normalizeString(str1);
    const normalized2 = this.normalizeString(str2);
    
    if (normalized1 === normalized2) return 1;
    
    const longer = normalized1.length > normalized2.length ? normalized1 : normalized2;
    const shorter = normalized1.length > normalized2.length ? normalized2 : normalized1;
    
    if (longer.length === 0) return 1;
    
    const editDistance = this.levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  private levenshteinDistance(str1: string, str2: string): number {
    const matrix: number[][] = [];
    
    for (let i = 0; i <= str2.length; i++) {
      matrix[i] = [i];
    }
    
    for (let j = 0; j <= str1.length; j++) {
      matrix[0][j] = j;
    }
    
    for (let i = 1; i <= str2.length; i++) {
      for (let j = 1; j <= str1.length; j++) {
        if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1, // substitution
            matrix[i][j - 1] + 1, // insertion
            matrix[i - 1][j] + 1 // deletion
          );
        }
      }
    }
    
    return matrix[str2.length][str1.length];
  }

  private isDurationMatch(duration1: number, duration2: number, toleranceMs: number = 3000): boolean {
    return Math.abs(duration1 - duration2) <= toleranceMs;
  }

  matchByISRC(sourceTrack: Track, candidates: Track[]): TrackMatch {
    if (!sourceTrack.isrc) {
      return {
        sourceTrack,
        confidence: 'none',
      };
    }

    const match = candidates.find(track => track.isrc === sourceTrack.isrc);
    
    if (match) {
      return {
        sourceTrack,
        targetTrack: match,
        confidence: 'high',
        matchType: 'isrc',
      };
    }

    return {
      sourceTrack,
      confidence: 'none',
    };
  }

  matchByMetadata(sourceTrack: Track, candidates: Track[]): TrackMatch {
    if (candidates.length === 0) {
      return {
        sourceTrack,
        confidence: 'none',
      };
    }

    const scoredCandidates = candidates.map(candidate => {
      const titleScore = this.calculateSimilarity(sourceTrack.name, candidate.name);
      const artistScore = this.calculateSimilarity(sourceTrack.artist, candidate.artist);
      const albumScore = this.calculateSimilarity(sourceTrack.album, candidate.album);
      const durationMatch = this.isDurationMatch(sourceTrack.duration, candidate.duration);
      
      // Weighted scoring
      const score = (titleScore * 0.4) + 
                   (artistScore * 0.3) + 
                   (albumScore * 0.2) + 
                   (durationMatch ? 0.1 : 0);
      
      return {
        track: candidate,
        score,
        titleScore,
        artistScore,
        durationMatch,
      };
    });

    // Sort by score descending
    scoredCandidates.sort((a, b) => b.score - a.score);
    const bestMatch = scoredCandidates[0];

    if (bestMatch.score >= 0.9 && bestMatch.durationMatch) {
      return {
        sourceTrack,
        targetTrack: bestMatch.track,
        confidence: 'high',
        matchType: 'search',
      };
    } else if (bestMatch.score >= 0.7) {
      return {
        sourceTrack,
        targetTrack: bestMatch.track,
        confidence: 'medium',
        matchType: 'search',
      };
    } else if (bestMatch.score >= 0.5 && bestMatch.titleScore >= 0.7 && bestMatch.artistScore >= 0.7) {
      return {
        sourceTrack,
        targetTrack: bestMatch.track,
        confidence: 'low',
        matchType: 'search',
      };
    }

    return {
      sourceTrack,
      confidence: 'none',
    };
  }

  async matchTrack(sourceTrack: Track, candidates: Track[]): Promise<TrackMatch> {
    // First try ISRC matching
    if (sourceTrack.isrc) {
      const isrcMatch = this.matchByISRC(sourceTrack, candidates);
      if (isrcMatch.confidence !== 'none') {
        return isrcMatch;
      }
    }

    // Fall back to metadata matching
    return this.matchByMetadata(sourceTrack, candidates);
  }
}

export const trackMatcher = new TrackMatcher();