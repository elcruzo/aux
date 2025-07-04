export interface ParsedPlaylistInfo {
  platform: 'spotify' | 'apple';
  playlistId: string;
  region?: string;
}

export function parsePlaylistUrl(url: string): ParsedPlaylistInfo | null {
  try {
    const urlObj = new URL(url);
    
    // Spotify: https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M
    if (urlObj.hostname === 'open.spotify.com' && urlObj.pathname.includes('/playlist/')) {
      const matches = urlObj.pathname.match(/\/playlist\/([a-zA-Z0-9]+)/);
      if (matches?.[1]) {
        return {
          platform: 'spotify',
          playlistId: matches[1]
        };
      }
    }
    
    // Spotify URI: spotify:playlist:37i9dQZF1DXcBWIGoYBM5M
    if (url.startsWith('spotify:playlist:')) {
      return {
        platform: 'spotify',
        playlistId: url.split(':')[2]
      };
    }
    
    // Apple Music: https://music.apple.com/us/playlist/todays-hits/pl.f4d106fed2bd41149aaacabb233eb5eb
    if (urlObj.hostname === 'music.apple.com') {
      const pathParts = urlObj.pathname.split('/');
      let playlistId: string | null = null;
      let region = 'us';
      
      // Extract region
      if (pathParts[1]?.length === 2) {
        region = pathParts[1];
      }
      
      // Find playlist ID (starts with pl.)
      for (const part of pathParts) {
        if (part.startsWith('pl.')) {
          playlistId = part;
          break;
        }
      }
      
      if (playlistId) {
        return {
          platform: 'apple',
          playlistId,
          region
        };
      }
    }
    
  } catch (error) {
    console.error('Error parsing playlist URL:', error);
  }
  
  return null;
}

export function isValidPlaylistUrl(url: string): boolean {
  return parsePlaylistUrl(url) !== null;
}