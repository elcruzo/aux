import jwt from 'jsonwebtoken';
import { env } from '@/lib/env';

export interface AppleTokenResponse {
  developerToken: string;
  expiresAt: number;
}

export function generateAppleDeveloperToken(): AppleTokenResponse {
  const privateKey = env.data!.APPLE_PRIVATE_KEY;
  const teamId = env.data!.APPLE_TEAM_ID;
  const keyId = env.data!.APPLE_KEY_ID;
  
  const expiresIn = 60 * 60 * 24; // 24 hours
  const issuedAt = Math.floor(Date.now() / 1000);
  const expiresAt = issuedAt + expiresIn;
  
  const token = jwt.sign({}, privateKey, {
    algorithm: 'ES256',
    expiresIn,
    issuer: teamId,
    header: {
      alg: 'ES256',
      kid: keyId,
    },
  });
  
  return {
    developerToken: token,
    expiresAt: expiresAt * 1000, // Convert to milliseconds
  };
}