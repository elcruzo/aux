import { NextResponse } from 'next/server';
import { getSession } from '@/lib/session';

export async function GET() {
  try {
    const session = await getSession();
    
    return NextResponse.json({
      spotify: !!session.spotify && Date.now() < session.spotify.expires_at,
      apple: !!session.apple && Date.now() < session.apple.expires_at,
    });
  } catch (error) {
    return NextResponse.json({
      spotify: false,
      apple: false,
    });
  }
}