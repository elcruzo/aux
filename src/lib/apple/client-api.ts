import { Playlist, Track } from '@/types/music';

const API_BASE = '/api';

async function fetchAPI(endpoint: string, options: RequestInit = {}) {
  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'API request failed');
  }
  
  return response.json();
}

export async function getUserPlaylists(): Promise<Playlist[]> {
  return fetchAPI('/apple/playlists');
}

export async function getPlaylistTracks(playlistId: string): Promise<Track[]> {
  return fetchAPI(`/apple/playlists/${playlistId}/tracks`);
}

export async function searchTracks(query: string, storefront = 'us'): Promise<Track[]> {
  return fetchAPI(`/apple/search?q=${encodeURIComponent(query)}&storefront=${storefront}`);
}

export async function searchTracksByISRC(isrc: string, storefront = 'us'): Promise<Track[]> {
  return fetchAPI(`/apple/search/isrc?isrc=${isrc}&storefront=${storefront}`);
}

export async function createPlaylist(name: string, description?: string): Promise<string> {
  const data = await fetchAPI('/apple/playlists', {
    method: 'POST',
    body: JSON.stringify({ name, description }),
  });
  return data.id;
}

export async function addTracksToPlaylist(playlistId: string, trackIds: string[]): Promise<void> {
  await fetchAPI(`/apple/playlists/${playlistId}/tracks`, {
    method: 'POST',
    body: JSON.stringify({ trackIds }),
  });
}