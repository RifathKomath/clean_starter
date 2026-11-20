# GoByPlan - Deep Links & App Links Guide (Android & iOS)

This guide provides end-to-end documentation for running, verifying, and deploying **Android App Links** and **iOS Universal Links** for GoByPlan.

---

## 1. Supported URL Formats

All deep links are standard, secure HTTPS URLs. They can be shared through **WhatsApp**, **Telegram**, **SMS**, **Email**, **Chrome**, **Safari**, etc., and will open the Flutter application directly if installed.

| Destination | Link Pattern | Auth Required? | Screen Routed to |
| :--- | :--- | :---: | :--- |
| **Activity / Venue** | `https://<DOMAIN>/activity/{id}` | No | `QuickBookVenueDetailsScreen` |
| **Vendor** | `https://<DOMAIN>/vendor/{id}` | No | `QuickBookVenueDetailsScreen` |
| **Venue Alias** | `https://<DOMAIN>/venue/{id}` | No | `QuickBookVenueDetailsScreen` |
| **Combo Deals** | `https://<DOMAIN>/combo/{id}` | No | `ComboDetailsScreen` |
| **Booking Detail** | `https://<DOMAIN>/booking/{id}` | **Yes** | `BookingDetailScreen` |
| **User Plans** | `https://<DOMAIN>/plans` or `/my-plans` | **Yes** | `MyPlansScreen` |
| **Notifications** | `https://<DOMAIN>/notifications` | **Yes** | `NotificationsScreen` |
| **Explore Map** | `https://<DOMAIN>/explore` or `/map` | No | `ExploreMapScreen` |

> [!NOTE]
> Deep links also support queries with parameters, e.g. `https://<DOMAIN>/activity?id=123`.

---

## 2. Authentication Protection & Resume Workflow

If an unauthenticated (logged-out) user taps an authentication-required deep link (such as `/booking/123` or `/plans`):
1. `DeepLinkService` intercepts the deep link.
2. Checks session token via `TokenService.getAccessToken()`.
3. If no token is found, the deep link is preserved in memory as `_pendingDeepLink`.
4. The user is navigated to `AppRoutes.login` with a polite toast (*"Please sign in to view this content"*).
5. Once the user completes OTP verification or Google login:
   - `resumePendingDeepLink()` is called.
   - The user is seamlessly navigated to their target destination (e.g. Booking #123) instead of being dumped on the home screen!

---

## 3. Android App Links Configuration

### 3.1 AndroidManifest.xml
Configured under `<activity android:name=".MainActivity">`:
- `android:autoVerify="true"`: instructs the Android OS to verify ownership of the domain via `assetlinks.json`.
- `android:launchMode="singleTop"`: prevents duplicate instances of the app when tapping links while the app is active in background or foreground.
- Filter:
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" />
    <data android:host="gobyplan.com" />
    <data android:host="www.gobyplan.com" />
    <!-- Path Prefixes -->
    <data android:pathPrefix="/activity" />
    <data android:pathPrefix="/vendor" />
    <data android:pathPrefix="/venue" />
    <data android:pathPrefix="/combo" />
    <data android:pathPrefix="/booking" />
    <data android:pathPrefix="/plans" />
    <data android:pathPrefix="/my-plans" />
    <data android:pathPrefix="/notifications" />
    <data android:pathPrefix="/explore" />
    <data android:pathPrefix="/map" />
</intent-filter>
```

### 3.2 Digital Asset Links (`assetlinks.json`)
The file is located at `server/.well-known/assetlinks.json` and must be hosted at:
```
https://<DOMAIN>/.well-known/assetlinks.json
```

It must contain:
```json
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "com.gobyplan.app",
      "sha256_cert_fingerprints": [
        "72:AF:A7:69:60:35:A3:66:DA:12:53:6E:09:EC:C0:FF:59:5D:64:7D:09:5B:F8:E1:34:D9:99:4C:2F:61:42:C7",
        "<REPLACE_WITH_PRODUCTION_RELEASE_SHA256_FINGERPRINT>"
      ]
    }
  }
]
```

### 3.3 How to Obtain SHA-256 Fingerprints

#### A. Local Debug Keystore (already included above):
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Fingerprint: `72:AF:A7:69:60:35:A3:66:DA:12:53:6E:09:EC:C0:FF:59:5D:64:7D:09:5B:F8:E1:34:D9:99:4C:2F:61:42:C7`

#### B. Production Release Keystore:
```bash
keytool -list -v -keystore /path/to/your/release-keystore.jks -alias your-key-alias
```
Copy the **SHA256** value and add it to `assetlinks.json`.

#### C. If using Google Play App Signing (Recommended for Play Store):
1. Open the [Google Play Console](https://play.google.com/console).
2. Select **GoByPlan** -> **Release** -> **Setup** -> **App Integrity**.
3. Under **App signing key certificate**, copy the **SHA-256 certificate fingerprint**.
4. Paste it into `assetlinks.json`.

### 3.4 Android App Link Verification Command
Test domain verification on a connected device or emulator:
```bash
adb shell pm get-app-links com.gobyplan.app
```
To force verification:
```bash
adb shell pm verify-app-links --re-verify com.gobyplan.app
```

---

## 4. iOS Universal Links Configuration

### 4.1 Associated Domains Entitlement
Configured in `ios/Runner/Runner.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.associated-domains</key>
    <array>
        <string>applinks:gobyplan.com</string>
        <string>applinks:www.gobyplan.com</string>
    </array>
</dict>
</plist>
```
`ios/Runner.xcodeproj/project.pbxproj` is configured with:
```
CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
```

### 4.2 Apple App Site Association (`apple-app-site-association`)
The file is located at `server/.well-known/apple-app-site-association` and must be hosted at:
```
https://<DOMAIN>/.well-known/apple-app-site-association
```

Content:
```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appIDs": [
          "<APPLE_TEAM_ID>.com.gobyplan.app"
        ],
        "appID": "<APPLE_TEAM_ID>.com.gobyplan.app",
        "paths": [
          "/activity/*",
          "/vendor/*",
          "/venue/*",
          "/combo/*",
          "/booking/*",
          "/plans*",
          "/my-plans*",
          "/notifications*",
          "/explore*",
          "/map*"
        ],
        "components": [
          {
            "/": "/activity/*",
            "comment": "Matches activity and venue detail deep links"
          },
          {
            "/": "/vendor/*",
            "comment": "Matches vendor detail deep links"
          },
          {
            "/": "/combo/*",
            "comment": "Matches combo deals deep links"
          },
          {
            "/": "/booking/*",
            "comment": "Matches booking details (auth protected)"
          },
          {
            "/": "/plans*",
            "comment": "Matches user plans (auth protected)"
          },
          {
            "/": "/notifications*",
            "comment": "Matches notifications (auth protected)"
          },
          {
            "/": "/explore*",
            "comment": "Matches explore map"
          }
        ]
      }
    ]
  }
}
```

### 4.3 How to Obtain Apple Team ID
1. Log in to [Apple Developer Member Center](https://developer.apple.com/account).
2. Go to **Membership Details** (or top right under your account name).
3. Copy the 10-character **Team ID** (e.g. `9ABC123XYZ`).
4. Replace `<APPLE_TEAM_ID>` in `apple-app-site-association`.

---

## 5. Web & Store Fallback Server Setup

When the user taps a link on a device where GoByPlan is **not installed**, the server serves the responsive landing page at `server/fallback/index.html`.

### Fallback Characteristics:
1. **WhatsApp Rich Link Previews**: Contains standard Open Graph meta tags (`og:title`, `og:description`, `og:image`, `og:url`) so sharing in WhatsApp, Telegram, or iMessage renders a rich interactive card with app branding.
2. **Platform Store Detection**:
   - iOS visitors get an automatic prompt / button to the **Apple App Store**.
   - Android visitors get an automatic prompt / button to the **Google Play Store**.
3. **Smart In-App Launch**: Tries opening `gobyplan://` if supported; falls back to the app store if the app doesn't launch within 1.8 seconds.

### Server Requirements:
- Served over valid HTTPS (valid SSL certificate required).
- No redirects on `.well-known` URLs (must return HTTP `200 OK`).
- `Content-Type: application/json` for both `assetlinks.json` and `apple-app-site-association`.

---

## 6. Testing Checklist

### 6.1 Android Testing (via ADB)
```bash
# 1. Cold start (app terminated)
adb shell am start -a android.intent.action.VIEW -d "https://gobyplan.com/activity/123" com.gobyplan.app

# 2. Protected route when logged out (verifies login prompt + resume)
adb shell am start -a android.intent.action.VIEW -d "https://gobyplan.com/booking/456" com.gobyplan.app

# 3. Background/foreground test
# Open the app, press home, then run:
adb shell am start -a android.intent.action.VIEW -d "https://gobyplan.com/combo/78" com.gobyplan.app
```

### 6.2 iOS Testing (via Simulator / Device)
```bash
# Test opening deep link on iOS Simulator
xcrun simctl openurl booted "https://gobyplan.com/activity/123"
```

### 6.3 Real-World App Testing (WhatsApp / Telegram / SMS / Email)
1. Send `https://gobyplan.com/activity/123` via WhatsApp to your device.
2. **App Installed**: Tap link. Verify app opens directly without showing a web browser prompt.
3. **App Not Installed**: Tap link. Verify fallback page opens with button to Google Play or App Store.
4. **Login test**: Tap `https://gobyplan.com/booking/99`. Verify login screen appears, complete login, verify booking 99 loads automatically.
