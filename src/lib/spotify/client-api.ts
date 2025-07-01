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

export async function getCurrentUser() {
  return fetchAPI('/spotify/me');
}

export async function getUserPlaylists(): Promise<Playlist[]> {
  return fetchAPI('/spotify/playlists');
}

export async function getPlaylistTracks(playlistId: string): Promise<Track[]> {
  return fetchAPI(`/spotify/playlists/${playlistId}/tracks`);
}

export async function createPlaylist(name: string, description?: string): Promise<string> {
  const data = await fetchAPI('/spotify/playlists', {
    method: 'POST',
    body: JSON.stringify({ name, description }),
  });
  return data.id;
}

export async function addTracksToPlaylist(playlistId: string, trackUris: string[]): Promise<void> {
  await fetchAPI(`/spotify/playlists/${playlistId}/tracks`, {
    method: 'POST',
    body: JSON.stringify({ uris: trackUris }),
  });
}

export async function searchTracks(query: string, limit = 10): Promise<Track[]> {
  return fetchAPI(`/spotify/search?q=${encodeURIComponent(query)}&limit=${limit}`);
}