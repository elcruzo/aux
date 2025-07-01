'use client';

import { useState, useEffect } from 'react';
import { ConversionDirection, ConversionProgress } from '@/lib/converter';
import { convertPlaylist } from '@/lib/client-converter';
import { Playlist, ConversionResult } from '@/types/music';
import AuthButton from '@/components/AuthButton';
import DirectionToggle from '@/components/DirectionToggle';
import PlaylistSelector from '@/components/PlaylistSelector';
import ConversionProgressComponent from '@/components/ConversionProgress';
import * as spotifyApi from '@/lib/spotify/client-api';
import * as appleApi from '@/lib/apple/client-api';

export default function Home() {
  const [direction, setDirection] = useState<ConversionDirection>('spotify-to-apple');
  const [spotifyAuth, setSpotifyAuth] = useState(false);
  const [appleAuth, setAppleAuth] = useState(false);
  const [playlists, setPlaylists] = useState<Playlist[]>([]);
  const [selectedPlaylist, setSelectedPlaylist] = useState<Playlist | null>(null);
  const [converting, setConverting] = useState(false);
  const [progress, setProgress] = useState<ConversionProgress | null>(null);
  const [result, setResult] = useState<ConversionResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loadingPlaylists, setLoadingPlaylists] = useState(false);

  // Check authentication status
  useEffect(() => {
    checkAuthStatus();
  }, []);

  // Load playlists when auth changes
  useEffect(() => {
    if (direction === 'spotify-to-apple' && spotifyAuth) {
      loadSpotifyPlaylists();
    } else if (direction === 'apple-to-spotify' && appleAuth) {
      loadApplePlaylists();
    }
  }, [direction, spotifyAuth, appleAuth]);

  const checkAuthStatus = async () => {
    try {
      const response = await fetch('/api/auth/status');
      const status = await response.json();
      setSpotifyAuth(status.spotify);
      setAppleAuth(status.apple);
    } catch (err) {
      console.error('Auth check error:', err);
      setSpotifyAuth(false);
      setAppleAuth(false);
    }
  };

  const loadSpotifyPlaylists = async () => {
    setLoadingPlaylists(true);
    try {
      const userPlaylists = await spotifyApi.getUserPlaylists();
      setPlaylists(userPlaylists);
    } catch (err) {
      setError('Failed to load Spotify playlists');
    } finally {
      setLoadingPlaylists(false);
    }
  };

  const loadApplePlaylists = async () => {
    setLoadingPlaylists(true);
    try {
      const userPlaylists = await appleApi.getUserPlaylists();
      setPlaylists(userPlaylists);
    } catch (err) {
      setError('Failed to load Apple Music playlists');
    } finally {
      setLoadingPlaylists(false);
    }
  };

  const handleConvert = async () => {
    if (!selectedPlaylist) return;

    setConverting(true);
    setError(null);
    setResult(null);
    setProgress(null);

    try {
      const conversionResult = await convertPlaylist(
        selectedPlaylist.id,
        selectedPlaylist.name,
        direction,
        (prog) => setProgress(prog)
      );
      setResult(conversionResult);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Conversion failed');
    } finally {
      setConverting(false);
    }
  };

  const sourceAuth = direction === 'spotify-to-apple' ? spotifyAuth : appleAuth;
  const targetAuth = direction === 'spotify-to-apple' ? appleAuth : spotifyAuth;

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto p-6">
        <header className="text-center mb-12">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Aux</h1>
          <p className="text-lg text-gray-600">Universal Playlist Converter</p>
        </header>

        <div className="space-y-8">
          {/* Direction Toggle */}
          <div className="flex justify-center">
            <DirectionToggle direction={direction} onChange={setDirection} />
          </div>

          {/* Authentication */}
          <div className="grid md:grid-cols-2 gap-6">
            <div className="bg-white rounded-lg border border-gray-200 p-6">
              <h2 className="text-lg font-semibold mb-4">Source Platform</h2>
              <AuthButton
                provider={direction === 'spotify-to-apple' ? 'spotify' : 'apple'}
                isAuthenticated={sourceAuth}
                onAuthenticated={checkAuthStatus}
              />
            </div>
            
            <div className="bg-white rounded-lg border border-gray-200 p-6">
              <h2 className="text-lg font-semibold mb-4">Target Platform</h2>
              <AuthButton
                provider={direction === 'spotify-to-apple' ? 'apple' : 'spotify'}
                isAuthenticated={targetAuth}
                onAuthenticated={checkAuthStatus}
              />
            </div>
          </div>

          {/* Playlist Selection */}
          {sourceAuth && targetAuth && (
            <div className="bg-white rounded-lg border border-gray-200 p-6">
              <h2 className="text-lg font-semibold mb-4">Select a Playlist</h2>
              <PlaylistSelector
                playlists={playlists}
                onSelect={setSelectedPlaylist}
                loading={loadingPlaylists}
              />
              
              {selectedPlaylist && (
                <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
                  <p className="text-sm text-blue-800">
                    Selected: <strong>{selectedPlaylist.name}</strong> ({selectedPlaylist.trackCount} tracks)
                  </p>
                  <button
                    onClick={handleConvert}
                    disabled={converting}
                    className="mt-3 w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                  >
                    {converting ? 'Converting...' : 'Start Conversion'}
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Progress & Results */}
          {(progress || result) && (
            <ConversionProgressComponent
              progress={progress}
              matches={result?.matches}
            />
          )}

          {/* Success Message */}
          {result && (
            <div className="bg-green-50 border border-green-200 rounded-lg p-6">
              <h3 className="text-lg font-semibold text-green-900 mb-2">
                Conversion Complete!
              </h3>
              <p className="text-green-700">
                Successfully converted {result.successfulMatches} of {result.totalTracks} tracks.
              </p>
              <button
                onClick={() => {
                  setResult(null);
                  setProgress(null);
                  setSelectedPlaylist(null);
                }}
                className="mt-4 text-green-700 hover:text-green-800 font-medium"
              >
                Convert Another Playlist →
              </button>
            </div>
          )}

          {/* Error Display */}
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <p className="text-red-700">{error}</p>
            </div>
          )}
        </div>

        <footer className="mt-16 text-center text-sm text-gray-500">
          <p>
            Built with ❤️ using Next.js • 
            <a href="https://github.com/your-repo" className="hover:text-gray-700 ml-1">
              View on GitHub
            </a>
          </p>
        </footer>
      </div>
    </div>
  );
}