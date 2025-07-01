import { NextRequest, NextResponse } from 'next/server';
import { v4 as uuidv4 } from 'uuid';
import { getSession } from '@/lib/session';
import { getSpotifyAuthUrl } from '@/lib/spotify/auth';

export async function GET(request: NextRequest) {
  try {
    const session = await getSession();
    const state = uuidv4();
    
    // Store state in session for CSRF protection
    session.state = state;
    await session.save();
    
    const authUrl = getSpotifyAuthUrl(state);
    
    return NextResponse.redirect(authUrl);
  } catch (error) {
    console.error('Spotify auth error:', error);
    return NextResponse.redirect('/auth/error?provider=spotify');
  }
}