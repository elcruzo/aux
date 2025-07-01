import { env } from '@/lib/env';

const SPOTIFY_AUTH_URL = 'https://accounts.spotify.com/authorize';
const SPOTIFY_TOKEN_URL = 'https://accounts.spotify.com/api/token';

export interface SpotifyTokens {
  access_token: string;
  token_type: string;
  expires_in: number;
  refresh_token: string;
  scope: string;
  expires_at: number;
}

export const spotifyScopes = [
  'playlist-read-private',
  'playlist-read-collaborative',
  'playlist-modify-public',
  'playlist-modify-private',
  'user-library-read',
];

export function getSpotifyAuthUrl(state: string): string {
  const params = new URLSearchParams({
    client_id: env.data!.SPOTIFY_CLIENT_ID,
    response_type: 'code',
    redirect_uri: env.data!.SPOTIFY_REDIRECT_URI,
    scope: spotifyScopes.join(' '),
    state,
  });

  return `${SPOTIFY_AUTH_URL}?${params.toString()}`;
}

export async function exchangeCodeForToken(code: string): Promise<SpotifyTokens> {
  const params = new URLSearchParams({
    grant_type: 'authorization_code',
    code,
    redirect_uri: env.data!.SPOTIFY_REDIRECT_URI,
  });

  const response = await fetch(SPOTIFY_TOKEN_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${Buffer.from(`${env.data!.SPOTIFY_CLIENT_ID}:${env.data!.SPOTIFY_CLIENT_SECRET}`).toString('base64')}`,
    },
    body: params.toString(),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Spotify token exchange failed: ${error.error_description || error.error}`);
  }

  const data = await response.json();
  
  return {
    ...data,
    expires_at: Date.now() + (data.expires_in * 1000),
  };
}

export async function refreshSpotifyToken(refreshToken: string): Promise<SpotifyTokens> {
  const params = new URLSearchParams({
    grant_type: 'refresh_token',
    refresh_token: refreshToken,
  });

  const response = await fetch(SPOTIFY_TOKEN_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': `Basic ${Buffer.from(`${env.data!.SPOTIFY_CLIENT_ID}:${env.data!.SPOTIFY_CLIENT_SECRET}`).toString('base64')}`,
    },
    body: params.toString(),
  });

  if (!response.ok) {
    const error = await response.json();
    throw new Error(`Spotify token refresh failed: ${error.error_description || error.error}`);
  }

  const data = await response.json();
  
  return {
    ...data,
    refresh_token: refreshToken, // Spotify doesn't always return a new refresh token
    expires_at: Date.now() + (data.expires_in * 1000),
  };
}