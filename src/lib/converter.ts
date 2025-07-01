import { Track, TrackMatch, ConversionResult } from '@/types/music';
import { trackMatcher } from './track-matcher';
import * as spotifyApi from './spotify/api';
import * as appleApi from './apple/api';

export type ConversionDirection = 'spotify-to-apple' | 'apple-to-spotify';

export interface ConversionProgress {
  stage: 'fetching' | 'matching' | 'creating' | 'adding' | 'complete';
  current: number;
  total: number;
  message: string;
}

export class PlaylistConverter {
  private onProgress?: (progress: ConversionProgress) => void;

  constructor(onProgress?: (progress: ConversionProgress) => void) {
    this.onProgress = onProgress;
  }

  private updateProgress(progress: ConversionProgress) {
    if (this.onProgress) {
      this.onProgress(progress);
    }
  }

  async convertPlaylist(
    playlistId: string,
    playlistName: string,
    direction: ConversionDirection
  ): Promise<ConversionResult> {
    try {
      // Fetch source tracks
      this.updateProgress({
        stage: 'fetching',
        current: 0,
        total: 1,
        message: 'Fetching playlist tracks...',
      });

      const sourceTracks = direction === 'spotify-to-apple'
        ? await spotifyApi.getPlaylistTracks(playlistId)
        : await appleApi.getPlaylistTracks(playlistId);

      const totalTracks = sourceTracks.length;

      // Match tracks
      this.updateProgress({
        stage: 'matching',
        current: 0,
        total: totalTracks,
        message: 'Matching tracks...',
      });

      const matches: TrackMatch[] = [];
      
      for (let i = 0; i < sourceTracks.length; i++) {
        const sourceTrack = sourceTracks[i];
        let targetTracks: Track[] = [];

        // Try ISRC first if available
        if (sourceTrack.isrc) {
          if (direction === 'spotify-to-apple') {
            targetTracks = await appleApi.searchTracksByISRC(sourceTrack.isrc);
          } else {
            // For Apple to Spotify, we need to search by metadata since Spotify doesn't have ISRC search
            const query = `track:"${sourceTrack.name}" artist:"${sourceTrack.artist}"`;
            targetTracks = await spotifyApi.searchTracks(query, 5);
          }
        }

        // If no ISRC match, search by metadata
        if (targetTracks.length === 0) {
          const query = `${sourceTrack.name} ${sourceTrack.artist}`;
          if (direction === 'spotify-to-apple') {
            targetTracks = await appleApi.searchTracks(query, 'us', 5);
          } else {
            targetTracks = await spotifyApi.searchTracks(query, 5);
          }
        }

        const match = await trackMatcher.matchTrack(sourceTrack, targetTracks);
        matches.push(match);

        this.updateProgress({
          stage: 'matching',
          current: i + 1,
          total: totalTracks,
          message: `Matched ${i + 1} of ${totalTracks} tracks...`,
        });
      }

      // Create playlist
      this.updateProgress({
        stage: 'creating',
        current: 0,
        total: 1,
        message: 'Creating playlist...',
      });

      const description = `Converted from ${direction === 'spotify-to-apple' ? 'Spotify' : 'Apple Music'} using Aux`;
      
      const newPlaylistId = direction === 'spotify-to-apple'
        ? await appleApi.createPlaylist(playlistName, description)
        : await spotifyApi.createPlaylist(playlistName, description);

      // Add matched tracks
      const successfulMatches = matches.filter(m => m.targetTrack && m.confidence !== 'none');
      const trackIds = successfulMatches.map(m => m.targetTrack!.uri!);

      if (trackIds.length > 0) {
        this.updateProgress({
          stage: 'adding',
          current: 0,
          total: trackIds.length,
          message: 'Adding tracks to playlist...',
        });

        if (direction === 'spotify-to-apple') {
          await appleApi.addTracksToPlaylist(newPlaylistId, trackIds);
        } else {
          // For Spotify, we need the full URIs
          const uris = successfulMatches.map(m => m.targetTrack!.uri!);
          await spotifyApi.addTracksToPlaylist(newPlaylistId, uris);
        }
      }

      this.updateProgress({
        stage: 'complete',
        current: totalTracks,
        total: totalTracks,
        message: 'Conversion complete!',
      });

      return {
        playlistId: newPlaylistId,
        playlistName,
        totalTracks,
        successfulMatches: successfulMatches.length,
        failedMatches: totalTracks - successfulMatches.length,
        matches,
      };
    } catch (error) {
      console.error('Conversion error:', error);
      throw error;
    }
  }
}