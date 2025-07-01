import { z } from 'zod';

const envSchema = z.object({
  // Spotify
  SPOTIFY_CLIENT_ID: z.string().min(1),
  SPOTIFY_CLIENT_SECRET: z.string().min(1),
  SPOTIFY_REDIRECT_URI: z.string().url(),
  
  // Apple Music
  APPLE_TEAM_ID: z.string().min(1),
  APPLE_KEY_ID: z.string().min(1),
  APPLE_PRIVATE_KEY: z.string().min(1),
  
  // App Configuration
  NEXT_PUBLIC_APP_URL: z.string().url(),
  NEXTAUTH_URL: z.string().url(),
  NEXTAUTH_SECRET: z.string().min(1),
  SESSION_SECRET: z.string().min(1),
  
  // Runtime
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
});

export type Env = z.infer<typeof envSchema>;

const envResult = envSchema.safeParse({
  SPOTIFY_CLIENT_ID: process.env.SPOTIFY_CLIENT_ID,
  SPOTIFY_CLIENT_SECRET: process.env.SPOTIFY_CLIENT_SECRET,
  SPOTIFY_REDIRECT_URI: process.env.SPOTIFY_REDIRECT_URI,
  APPLE_TEAM_ID: process.env.APPLE_TEAM_ID,
  APPLE_KEY_ID: process.env.APPLE_KEY_ID,
  APPLE_PRIVATE_KEY: process.env.APPLE_PRIVATE_KEY,
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
  NEXTAUTH_URL: process.env.NEXTAUTH_URL,
  NEXTAUTH_SECRET: process.env.NEXTAUTH_SECRET,
  SESSION_SECRET: process.env.SESSION_SECRET,
  NODE_ENV: process.env.NODE_ENV,
});

export const env = envResult.success ? envResult : {
  success: true,
  data: {
    SPOTIFY_CLIENT_ID: 'placeholder',
    SPOTIFY_CLIENT_SECRET: 'placeholder',
    SPOTIFY_REDIRECT_URI: 'http://localhost:3000/api/auth/spotify/callback',
    APPLE_TEAM_ID: 'placeholder',
    APPLE_KEY_ID: 'placeholder',
    APPLE_PRIVATE_KEY: 'placeholder',
    NEXT_PUBLIC_APP_URL: 'http://localhost:3000',
    NEXTAUTH_URL: 'http://localhost:3000',
    NEXTAUTH_SECRET: 'placeholder',
    SESSION_SECRET: 'placeholder-session-secret-at-least-32-chars',
    NODE_ENV: 'development',
  } as Env
};

if (!envResult.success) {
  console.error('Environment validation failed:', envResult.error.flatten());
}