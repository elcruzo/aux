# Aux API Curl Commands

Base URL: `https://aux-50dr.onrender.com`

## 1. Check Auth Status
```bash
curl https://aux-50dr.onrender.com/api/auth/status
```

## 2. Get Spotify Auth URL
```bash
curl https://aux-50dr.onrender.com/api/auth/spotify
```

## 3. Test Convert Endpoint (requires auth)
```bash
curl -X POST https://aux-50dr.onrender.com/api/convert \
  -H "Content-Type: application/json" \
  -d '{
    "playlistId": "37i9dQZF1DXcBWIGoYBM5M",
    "playlistName": "Today's Top Hits",
    "direction": "spotify-to-apple"
  }'
```

## 4. Get Spotify Playlists (requires auth)
```bash
curl https://aux-50dr.onrender.com/api/spotify/playlists \
  -H "Cookie: aux-session=YOUR_SESSION_COOKIE"
```

## 5. Get Apple Music Playlists (requires auth)
```bash
curl https://aux-50dr.onrender.com/api/apple/playlists \
  -H "Cookie: aux-session=YOUR_SESSION_COOKIE"
```

## 6. View API Documentation
```bash
# In browser:
open https://aux-50dr.onrender.com/api-docs

# Or with curl:
curl https://aux-50dr.onrender.com/api-docs
```

## 7. Get Swagger JSON
```bash
curl https://aux-50dr.onrender.com/swagger.json | jq '.'
```

## 8. Test Root Endpoint
```bash
curl https://aux-50dr.onrender.com/
```

## 9. Test with Pretty JSON output
```bash
# Install jq if you haven't: brew install jq
curl https://aux-50dr.onrender.com/api/auth/status | jq '.'
```

## Notes:
- Most endpoints require authentication via session cookie
- The `/api/auth/spotify` endpoint will redirect to Spotify for OAuth
- Replace `YOUR_SESSION_COOKIE` with actual session after authenticating