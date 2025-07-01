'use client';

import { ConversionProgress } from '@/lib/converter';
import { TrackMatch } from '@/types/music';

interface ConversionProgressProps {
  progress: ConversionProgress | null;
  matches?: TrackMatch[];
}

export default function ConversionProgressComponent({ progress, matches }: ConversionProgressProps) {
  if (!progress) return null;

  const getStageIcon = (stage: ConversionProgress['stage']) => {
    switch (stage) {
      case 'fetching':
        return '📥';
      case 'matching':
        return '🔍';
      case 'creating':
        return '📝';
      case 'adding':
        return '➕';
      case 'complete':
        return '✅';
    }
  };

  const percentage = progress.total > 0 ? (progress.current / progress.total) * 100 : 0;

  return (
    <div className="bg-white rounded-lg border border-gray-200 p-6">
      <div className="flex items-center mb-4">
        <span className="text-2xl mr-3">{getStageIcon(progress.stage)}</span>
        <div className="flex-1">
          <h3 className="font-semibold text-gray-900">{progress.message}</h3>
          <p className="text-sm text-gray-500">
            {progress.current} of {progress.total}
          </p>
        </div>
      </div>

      <div className="w-full bg-gray-200 rounded-full h-2 mb-4">
        <div
          className="bg-blue-600 h-2 rounded-full transition-all duration-300"
          style={{ width: `${percentage}%` }}
        />
      </div>

      {matches && matches.length > 0 && progress.stage === 'complete' && (
        <div className="mt-6">
          <h4 className="font-medium text-gray-900 mb-3">Match Summary</h4>
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">High confidence matches:</span>
              <span className="font-medium text-green-600">
                {matches.filter(m => m.confidence === 'high').length}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Medium confidence matches:</span>
              <span className="font-medium text-yellow-600">
                {matches.filter(m => m.confidence === 'medium').length}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Low confidence matches:</span>
              <span className="font-medium text-orange-600">
                {matches.filter(m => m.confidence === 'low').length}
              </span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-gray-600">Failed matches:</span>
              <span className="font-medium text-red-600">
                {matches.filter(m => m.confidence === 'none').length}
              </span>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}