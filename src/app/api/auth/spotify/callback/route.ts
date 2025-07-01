import { NextRequest, NextResponse } from 'next/server';
import { getSession } from '@/lib/session';
import { exchangeCodeForToken } from '@/lib/spotify/auth';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const code = searchParams.get('code');
    const state = searchParams.get('state');
    const error = searchParams.get('error');
    
    if (error) {
      return NextResponse.redirect(`/auth/error?provider=spotify&error=${error}`);
    }
    
    if (!code || !state) {
      return NextResponse.redirect('/auth/error?provider=spotify&error=missing_params');
    }
    
    const session = await getSession();
    
    // Verify state for CSRF protection
    if (session.state !== state) {
      return NextResponse.redirect('/auth/error?provider=spotify&error=invalid_state');
    }
    
    // Exchange code for tokens
    const tokens = await exchangeCodeForToken(code);
    
    // Store tokens in session
    session.spotify = {
      access_token: tokens.access_token,
      refresh_token: tokens.refresh_token,
      expires_at: tokens.expires_at,
    };
    
    // Clear state
    session.state = undefined;
    await session.save();
    
    return NextResponse.redirect('/');
  } catch (error) {
    console.error('Spotify callback error:', error);
    return NextResponse.redirect('/auth/error?provider=spotify&error=token_exchange');
  }
}