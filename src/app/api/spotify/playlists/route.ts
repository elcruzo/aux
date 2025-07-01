import { NextResponse } from 'next/server';
import { getUserPlaylists } from '@/lib/spotify/api';

export async function GET() {
  try {
    const playlists = await getUserPlaylists();
    return NextResponse.json(playlists);
  } catch (error) {
    console.error('Failed to fetch Spotify playlists:', error);
    return NextResponse.json(
      { error: 'Failed to fetch playlists' },
      { status: 500 }
    );
  }
}