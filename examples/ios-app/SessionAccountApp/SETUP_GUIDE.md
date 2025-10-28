# Session Account App - WebAuthn Setup Guide

This guide explains the changes made to support in-app WebAuthn/Passkeys and how to configure your Xcode project.

## Features Added

1. **In-App Web View** - Session authorization now happens in-app instead of external browser
2. **Background Subscription** - Session creation happens automatically in the background while user authorizes
3. **Beautiful Success Card** - A sliding card animation shows account connection details
4. **Auto Tab Switching** - After successful connection, user is automatically taken to the Execute tab

## Files Added

1. **`controller/controller/Views/SessionWebView.swift`** - WKWebView component with WebAuthn support
2. **`controller/controller/Views/AccountConnectedCard.swift`** - Animated success card component
3. **`controller/controller/SessionAccountApp.entitlements`** - Entitlements file for WebAuthn/Passkeys

## Files Modified

1. **`controller/controller/SessionManager.swift`** - Added background subscription and card display logic
2. **`controller/controller/Views/SetupView.swift`** - Updated to use in-app web view with "Register Session" button
3. **`controller/controller/SessionAccountView.swift`** - Integrated the success card with tab switching
4. **`Info.plist`** - Added Face ID usage description

## Xcode Project Configuration

### 1. Add New Files to Xcode

The new files have been added to your Xcode project in the correct location:

```
controller/controller/Views/
  └── SessionWebView.swift          (NEW)
  └── AccountConnectedCard.swift    (NEW)
controller/controller/
  └── SessionAccountApp.entitlements (NEW)
```

**Steps:**
1. Open Xcode
2. The files are already in the `controller/controller/Views/` directory
3. If they're not showing in Xcode, right-click on the Views folder
4. Select "Add Files to [Project]..."
5. Select the new files (SessionWebView.swift and AccountConnectedCard.swift)
6. Make sure "Copy items if needed" is **unchecked** (they're already there)
7. Ensure your target is selected

### 2. Configure Entitlements

The `SessionAccountApp.entitlements` file includes:

```xml
<key>com.apple.developer.web-browser</key>
<true/>
<key>com.apple.developer.associated-domains</key>
<array>
    <string>webcredentials:x.cartridge.gg</string>
    <string>webcredentials:cartridge.gg</string>
</array>
<key>com.apple.developer.authentication-services.autofill-credential-provider</key>
<true/>
```

**Steps to link entitlements:**
1. Select your project in Xcode
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+" to add capabilities:
   - Add "Associated Domains"
   - Add "AutoFill Credential Provider" (if available)
5. In the file inspector, set the entitlements file path to `SessionAccountApp.entitlements`

### 3. Associated Domains

In your target's "Signing & Capabilities" tab:

1. Under "Associated Domains", add:
   - `webcredentials:x.cartridge.gg`
   - `webcredentials:cartridge.gg`

This allows your app to work with WebAuthn credentials from these domains.

### 4. Info.plist

The Info.plist has been updated with:

```xml
<key>NSFaceIDUsageDescription</key>
<string>We use Face ID to securely authenticate your session with Cartridge</string>
```

This is required for biometric authentication with Passkeys.

## How It Works

### Flow

1. **User clicks "Authorize Session"**
   - Background subscription task starts
   - In-app web view opens with Cartridge Keychain URL

2. **User completes WebAuthn authorization**
   - User authenticates with Face ID/Touch ID
   - Authorization happens in the web view

3. **Background task receives session**
   - Session is created automatically
   - Web view closes automatically
   - Success card slides up

4. **User sees account details**
   - Username and public key displayed
   - User clicks "Continue to Execute"
   - App switches to Execute tab

### Key Components

**SessionManager:**
- `openSessionInWebView()` - Starts the flow
- `startBackgroundSubscription()` - Polls for session creation
- `cancelSubscription()` - Cancels if user dismisses

**SessionWebView:**
- WKWebView with WebAuthn support enabled
- Handles navigation and errors
- Automatically detects callback URLs

**AccountConnectedCard:**
- Beautiful sliding animation
- Shows username and public key
- Auto-switches to Execute tab on dismiss

## Testing

1. Run the app on a real device (Simulator has limited WebAuthn support)
2. Go to Setup tab
3. Add policies (or use default ETH transfer/approve)
4. Click "Authorize Session"
5. Complete authentication in the web view
6. Watch for automatic session creation and card appearance
7. Click "Continue to Execute" to go to Execute tab

## Troubleshooting

**Web view doesn't load:**
- Check that `NSAppTransportSecurity` allows arbitrary loads in Info.plist
- Verify the Keychain URL is correct

**WebAuthn doesn't work:**
- Ensure entitlements file is properly linked to target
- Check that Associated Domains are configured
- Test on a real device, not simulator

**Session doesn't create automatically:**
- Check network connectivity
- Verify RPC URL is correct
- Look for errors in the error alert

**Card doesn't appear:**
- Check that `showAccountConnectedCard` is being set to true
- Verify the main view has the ZStack with the card

## Security Notes

1. **Associated Domains** - Only works with domains you control and have proper server configuration
2. **Entitlements** - Must be properly signed with Apple Developer account
3. **WebAuthn** - Requires HTTPS and proper domain association
4. **Biometrics** - User must have Face ID/Touch ID enabled on device

## Next Steps

If you want to customize:

1. **Change domains:** Update entitlements and associated domains
2. **Customize card:** Edit `AccountConnectedCard.swift`
3. **Change animation:** Modify the spring animations in the card
4. **Add more info:** Extract additional data from `SessionAccount`

