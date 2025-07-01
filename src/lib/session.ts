import { getIronSession, IronSession, SessionOptions } from 'iron-session';
import { cookies } from 'next/headers';
import { env } from '@/lib/env';

export interface SessionData {
  spotify?: {
    access_token: string;
    refresh_token: string;
    expires_at: number;
  };
  apple?: {
    music_user_token: string;
    expires_at: number;
  };
  state?: string;
}

const sessionOptions: SessionOptions = {
  password: env.data!.SESSION_SECRET,
  cookieName: 'aux-session',
  cookieOptions: {
    secure: env.data!.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: 'lax',
    maxAge: 60 * 60 * 24 * 30, // 30 days
  },
};

export async function getSession(): Promise<IronSession<SessionData>> {
  const cookieStore = await cookies();
  return getIronSession<SessionData>(cookieStore, sessionOptions);
}