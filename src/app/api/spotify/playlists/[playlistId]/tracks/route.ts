import { NextRequest, NextResponse } from 'next/server';
import { getPlaylistTracks } from '@/lib/spotify/api';

export async function GET(
  request: NextRequest,
  context: { params: Promise<{ playlistId: string }> }
) {
  try {
    const { playlistId } = await context.params;
    const tracks = await getPlaylistTracks(playlistId);
    return NextResponse.json(tracks);
  } catch (error) {
    console.error('Failed to fetch Spotify playlist tracks:', error);
    return NextResponse.json(
      { error: 'Failed to fetch tracks' },
      { status: 500 }
    );
  }
}