import { NextRequest, NextResponse } from 'next/server';
import { PlaylistConverter } from '@/lib/converter';

export async function POST(request: NextRequest) {
  try {
    const { playlistId, playlistName, direction } = await request.json();
    
    if (!playlistId || !playlistName || !direction) {
      return NextResponse.json(
        { error: 'Missing required parameters' },
        { status: 400 }
      );
    }
    
    const converter = new PlaylistConverter();
    const result = await converter.convertPlaylist(playlistId, playlistName, direction);
    
    return NextResponse.json(result);
  } catch (error) {
    console.error('Conversion error:', error);
    return NextResponse.json(
      { error: error instanceof Error ? error.message : 'Conversion failed' },
      { status: 500 }
    );
  }
}