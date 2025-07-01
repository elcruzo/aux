import { Playlist, Track } from '@/types/music';
import { getSession } from '@/lib/session';
import { generateAppleDeveloperToken } from './auth';

const APPLE_API_BASE = 'https://api.music.apple.com/v1';

interface AppleApiOptions {
  developerToken: string;
  musicUserToken?: string;
}

let cachedDeveloperToken: { token: string; expiresAt: number } | null = null;

async function getDeveloperToken(): Promise<string> {
  if (cachedDeveloperToken && Date.now() < cachedDeveloperToken.expiresAt - 300000) {
    return cachedDeveloperToken.token;
  }
  
  const tokenData = generateAppleDeveloperToken();
  cachedDeveloperToken = {
    token: tokenData.developerToken,
    expiresAt: tokenData.expiresAt,
  };
  
  return tokenData.developerToken;
}

async function getApiTokens(): Promise<AppleApiOptions> {
  const developerToken = await getDeveloperToken();
  const session = await getSession();
  
  return {
    developerToken,
    musicUserToken: session.apple?.music_user_token,
  };
}

async function appleFetch(endpoint: string, options: RequestInit = {}, requiresUserToken = false) {
  const tokens = await getApiTokens();
  
  if (requiresUserToken && !tokens.musicUserToken) {
    throw new Error('Not authenticated with Apple Music');
  }
  
  const headers: Record<string, string> = {
    'Authorization': `Bearer ${tokens.developerToken}`,
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string> || {}),
  };
  
  if (tokens.musicUserToken) {
    headers['Music-User-Token'] = tokens.musicUserToken;
  }
  
  const response = await fetch(`${APPLE_API_BASE}${endpoint}`, {
    ...options,
    headers,
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Apple Music API error: ${error.errors?.[0]?.detail || response.statusText}`);
  }
  
  return response.json();
}

export async function getUserPlaylists(limit = 50, offset = 0): Promise<Playlist[]> {
  const data = await appleFetch(`/me/library/playlists?limit=${limit}&offset=${offset}`, {}, true);
  
  return data.data.map((playlist: any) => ({
    id: playlist.id,
    name: playlist.attributes.name,
    description: playlist.attributes.description?.standard || '',
    imageUrl: playlist.attributes.artwork?.url?.replace('{w}', '300').replace('{h}', '300'),
    trackCount: playlist.attributes.trackCount || 0,
    owner: 'me',
    platform: 'apple' as const,
  }));
}

export async function getPlaylistTracks(playlistId: string): Promise<Track[]> {
  const tracks: Track[] = [];
  let next = `/me/library/playlists/${playlistId}/tracks?limit=100`;
  
  while (next) {
    const data = await appleFetch(next, {}, true);
    
    const pageTracks = data.data.map((track: any) => ({
      id: track.id,
      name: track.attributes.name,
      artist: track.attributes.artistName,
      album: track.attributes.albumName,
      duration: track.attributes.durationInMillis,
      isrc: track.attributes.isrc,
      platform: 'apple' as const,
      uri: track.id,
      imageUrl: track.attributes.artwork?.url?.replace('{w}', '300').replace('{h}', '300'),
    }));
    
    tracks.push(...pageTracks);
    next = data.next;
  }
  
  return tracks;
}

export async function searchTracks(query: string, storefront = 'us', limit = 10): Promise<Track[]> {
  const data = await appleFetch(`/catalog/${storefront}/search?term=${encodeURIComponent(query)}&types=songs&limit=${limit}`);
  
  if (!data.results?.songs?.data) {
    return [];
  }
  
  return data.results.songs.data.map((track: any) => ({
    id: track.id,
    name: track.attributes.name,
    artist: track.attributes.artistName,
    album: track.attributes.albumName,
    duration: track.attributes.durationInMillis,
    isrc: track.attributes.isrc,
    platform: 'apple' as const,
    uri: track.id,
    imageUrl: track.attributes.artwork?.url?.replace('{w}', '300').replace('{h}', '300'),
  }));
}

export async function searchTracksByISRC(isrc: string, storefront = 'us'): Promise<Track[]> {
  const data = await appleFetch(`/catalog/${storefront}/songs?filter[isrc]=${isrc}`);
  
  if (!data.data || data.data.length === 0) {
    return [];
  }
  
  return data.data.map((track: any) => ({
    id: track.id,
    name: track.attributes.name,
    artist: track.attributes.artistName,
    album: track.attributes.albumName,
    duration: track.attributes.durationInMillis,
    isrc: track.attributes.isrc,
    platform: 'apple' as const,
    uri: track.id,
    imageUrl: track.attributes.artwork?.url?.replace('{w}', '300').replace('{h}', '300'),
  }));
}

export async function createPlaylist(name: string, description?: string): Promise<string> {
  const data = await appleFetch('/me/library/playlists', {
    method: 'POST',
    body: JSON.stringify({
      attributes: {
        name,
        description: description ? { standard: description } : undefined,
      },
    }),
  }, true);
  
  return data.data[0].id;
}

export async function addTracksToPlaylist(playlistId: string, trackIds: string[]): Promise<void> {
  // Apple Music also has limits on tracks per request
  const chunks = [];
  for (let i = 0; i < trackIds.length; i += 100) {
    chunks.push(trackIds.slice(i, i + 100));
  }
  
  for (const chunk of chunks) {
    await appleFetch(`/me/library/playlists/${playlistId}/tracks`, {
      method: 'POST',
      body: JSON.stringify({
        data: chunk.map(id => ({ id, type: 'songs' })),
      }),
    }, true);
  }
}