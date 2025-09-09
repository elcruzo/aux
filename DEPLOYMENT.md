# 🚀 Aux iOS App Deployment Guide

Complete guide for deploying the Aux playlist converter iOS app to the App Store.

## 📋 Prerequisites

### Development Environment
- macOS 14+ (Sonoma)
- Xcode 15.0+
- iOS 16.0+ deployment target
- Active Apple Developer Account ($99/year)

### Required Accounts & Services
- **Apple Developer Account**: Code signing and App Store distribution
- **App Store Connect**: App management and TestFlight
- **Spotify Developer**: API access for playlist conversion
- **Apple Music API**: MusicKit integration
- **Backend API**: aux-50dr.onrender.com (already deployed)

## 🔧 Initial Setup

### 1. Apple Developer Configuration

```bash
# Install Xcode command line tools
xcode-select --install

# Install fastlane for automation
sudo gem install fastlane
```

### 2. App Store Connect Setup

1. **Create App Record**:
   - Bundle ID: `com.elcruzo.aux`
   - App Name: "Aux - Playlist Converter"
   - Primary Language: English
   - SKU: `aux-ios-app`

2. **Configure App Information**:
   - Category: Music
   - Content Rating: 4+ (Clean content)
   - Privacy Policy URL: `https://aux-50dr.onrender.com/privacy`
   - Support URL: `https://aux-50dr.onrender.com/support`

### 3. Certificates & Provisioning

```bash
# Using match for certificate management
fastlane match init

# Generate certificates
fastlane match development
fastlane match appstore
```

## 🏗️ Build Configuration

### 1. Project Settings

```swift
// Configuration.xcconfig
PRODUCT_BUNDLE_IDENTIFIER = com.elcruzo.aux
CODE_SIGN_STYLE = Manual
DEVELOPMENT_TEAM = [YOUR_TEAM_ID]
PROVISIONING_PROFILE_SPECIFIER = match AppStore com.elcruzo.aux
```

### 2. Info.plist Requirements

```xml
<key>NSAppleMusicUsageDescription</key>
<string>Aux needs access to your Apple Music library to convert playlists between platforms.</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>aux</string>
        </array>
        <key>CFBundleURLName</key>
        <string>com.elcruzo.aux.deeplink</string>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>spotify</string>
    <string>music</string>
</array>
```

### 3. Entitlements

```xml
<!-- Aux.entitlements -->
<key>com.apple.developer.musickit</key>
<true/>

<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.elcruzo.aux</string>
</array>

<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:aux-50dr.onrender.com</string>
</array>
```

## 📱 App Store Submission

### 1. Build and Archive

#### Manual Build
```bash
# Clean build
./scripts/build-and-deploy.sh --clean-only

# Run tests
./scripts/build-and-deploy.sh --test-only

# Build for App Store
./scripts/build-and-deploy.sh --app-store --bump-version patch
```

#### Automated Build (Fastlane)
```bash
# Full CI pipeline
fastlane ci

# Deploy to TestFlight
fastlane beta

# Deploy to App Store
fastlane release
```

### 2. GitHub Actions CI/CD

The repository includes automated CI/CD that:
- ✅ Runs tests on every PR
- 🧪 Deploys to TestFlight on main branch
- 🚀 Deploys to App Store on releases

**Required Secrets:**
```
APP_STORE_CONNECT_API_KEY      # Base64 encoded .p8 key
APP_STORE_CONNECT_ISSUER_ID    # Issuer ID from App Store Connect
APP_STORE_CONNECT_KEY_ID       # Key ID from API key
CERTIFICATES_P12               # Base64 encoded certificates
CERTIFICATES_PASSWORD          # Certificate password
PROVISIONING_PROFILE           # Base64 encoded provisioning profile
KEYCHAIN_PASSWORD              # Temporary keychain password
SLACK_WEBHOOK_URL              # Optional: Slack notifications
```

### 3. App Store Metadata

#### App Description
```
Convert playlists between Spotify and Apple Music with just a tap! Aux makes it effortless to share and enjoy music across platforms.

🎵 SEAMLESS CONVERSION
• Share any playlist link to Aux for instant conversion
• Smart matching finds the exact same songs on your platform
• Works with public playlists, personal playlists, and collaborative playlists
• Universal Share Extension works from any app

✨ SMART FEATURES
• Advanced algorithm ensures perfect song matching
• Conversion history to track all your converted playlists
• Beautiful, native iOS interface
• Privacy-first design - no data stored or tracked

Perfect for music lovers who want to share playlists with friends regardless of their music platform preference. Never miss out on great music again!
```

#### Keywords
```
playlist,convert,spotify,apple music,music,share,transfer,convert playlist
```

#### Screenshots Required
- 6.7" iPhone (iPhone 15 Pro Max): 3-10 screenshots
- 6.5" iPhone (iPhone 14 Plus): 3-10 screenshots  
- 5.5" iPhone (iPhone 8 Plus): 3-10 screenshots
- 12.9" iPad Pro: 3-10 screenshots

## 🧪 TestFlight Beta Testing

### 1. Internal Testing
- Development team members
- Up to 100 internal testers
- No review required

### 2. External Testing
- Public beta testers
- Up to 10,000 external testers
- Requires beta app review

### 3. TestFlight Commands
```bash
# Upload to TestFlight
fastlane beta

# Or manual upload
xcrun altool --upload-app \
  -f build/Aux.ipa \
  -t ios \
  --apiKey [KEY_ID] \
  --apiIssuer [ISSUER_ID]
```

## 🔍 App Store Review Process

### 1. Submission Checklist
- ✅ App works on all supported devices
- ✅ All features function as described
- ✅ Privacy policy accessible and accurate
- ✅ No crashes or critical bugs
- ✅ Follows iOS Design Guidelines
- ✅ Proper use of Spotify and Apple Music APIs
- ✅ No promotional content in screenshots
- ✅ Age rating matches content (4+)

### 2. Common Rejection Reasons
- **Incomplete functionality**: All features must work
- **Design issues**: Must follow iOS guidelines
- **Privacy concerns**: Clear data usage explanation
- **API violations**: Proper use of platform APIs
- **Metadata mismatch**: Description must match functionality

### 3. Review Timeline
- **Standard Review**: 24-48 hours
- **Expedited Review**: 2-24 hours (limited usage)
- **Rejection Response**: Usually within 24 hours

## 📊 App Store Optimization (ASO)

### 1. App Store Keywords
Primary keywords to target:
- "playlist converter"
- "spotify to apple music"
- "music transfer"
- "playlist share"
- "music converter"

### 2. App Icon Design
- 1024x1024px for App Store
- No text overlays
- Clean, recognizable at small sizes
- Follows iOS icon guidelines

### 3. Screenshot Strategy
1. **Hero Screenshot**: Main conversion interface
2. **Share Extension**: Show iOS share sheet integration
3. **Conversion Progress**: Show the conversion process
4. **Results**: Display successful conversion
5. **Features**: Widget, Siri Shortcuts, Analytics

## 🔄 Post-Launch Maintenance

### 1. Version Updates
```bash
# Patch release (bug fixes)
fastlane bump_patch
fastlane release

# Minor release (new features)
fastlane bump_minor
fastlane release

# Major release (breaking changes)
fastlane bump_major
fastlane release
```

### 2. Monitoring
- **App Store Connect**: Downloads, revenue, ratings
- **Crashlytics**: Crash reports (if enabled)
- **Analytics**: User behavior insights
- **Support**: User feedback and issues

### 3. API Maintenance
- Monitor Spotify API changes
- Update Apple Music API usage
- Backend API compatibility
- Rate limit adjustments

## 🚨 Troubleshooting

### Common Build Issues
```bash
# Certificate issues
fastlane match nuke development
fastlane match nuke appstore
fastlane certificates

# Derived data corruption
rm -rf ~/Library/Developer/Xcode/DerivedData

# Provisioning profile issues  
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles
fastlane match development --force
```

### App Store Connect Issues
- **Processing stuck**: Wait 24 hours, then contact Apple
- **Missing compliance**: Submit encryption compliance
- **Invalid binary**: Check bundle ID and certificates
- **Metadata rejected**: Review App Store guidelines

### API Issues
- **Spotify rate limits**: Implement exponential backoff
- **Apple Music permissions**: Request proper entitlements
- **Backend connectivity**: Monitor API health endpoints

## 📞 Support & Resources

### Documentation
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- [Apple Music API](https://developer.apple.com/documentation/applemusicapi)
- [Fastlane Documentation](https://docs.fastlane.tools)

### Contact Information
- **Developer**: ayomideadekoya266@gmail.com
- **Support**: [LinkedIn](https://www.linkedin.com/in/elcruzo/)
- **GitHub**: [Repository Issues](https://github.com/elcruzo/aux/issues)

---

## 🎯 Quick Deploy Commands

```bash
# Full deployment pipeline
git checkout main
git pull origin main
./scripts/build-and-deploy.sh --full --bump-version patch

# Emergency hotfix
git checkout -b hotfix/critical-fix
# Make fixes
git commit -m "Fix critical issue"
git push origin hotfix/critical-fix
# Merge to main
./scripts/build-and-deploy.sh --app-store --skip-tests
```

**Ready to launch! 🚀**

The Aux iOS app is production-ready with comprehensive CI/CD, automated deployment, and App Store optimization.