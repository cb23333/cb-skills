# Deployment Guide

Platform-specific build and deployment instructions.

## Table of Contents
1. [Pre-Build Checklist](#pre-build-checklist)
2. [Android Build & Deploy](#android-build--deploy)
3. [iOS Build & Deploy](#ios-build--deploy)
4. [App Icons & Splash Screen](#app-icons--splash-screen)
5. [Version Management](#version-management)

---

## Pre-Build Checklist

Before building for release, verify:

- [ ] `flutter doctor` shows no errors
- [ ] All tests pass: `flutter test`
- [ ] No print/debug statements in production code
- [ ] API base URL points to production endpoint
- [ ] App version and build number are updated in pubspec.yaml
- [ ] Permissions are correctly declared in platform configs
- [ ] ProGuard/R8 rules are set (Android)
- [ ] App icon and splash screen are configured

---

## Android Build & Deploy

### Configure Signing

1. Create a keystore:
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

3. Update `android/app/build.gradle`:
```gradle
// Add before android { block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### Update App Name

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="My App Name"
    android:icon="@mipmap/ic_launcher">
```

### Build

```bash
# Android App Bundle (for Play Store)
flutter build appbundle --release

# APK (for direct distribution)
flutter build apk --release

# Split per ABI (smaller APKs)
flutter build apk --split-per-abi --release
```

Output locations:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### Required Permissions

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<!-- Add others as needed -->
```

---

## iOS Build & Deploy

### Configure in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner target → Signing & Capabilities
3. Set your Team and Bundle Identifier
4. Set the app version and build number

### Update App Name

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>My App Name</string>
<key>CFBundleDisplayName</key>
<string>My App Name</string>
```

### Build

```bash
# Build IPA
flutter build ipa --release

# Or archive through Xcode for more control
open ios/Runner.xcworkspace
# Then: Product → Archive → Distribute App
```

Output: `build/ios/ipa/my_app.ipa`

### Required Permissions

Edit `ios/Runner/Info.plist`:
```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select photos.</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to show nearby places.</string>
```

---

## App Icons & Splash Screen

### App Icon

Use `flutter_launcher_icons` package:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.0

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  # Optional: adaptive icon for Android
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

Run:
```bash
dart run flutter_launcher_icons
```

### Splash Screen

Use `flutter_native_splash`:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_native_splash: ^2.3.0

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/icon/splash_logo.png
  android_12:
    image: assets/icon/splash_logo_android12.png
```

Run:
```bash
dart run flutter_native_splash:create
```

---

## Version Management

Version is set in `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

- `1.0.0` is the user-facing version
- `+1` is the build number (must increment for each upload to stores)

Update before each release:
```yaml
version: 1.0.1+2  # Bug fix
version: 1.1.0+3  # New feature
version: 2.0.0+4  # Major update
```
