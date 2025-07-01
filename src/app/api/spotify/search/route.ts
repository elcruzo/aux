import { NextRequest, NextResponse } from 'next/server';
import { searchTracks } from '@/lib/spotify/api';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const query = searchParams.get('q');
    const limit = searchParams.get('limit');
    
    if (!query) {
      return NextResponse.json(
        { error: 'Query parameter is required' },
        { status: 400 }
      );
    }
    
    const tracks = await searchTracks(query, limit ? parseInt(limit) : 10);
    return NextResponse.json(tracks);
  } catch (error) {
    console.error('Failed to search Spotify tracks:', error);
    return NextResponse.json(
      { error: 'Failed to search tracks' },
      { status: 500 }
    );
  }
}