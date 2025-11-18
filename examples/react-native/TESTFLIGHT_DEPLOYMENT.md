# 📱 TestFlight Deployment Guide

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Sign up at https://developer.apple.com
   - Make sure your account is active

2. **Expo Account**
   - Sign up at https://expo.dev if you haven't already

## Step-by-Step Guide

### 1. Install EAS CLI

```bash
npm install -g eas-cli
```

### 2. Login to Expo

```bash
eas login
```

### 3. Configure Your App

**Update `app.json`:**
- Replace `YOUR_EXPO_USERNAME` with your Expo username
- Make sure your `bundleIdentifier` is unique: `com.arcadenative` (or change it)

**Update `eas.json`:**
- Replace `YOUR_APPLE_ID@example.com` with your Apple ID email
- You'll get `YOUR_ASC_APP_ID` and `YOUR_TEAM_ID` in later steps

### 4. Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **Apps** → **+** (Add button)
3. Fill in:
   - **Name**: Arcade Native
   - **Primary Language**: English
   - **Bundle ID**: Select or create `com.arcadenative`
   - **SKU**: Can be anything (e.g., `arcade-native-001`)
   - **User Access**: Full Access
4. Click **Create**
5. Note down your **App ID** (you'll see it in the URL: `https://appstoreconnect.apple.com/apps/YOUR_APP_ID`)

### 5. Get Your Team ID

1. Go to https://developer.apple.com/account
2. Click **Membership** in the sidebar
3. Copy your **Team ID** (10-character alphanumeric)

### 6. Update `eas.json` with Real Values

Replace in the `submit.production.ios` section:
```json
"appleId": "your-real-email@example.com",
"ascAppId": "YOUR_APP_ID_FROM_STEP_4",
"appleTeamId": "YOUR_TEAM_ID_FROM_STEP_5"
```

### 7. Configure Your Project

```bash
eas build:configure
```

This will:
- Link your project to your Expo account
- Generate iOS credentials if needed

### 8. Build for TestFlight (Production)

```bash
# Build the iOS app for App Store/TestFlight
eas build --platform ios --profile production
```

This will:
- Ask you to create/reuse certificates and provisioning profiles
- Upload your code to Expo's build servers
- Build your iOS app (~15-30 minutes)
- Give you a download link when complete

**Choose:**
- **Let Expo handle certificates** (recommended for first time)
- Or **Use existing credentials** if you have them

### 9. Wait for Build to Complete

You can monitor the build:
- On the terminal (it will show progress)
- On Expo dashboard: https://expo.dev/accounts/YOUR_USERNAME/projects/arcade-native/builds

### 10. Submit to TestFlight

Once the build is complete:

```bash
# Automatically submit to TestFlight
eas submit --platform ios --latest
```

Or manually:
1. Download the `.ipa` file from the Expo build page
2. Use **Transporter** app (Mac App Store) to upload
3. Upload the `.ipa` to App Store Connect

### 11. Configure TestFlight in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click your app → **TestFlight** tab
3. Wait for "Processing" to complete (~5-30 minutes)
4. Once processed:
   - Add **Test Information** (What to test, feedback email, etc.)
   - Add **Internal Testers** (up to 100 people)
   - Or create **External Test Group** (up to 10,000 people)

### 12. Distribute to Testers

**Internal Testing** (immediate, no review):
1. Go to **TestFlight** → **Internal Testing**
2. Click **+** next to testers
3. Add testers by email
4. They'll receive an email with TestFlight link

**External Testing** (requires Apple review, ~24 hours):
1. Go to **TestFlight** → **External Testing**
2. Create a test group
3. Add build to the group
4. Submit for review
5. Once approved, add testers

### 13. Testers Install the App

Testers need to:
1. Install **TestFlight** from App Store
2. Click the invitation link from their email
3. Accept the invitation
4. Install your app

## Quick Commands Reference

```bash
# Build for TestFlight
eas build --platform ios --profile production

# Submit to TestFlight
eas submit --platform ios --latest

# Check build status
eas build:list

# View build logs
eas build:view BUILD_ID

# Update with new version
# 1. Increment version in app.json
# 2. Run build command again
eas build --platform ios --profile production
```

## Troubleshooting

### "Bundle identifier is already in use"
Change the `bundleIdentifier` in `app.json` to something unique:
```json
"bundleIdentifier": "com.yourcompany.arcade"
```

### "Missing required icon"
Make sure `./assets/icon.png` exists and is 1024x1024px

### "Build failed"
Check the build logs:
```bash
eas build:view BUILD_ID
```

### "Processing stuck"
In App Store Connect, if processing takes more than 1 hour:
- Check if there are any warnings/errors
- Try uploading again

## Updating Your App

When you make changes and want to release a new version:

1. Update version in `app.json`:
   ```json
   "version": "1.0.1"
   ```

2. Build and submit:
   ```bash
   eas build --platform ios --profile production
   eas submit --platform ios --latest
   ```

3. TestFlight will automatically notify testers of the new build

## Auto-Increment Build Numbers

The `eas.json` has `"autoIncrement": true` which automatically increments the build number each time, so you only need to update the version number manually when releasing major/minor updates.

## Cost & Limits

- **Apple Developer Account**: $99/year
- **Expo Build Service**: Free tier includes limited builds per month
  - Paid plans available for more builds
- **TestFlight**: Free, up to 10,000 external testers
- **Internal Testing**: Up to 100 testers, no Apple review needed

## Resources

- [Expo EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [Expo Submit Documentation](https://docs.expo.dev/submit/introduction/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [App Store Connect](https://appstoreconnect.apple.com)


