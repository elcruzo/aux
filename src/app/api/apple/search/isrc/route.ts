import { NextRequest, NextResponse } from 'next/server';
import { searchTracksByISRC } from '@/lib/apple/api';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const isrc = searchParams.get('isrc');
    const storefront = searchParams.get('storefront') || 'us';
    
    if (!isrc) {
      return NextResponse.json(
        { error: 'ISRC parameter is required' },
        { status: 400 }
      );
    }
    
    const tracks = await searchTracksByISRC(isrc, storefront);
    return NextResponse.json(tracks);
  } catch (error) {
    console.error('Failed to search Apple Music tracks by ISRC:', error);
    return NextResponse.json(
      { error: 'Failed to search tracks' },
      { status: 500 }
    );
  }
}