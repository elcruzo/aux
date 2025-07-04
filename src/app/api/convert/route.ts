import { NextRequest, NextResponse } from 'next/server';
import { getSession } from '@/lib/session';
import { PlaylistConverter } from '@/lib/converter';
import { refreshSpotifyToken } from '@/lib/spotify/auth';

interface ConversionRequest {
  playlistId: string;
  playlistName: string;
  direction: 'spotify-to-apple' | 'apple-to-spotify';
}

export async function POST(req: NextRequest) {
  try {
    const session = await getSession();
    
    // Check authentication based on direction
    const { playlistId, playlistName, direction } = await req.json() as ConversionRequest;

    if (!playlistId || !playlistName || !direction) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      );
    }

    // Verify user has required authentication
    if (direction === 'spotify-to-apple') {
      if (!session?.apple?.music_user_token) {
        return NextResponse.json(
          { error: 'Please authenticate with Apple Music first' },
          { status: 401 }
        );
      }
    } else {
      if (!session?.spotify?.access_token) {
        return NextResponse.json(
          { error: 'Please authenticate with Spotify first' },
          { status: 401 }
        );
      }
      // Refresh Spotify token if needed
      if (session.spotify?.refresh_token) {
        const newTokens = await refreshSpotifyToken(session.spotify.refresh_token);
        session.spotify = newTokens;
        await session.save();
      }
    }

    // Perform the actual conversion
    const converter = new PlaylistConverter();
    const result = await converter.convertPlaylist(
      playlistId,
      playlistName,
      direction
    );

    // Add the target playlist URL
    const targetPlaylistUrl = direction === 'spotify-to-apple'
      ? `https://music.apple.com/library/playlist/${result.playlistId}`
      : `https://open.spotify.com/playlist/${result.playlistId}`;

    return NextResponse.json({
      ...result,
      targetPlaylistId: result.playlistId,
      targetPlaylistUrl
    });
  } catch (error) {
    console.error('Conversion error:', error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Failed to convert playlist' },
      { status: 500 }
    );
  }
}