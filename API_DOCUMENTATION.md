# Aux API Documentation

## Overview

The Aux API provides endpoints for converting playlists between Spotify and Apple Music. This RESTful API handles authentication, playlist management, and track matching.

## Base URL

- Production: `https://aux-50dr.onrender.com/api`
- Development: `http://localhost:3000/api`

## Interactive Documentation

Access the interactive Swagger UI documentation at:
- **Production**: https://aux-50dr.onrender.com/api-docs
- **Development**: http://localhost:3000/api-docs

## Authentication

The API uses cookie-based session authentication. iOS app users authenticate via OAuth flows.

### Check Authentication Status

**GET** `/api/auth/status`

Returns the current authentication status for both platforms.

Response:
```json
{
  "spotify": true,
  "apple": false
}
```

### Spotify Authentication

**GET** `/api/auth/spotify`

Initiates Spotify OAuth flow. Returns redirect URL for iOS app.

Response:
```json
{
  "url": "https://accounts.spotify.com/authorize?client_id=..."
}
```

**GET** `/api/auth/spotify/callback?code={code}&state={state}`

Handles Spotify OAuth callback. Sets session cookie.

### Apple Music Authentication

**POST** `/api/auth/apple/callback`

Saves Apple Music user token from iOS app.

Request body:
```json
{
  "userToken": "eyJhbGc..."
}
```

## Playlist Operations

### Get User's Playlists

**GET** `/api/spotify/playlists`
**GET** `/api/apple/playlists`

Returns user's playlists for the specified platform.

Response:
```json
{
  "playlists": [
    {
      "id": "37i9dQZF1DX5Ejj0EkURtP",
      "name": "Today's Top Hits",
      "description": "The hottest tracks in the world",
      "imageUrl": "https://i.scdn.co/image/...",
      "trackCount": 50,
      "owner": "Spotify",
      "isPublic": true
    }
  ]
}
```

### Get Playlist Tracks

**GET** `/api/spotify/playlists/{playlistId}/tracks`
**GET** `/api/apple/playlists/{playlistId}/tracks`

Returns all tracks in a playlist.

Response:
```json
{
  "tracks": [
    {
      "id": "track123",
      "name": "Flowers",
      "artist": "Miley Cyrus",
      "album": "Endless Summer Vacation",
      "duration": 200000,
      "isrc": "USSM12209515",
      "popularity": 95,
      "previewUrl": "https://p.scdn.co/..."
    }
  ]
}
```

## Playlist Conversion

### Convert Playlist

**POST** `/api/convert`

Converts a playlist from one platform to another.

Request body:
```json
{
  "playlistId": "37i9dQZF1DX5Ejj0EkURtP",
  "playlistName": "Today's Top Hits",
  "direction": "spotify-to-apple"
}
```

Response:
```json
{
  "playlistId": "37i9dQZF1DX5Ejj0EkURtP",
  "playlistName": "Today's Top Hits",
  "totalTracks": 50,
  "successfulMatches": 48,
  "failedMatches": 2,
  "targetPlaylistId": "pl.f4d106fed2bd41149aaacabb233eb5eb",
  "targetPlaylistUrl": "https://music.apple.com/playlist/pl.f4d106fed2bd41149aaacabb233eb5eb",
  "matches": [
    {
      "status": "matched",
      "confidence": 1.0,
      "sourceTrack": {
        "name": "Flowers",
        "artist": "Miley Cyrus"
      },
      "targetTrack": {
        "id": "1622855135",
        "name": "Flowers",
        "artist": "Miley Cyrus"
      }
    },
    {
      "status": "not_found",
      "sourceTrack": {
        "name": "Some Rare Track",
        "artist": "Unknown Artist"
      },
      "reason": "No match found"
    }
  ]
}
```

### Direction Values
- `spotify-to-apple` - Convert from Spotify to Apple Music
- `apple-to-spotify` - Convert from Apple Music to Spotify

## Track Matching Algorithm

The API uses a sophisticated multi-step matching process:

1. **ISRC Match** (100% confidence)
   - International Standard Recording Code
   - Most accurate method
   - Unique identifier for recordings

2. **Exact Metadata Match** (95% confidence)
   - Artist name + Track name + Album name
   - Case-insensitive comparison
   - Handles special characters

3. **Fuzzy Search** (80-90% confidence)
   - Normalized string matching
   - Handles slight variations
   - Removes featuring artists for comparison

## Error Responses

All errors return consistent JSON format:

```json
{
  "error": "Detailed error message"
}
```

### Status Codes

- `200` - Success
- `400` - Bad Request (invalid parameters)
- `401` - Unauthorized (authentication required)
- `404` - Not Found (playlist or track not found)
- `429` - Rate Limited
- `500` - Internal Server Error

### Common Errors

```json
// Not authenticated
{
  "error": "Please authenticate with Spotify first"
}

// Invalid playlist
{
  "error": "Playlist not found or access denied"
}

// Rate limited
{
  "error": "Rate limit exceeded. Please try again later"
}
```

## Rate Limits

- **Spotify API**: 180 requests per minute
- **Apple Music API**: Based on user token (typically 900/hour)
- **Conversion endpoint**: 10 conversions per minute per user

## iOS App Integration

The iOS app uses the `APIClient` class to interact with these endpoints:

```swift
// Check authentication
let status = try await apiClient.getAuthStatus()

// Get playlists
let playlists = try await apiClient.getSpotifyPlaylists()

// Convert playlist
let result = try await apiClient.convertPlaylist(
    playlistId: playlist.id,
    playlistName: playlist.name,
    direction: .spotifyToApple
)
```

## Session Management

- Sessions expire after 7 days of inactivity
- Spotify tokens refresh automatically
- Apple Music tokens are valid for 6 months
- iOS app handles re-authentication when needed

## Security

- All endpoints use HTTPS in production
- Session cookies are httpOnly and secure
- OAuth state parameter prevents CSRF attacks
- No user data is stored permanently

## Support

For API issues or questions:
- Email: ayomideadekoya266@gmail.com
- GitHub: https://github.com/elcruzo/aux
- API Status: https://aux-50dr.onrender.com/api/auth/status
- Interactive Docs: https://aux-50dr.onrender.com/api-docs