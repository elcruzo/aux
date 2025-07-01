# Aux - Universal Playlist Converter

Convert playlists between Spotify and Apple Music seamlessly.

## Setup Instructions

### Prerequisites
- Node.js 18+ installed
- npm or yarn package manager
- Spotify Developer Account
- Apple Developer Account ($99/year for MusicKit access)

### API Keys Required

#### 1. Spotify API Setup
1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note your Client ID and Client Secret
4. Add redirect URI: `http://localhost:3000/api/auth/spotify/callback`

#### 2. Apple Music API Setup
1. Sign in to [Apple Developer](https://developer.apple.com)
2. Go to Certificates, Identifiers & Profiles
3. Create a new Media ID (Services → Media IDs)
4. Create a MusicKit key:
   - Keys → Create a new key
   - Enable MusicKit
   - Download the .p8 file
   - Note the Key ID and Team ID

### Environment Variables

Create a `.env.local` file in the root directory:

```env
# Spotify
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/auth/spotify/callback

# Apple Music
APPLE_TEAM_ID=your_apple_team_id
APPLE_KEY_ID=your_musickit_key_id
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
your_p8_file_contents_here
-----END PRIVATE KEY-----"

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=generate_a_random_string_here

# Session encryption (generate with: openssl rand -base64 32)
SESSION_SECRET=your_session_secret_here
```

### Installation

```bash
# Clone the repository
git clone [your-repo-url]
cd aux-app

# Install dependencies
npm install

# Run development server
npm run dev
```

### Generating Secrets

```bash
# Generate NEXTAUTH_SECRET
openssl rand -base64 32

# Generate SESSION_SECRET
openssl rand -base64 32
```

### Apple Music Private Key

Place your downloaded .p8 file contents in the `APPLE_PRIVATE_KEY` environment variable. Make sure to keep the BEGIN/END markers and maintain the line breaks.

## Development

```bash
# Run development server
npm run dev

# Run tests
npm test

# Type checking
npm run type-check

# Linting
npm run lint

# Build for production
npm run build
```

## Testing Your Setup

1. Start the dev server: `npm run dev`
2. Navigate to http://localhost:3000
3. Try authenticating with Spotify first
4. Then authenticate with Apple Music
5. Test converting a small playlist

## Troubleshooting

### Spotify Issues
- Ensure redirect URI matches exactly in Spotify dashboard
- Check that Client ID and Secret are correct
- Verify the app is not in development mode if testing with other users

### Apple Music Issues
- Verify your Apple Developer account is active
- Ensure the .p8 key file contents are correctly formatted
- Check that Team ID and Key ID match your developer account
- MusicKit tokens expire after 24 hours - the app handles renewal automatically

### Common Errors
- `401 Unauthorized`: Check your API credentials
- `429 Too Many Requests`: You've hit rate limits, wait a moment
- `Network Error`: Check your internet connection and CORS settings

## Support

For issues or questions, please check the troubleshooting guide above or create an issue in the repository.