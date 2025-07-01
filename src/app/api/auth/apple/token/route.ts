import { NextResponse } from 'next/server';
import { generateAppleDeveloperToken } from '@/lib/apple/auth';

export async function GET() {
  try {
    const tokenData = generateAppleDeveloperToken();
    
    return NextResponse.json({
      token: tokenData.developerToken,
      expiresAt: tokenData.expiresAt,
    });
  } catch (error) {
    console.error('Apple developer token generation error:', error);
    return NextResponse.json(
      { error: 'Failed to generate developer token' },
      { status: 500 }
    );
  }
}