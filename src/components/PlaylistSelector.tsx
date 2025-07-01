'use client';

import { useState } from 'react';
import { Playlist } from '@/types/music';

interface PlaylistSelectorProps {
  playlists: Playlist[];
  onSelect: (playlist: Playlist) => void;
  loading?: boolean;
}

export default function PlaylistSelector({ playlists, onSelect, loading }: PlaylistSelectorProps) {
  const [searchTerm, setSearchTerm] = useState('');

  const filteredPlaylists = playlists.filter(playlist =>
    playlist.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
      </div>
    );
  }

  return (
    <div>
      <input
        type="text"
        placeholder="Search playlists..."
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 mb-4"
      />
      
      <div className="grid gap-4 max-h-96 overflow-y-auto">
        {filteredPlaylists.length === 0 ? (
          <p className="text-gray-500 text-center">No playlists found</p>
        ) : (
          filteredPlaylists.map((playlist) => (
            <button
              key={playlist.id}
              onClick={() => onSelect(playlist)}
              className="flex items-center p-4 bg-white rounded-lg border border-gray-200 hover:border-blue-500 hover:shadow-sm transition-all text-left"
            >
              {playlist.imageUrl && (
                <img
                  src={playlist.imageUrl}
                  alt={playlist.name}
                  className="w-16 h-16 rounded-md mr-4 object-cover"
                />
              )}
              <div className="flex-1">
                <h3 className="font-semibold text-gray-900">{playlist.name}</h3>
                {playlist.description && (
                  <p className="text-sm text-gray-500 line-clamp-1">{playlist.description}</p>
                )}
                <p className="text-xs text-gray-400 mt-1">
                  {playlist.trackCount} tracks • by {playlist.owner}
                </p>
              </div>
              <svg
                className="w-5 h-5 text-gray-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 5l7 7-7 7"
                />
              </svg>
            </button>
          ))
        )}
      </div>
    </div>
  );
}