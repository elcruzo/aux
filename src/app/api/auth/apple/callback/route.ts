import { NextRequest, NextResponse } from 'next/server';
import { getSession } from '@/lib/session';

export async function POST(request: NextRequest) {
  try {
    const { musicUserToken, expiresAt } = await request.json();
    
    if (!musicUserToken) {
      return NextResponse.json(
        { error: 'Missing music user token' },
        { status: 400 }
      );
    }
    
    const session = await getSession();
    
    // Store Apple Music user token in session
    session.apple = {
      music_user_token: musicUserToken,
      expires_at: expiresAt,
    };
    
    await session.save();
    
    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Apple Music callback error:', error);
    return NextResponse.json(
      { error: 'Failed to save Apple Music token' },
      { status: 500 }
    );
  }
}