import { Playlist, Track } from '@/types/music';
import { getSession } from '@/lib/session';
import { refreshSpotifyToken } from './auth';

const SPOTIFY_API_BASE = 'https://api.spotify.com/v1';

async function getValidToken(): Promise<string> {
  const session = await getSession();
  
  if (!session.spotify) {
    throw new Error('Not authenticated with Spotify');
  }
  
  // Check if token is expired or about to expire (5 min buffer)
  if (Date.now() >= session.spotify.expires_at - 300000) {
    const newTokens = await refreshSpotifyToken(session.spotify.refresh_token);
    session.spotify = {
      access_token: newTokens.access_token,
      refresh_token: newTokens.refresh_token,
      expires_at: newTokens.expires_at,
    };
    await session.save();
  }
  
  return session.spotify.access_token;
}

async function spotifyFetch(endpoint: string, options: RequestInit = {}) {
  const token = await getValidToken();
  
  const response = await fetch(`${SPOTIFY_API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Spotify API error: ${error.error?.message || response.statusText}`);
  }
  
  return response.json();
}

export async function getCurrentUser() {
  return spotifyFetch('/me');
}

export async function getUserPlaylists(limit = 50, offset = 0): Promise<Playlist[]> {
  const data = await spotifyFetch(`/me/playlists?limit=${limit}&offset=${offset}`);
  
  return data.items.map((playlist: any) => ({
    id: playlist.id,
    name: playlist.name,
    description: playlist.description || '',
    imageUrl: playlist.images?.[0]?.url,
    trackCount: playlist.tracks.total,
    owner: playlist.owner.display_name || playlist.owner.id,
    platform: 'spotify' as const,
  }));
}

export async function getPlaylistTracks(playlistId: string): Promise<Track[]> {
  const tracks: Track[] = [];
  let offset = 0;
  const limit = 100;
  
  while (true) {
    const data = await spotifyFetch(`/playlists/${playlistId}/tracks?limit=${limit}&offset=${offset}`);
    
    const pageTracks = data.items
      .filter((item: any) => item.track && !item.track.is_local)
      .map((item: any) => ({
        id: item.track.id,
        name: item.track.name,
        artist: item.track.artists.map((a: any) => a.name).join(', '),
        album: item.track.album.name,
        duration: item.track.duration_ms,
        isrc: item.track.external_ids?.isrc,
        platform: 'spotify' as const,
        uri: item.track.uri,
        imageUrl: item.track.album.images?.[0]?.url,
      }));
    
    tracks.push(...pageTracks);
    
    if (!data.next) break;
    offset += limit;
  }
  
  return tracks;
}

export async function searchTracks(query: string, limit = 10): Promise<Track[]> {
  const data = await spotifyFetch(`/search?q=${encodeURIComponent(query)}&type=track&limit=${limit}`);
  
  return data.tracks.items.map((track: any) => ({
    id: track.id,
    name: track.name,
    artist: track.artists.map((a: any) => a.name).join(', '),
    album: track.album.name,
    duration: track.duration_ms,
    isrc: track.external_ids?.isrc,
    platform: 'spotify' as const,
    uri: track.uri,
    imageUrl: track.album.images?.[0]?.url,
  }));
}

export async function createPlaylist(name: string, description?: string, isPublic = false): Promise<string> {
  const user = await getCurrentUser();
  
  const data = await spotifyFetch(`/users/${user.id}/playlists`, {
    method: 'POST',
    body: JSON.stringify({
      name,
      description,
      public: isPublic,
    }),
  });
  
  return data.id;
}

export async function addTracksToPlaylist(playlistId: string, trackUris: string[]): Promise<void> {
  // Spotify limits to 100 tracks per request
  const chunks = [];
  for (let i = 0; i < trackUris.length; i += 100) {
    chunks.push(trackUris.slice(i, i + 100));
  }
  
  for (const chunk of chunks) {
    await spotifyFetch(`/playlists/${playlistId}/tracks`, {
      method: 'POST',
      body: JSON.stringify({
        uris: chunk,
      }),
    });
  }
}