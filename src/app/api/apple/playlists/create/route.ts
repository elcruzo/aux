import { NextRequest, NextResponse } from 'next/server';
import { createPlaylist, addTracksToPlaylist } from '@/lib/apple/api';

export async function POST(request: NextRequest) {
  try {
    const { name, description, tracks } = await request.json();
    
    if (!name) {
      return NextResponse.json(
        { error: 'Playlist name is required' },
        { status: 400 }
      );
    }
    
    const playlistId = await createPlaylist(name, description);
    
    if (tracks && tracks.length > 0) {
      await addTracksToPlaylist(playlistId, tracks);
    }
    
    return NextResponse.json({ id: playlistId });
  } catch (error) {
    console.error('Failed to create Apple Music playlist:', error);
    return NextResponse.json(
      { error: 'Failed to create playlist' },
      { status: 500 }
    );
  }
}