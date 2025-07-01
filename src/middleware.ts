import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Handle environment variable checks
  if (request.nextUrl.pathname.startsWith('/api/')) {
    try {
      // Ensure critical environment variables are set
      const requiredEnvVars = [
        'SPOTIFY_CLIENT_ID',
        'SPOTIFY_CLIENT_SECRET',
        'APPLE_TEAM_ID',
        'APPLE_KEY_ID',
        'SESSION_SECRET',
      ];

      for (const envVar of requiredEnvVars) {
        if (!process.env[envVar]) {
          return NextResponse.json(
            { error: `Missing required environment variable: ${envVar}` },
            { status: 500 }
          );
        }
      }
    } catch (error) {
      console.error('Middleware error:', error);
    }
  }

  return NextResponse.next();
}

export const config = {
  matcher: '/api/:path*',
};