# Aux API Documentation

## Overview

The Aux API provides endpoints for converting playlists between Spotify and Apple Music. This RESTful API handles authentication, playlist management, and track matching.

## Base URL

- Development: `http://localhost:3000/api`
- Production: `https://your-domain.com/api`

## Interactive Documentation

Access the interactive API documentation at:
- Local: http://localhost:3000/api-docs
- Static HTML: http://localhost:3000/api-docs.html

## Authentication

The API uses cookie-based session authentication. Users must authenticate with both Spotify and Apple Music before converting playlists.

### Auth Flow

1. **Check Status**: `GET /api/auth/status`
2. **Spotify Auth**: `GET /api/auth/spotify` → Returns OAuth URL
3. **Apple Auth**: `POST /api/auth/apple/callback` with user token

## Key Endpoints

### Playlists

- `GET /api/spotify/playlists` - Get user's Spotify playlists
- `GET /api/apple/playlists` - Get user's Apple Music playlists
- `GET /api/{platform}/playlists/{id}/tracks` - Get playlist tracks

### Conversion

- `POST /api/convert` - Convert a playlist

Request body:
```json
{
  "playlistId": "spotify:playlist:123",
  "playlistName": "My Playlist",
  "direction": "spotify-to-apple"
}
```

Response:
```json
{
  "playlistId": "spotify:playlist:123",
  "playlistName": "My Playlist",
  "totalTracks": 50,
  "successfulMatches": 48,
  "failedMatches": 2,
  "targetPlaylistId": "apple:playlist:456",
  "targetPlaylistUrl": "https://music.apple.com/...",
  "matches": [...]
}
```

## Track Matching Algorithm

The API uses a multi-step matching process:

1. **ISRC Match** - International Standard Recording Code (most accurate)
2. **Metadata Search** - Artist + Track name + Album
3. **Fuzzy Search** - Normalized string matching

## Error Handling

All errors follow this format:
```json
{
  "error": "Error description"
}
```

Common status codes:
- `401` - Authentication required
- `400` - Bad request
- `429` - Rate limited
- `500` - Server error

## Rate Limits

- Spotify: 180 requests per minute
- Apple Music: Based on user's token limits

## Development

### Running Locally

```bash
cd aux-app
npm install
npm run dev
```

### Testing the API

Use the Swagger UI at `/api-docs` or test with curl:

```bash
# Check auth status
curl http://localhost:3000/api/auth/status

# Get Spotify playlists (with session cookie)
curl http://localhost:3000/api/spotify/playlists \
  -H "Cookie: session=..."
```

## SDK Integration

The iOS app uses the APIClient to interact with this API:

```swift
let playlists = try await apiClient.getSpotifyPlaylists()
let result = try await apiClient.convertPlaylist(
    playlistId: playlist.id,
    playlistName: playlist.name,
    direction: .spotifyToApple
)
```