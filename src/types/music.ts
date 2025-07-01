export interface Track {
  id: string;
  name: string;
  artist: string;
  album: string;
  duration: number; // in milliseconds
  isrc?: string;
  platform: 'spotify' | 'apple';
  uri?: string; // Platform-specific URI
  imageUrl?: string;
}

export interface Playlist {
  id: string;
  name: string;
  description?: string;
  imageUrl?: string;
  trackCount: number;
  owner: string;
  platform: 'spotify' | 'apple';
}

export interface TrackMatch {
  sourceTrack: Track;
  targetTrack?: Track;
  confidence: 'high' | 'medium' | 'low' | 'none';
  matchType?: 'isrc' | 'search' | 'manual';
}

export interface ConversionResult {
  playlistId: string;
  playlistName: string;
  totalTracks: number;
  successfulMatches: number;
  failedMatches: number;
  matches: TrackMatch[];
}