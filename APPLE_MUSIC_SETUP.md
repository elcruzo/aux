# Apple Music API Setup Guide

Since you have an Apple Developer account, here's how to get your credentials:

## Step 1: Get Your Team ID
1. Go to [Apple Developer](https://developer.apple.com)
2. Sign in with your Apple ID
3. Click on "Account" in the top menu
4. Under "Membership Details", you'll see your **Team ID** (looks like: ABCD123456)

## Step 2: Create a Media ID (App ID)
1. Go to [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
2. Click the "+" button next to "Identifiers"
3. Select "Media IDs" and click Continue
4. Select "MusicKit" and click Continue
5. Enter:
   - Description: "Aux Music Converter" (or any name you prefer)
   - Identifier: "com.yourname.aux" (or any reverse-domain format)
6. Click Continue, then Register

## Step 3: Create a MusicKit Key
1. Go to [Keys](https://developer.apple.com/account/resources/authkeys/list)
2. Click the "+" button to create a new key
3. Enter:
   - Key Name: "Aux MusicKit Key" (or any name)
   - Check the box for "Enable MusicKit"
4. Click Continue, then Register
5. **IMPORTANT**: Download the key file (it will be named something like `AuthKey_XXXXXXXXXX.p8`)
   - **Save this file securely! You can only download it once!**
6. Note the **Key ID** shown on the page (looks like: XXXXXXXXXX)

## Step 4: Update Your .env.local File

Now update your `.env.local` with the values:

```env
# Apple Music
APPLE_TEAM_ID=YOUR_TEAM_ID_HERE
APPLE_KEY_ID=YOUR_KEY_ID_HERE
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
PASTE_THE_ENTIRE_CONTENTS_OF_YOUR_P8_FILE_HERE
INCLUDING_ALL_THE_LINES_BETWEEN_BEGIN_AND_END
-----END PRIVATE KEY-----"
```

### How to add the private key:
1. Open the `.p8` file you downloaded in a text editor
2. Copy the ENTIRE contents (including the BEGIN/END lines)
3. Paste it into the `APPLE_PRIVATE_KEY` value in `.env.local`

## Example .env.local (with your Spotify credentials):

```env
# Spotify
SPOTIFY_CLIENT_ID=7ab90fb9a92940d0a15abb8951385360
SPOTIFY_CLIENT_SECRET=8faf9b788ade4202ba42239a66420977
SPOTIFY_REDIRECT_URI=http://localhost:3000/api/auth/spotify/callback

# Apple Music
APPLE_TEAM_ID=ABCD123456
APPLE_KEY_ID=XXXXXXXXXX
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg[...]
[multiple lines of base64 encoded key data]
[...]gCJA==
-----END PRIVATE KEY-----"

# App Configuration (keep these as is)
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=development-secret-change-this
SESSION_SECRET=development-session-secret-at-least-32-chars
```

## Troubleshooting

### "Invalid authentication" errors
- Make sure you copied the ENTIRE .p8 file contents including BEGIN/END lines
- Verify the Team ID and Key ID are correct
- Ensure the key has MusicKit enabled

### "Token generation failed"
- Check that the private key is properly formatted in the .env.local file
- Make sure there are no extra spaces or line breaks outside the key content

## Testing Your Setup

After updating `.env.local`:

1. Restart your development server: `npm run dev`
2. Go to http://localhost:3000
3. Try authenticating with Apple Music
4. If it works, you should see "Connected to Apple Music" ✓

Need help? Check the Apple Music API documentation at:
https://developer.apple.com/documentation/applemusicapi/