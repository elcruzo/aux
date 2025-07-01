'use client';

import { ConversionDirection } from '@/lib/converter';

interface DirectionToggleProps {
  direction: ConversionDirection;
  onChange: (direction: ConversionDirection) => void;
}

export default function DirectionToggle({ direction, onChange }: DirectionToggleProps) {
  return (
    <div className="flex items-center justify-center space-x-4 p-4 bg-white rounded-lg border border-gray-200">
      <div className="flex items-center">
        <span className={`font-medium ${direction === 'spotify-to-apple' ? 'text-green-600' : 'text-gray-400'}`}>
          Spotify
        </span>
      </div>
      
      <button
        onClick={() => onChange(direction === 'spotify-to-apple' ? 'apple-to-spotify' : 'spotify-to-apple')}
        className="relative inline-flex h-8 w-14 items-center rounded-full bg-gray-200 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
      >
        <span
          className={`inline-block h-6 w-6 transform rounded-full bg-white shadow-lg transition-transform ${
            direction === 'spotify-to-apple' ? 'translate-x-1' : 'translate-x-7'
          }`}
        />
      </button>
      
      <div className="flex items-center">
        <span className={`font-medium ${direction === 'apple-to-spotify' ? 'text-gray-900' : 'text-gray-400'}`}>
          Apple Music
        </span>
      </div>
    </div>
  );
}