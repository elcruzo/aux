'use client';

import { useState } from 'react';
import { configureMusicKit, authorizeMusicKit } from '@/lib/musickit';

interface AuthButtonProps {
  provider: 'spotify' | 'apple';
  isAuthenticated: boolean;
  onAuthenticated?: () => void;
}

export default function AuthButton({ provider, isAuthenticated, onAuthenticated }: AuthButtonProps) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSpotifyAuth = () => {
    window.location.href = '/api/auth/spotify';
  };

  const handleAppleAuth = async () => {
    setLoading(true);
    setError(null);

    try {
      // Get developer token
      const response = await fetch('/api/auth/apple/token');
      const { token } = await response.json();

      // Configure MusicKit
      const music = await configureMusicKit(token);
      
      // Authorize user
      const musicUserToken = await authorizeMusicKit(music);
      
      // Save token to session
      const saveResponse = await fetch('/api/auth/apple/callback', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          musicUserToken,
          expiresAt: Date.now() + (24 * 60 * 60 * 1000), // 24 hours
        }),
      });

      if (!saveResponse.ok) {
        throw new Error('Failed to save Apple Music token');
      }

      if (onAuthenticated) {
        onAuthenticated();
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Authentication failed');
    } finally {
      setLoading(false);
    }
  };

  const handleAuth = () => {
    if (provider === 'spotify') {
      handleSpotifyAuth();
    } else {
      handleAppleAuth();
    }
  };

  if (isAuthenticated) {
    return (
      <div className="flex items-center space-x-2 text-green-600">
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
        </svg>
        <span>Connected to {provider === 'spotify' ? 'Spotify' : 'Apple Music'}</span>
      </div>
    );
  }

  return (
    <div>
      <button
        onClick={handleAuth}
        disabled={loading}
        className={`px-4 py-2 rounded-lg font-medium transition-colors ${
          provider === 'spotify'
            ? 'bg-green-600 hover:bg-green-700 text-white'
            : 'bg-gray-900 hover:bg-gray-800 text-white'
        } disabled:opacity-50 disabled:cursor-not-allowed`}
      >
        {loading ? 'Connecting...' : `Connect ${provider === 'spotify' ? 'Spotify' : 'Apple Music'}`}
      </button>
      {error && (
        <p className="mt-2 text-sm text-red-600">{error}</p>
      )}
    </div>
  );
}