#!/bin/bash
# Builds Arrival for macOS as a universal (Apple Silicon + Intel) app, signs and
# notarizes it, and packages it as dist/Arrival.dmg.
#
# Prerequisites:
#   - Developer ID Application certificate in the keychain
#   - notarytool credentials stored as the keychain profile "notarytool"
#     (override with NOTARY_PROFILE)
#
# Usage: ./scripts/build-dmg.sh
set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="Arrival"
SIGN_IDENTITY="${SIGN_IDENTITY:-Developer ID Application: Santiago Alonso Alexandre (QAMM2A6WRQ)}"
NOTARY_PROFILE="${NOTARY_PROFILE:-notarytool}"
DIST="dist"
APP="$DIST/$APP_NAME.app"
DMG="$DIST/$APP_NAME.dmg"

echo "==> Building universal release binary"
swift build -c release --arch arm64 --arch x86_64
BIN_DIR="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)"

echo "==> Assembling $APP"
rm -rf "$DIST"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN_DIR/$APP_NAME" "$APP/Contents/MacOS/$APP_NAME"
cp Sources/Arrival/Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
# The station list ships in SwiftPM's resource bundle; StationStore looks for it here
cp -R "$BIN_DIR/${APP_NAME}_${APP_NAME}.bundle" "$APP/Contents/Resources/"

echo "==> Architectures: $(lipo -archs "$APP/Contents/MacOS/$APP_NAME")"

# Embed Sparkle, the in-app updater. ditto keeps the framework's symlinks intact.
mkdir -p "$APP/Contents/Frameworks"
ditto "$BIN_DIR/Sparkle.framework" "$APP/Contents/Frameworks/Sparkle.framework"

echo "==> Signing app"
# Sparkle's nested code inside-out first, then the app, without --deep.
FW="$APP/Contents/Frameworks/Sparkle.framework"
codesign -f -o runtime --timestamp -s "$SIGN_IDENTITY" "$FW/Versions/B/XPCServices/Installer.xpc"
codesign -f -o runtime --timestamp --preserve-metadata=entitlements -s "$SIGN_IDENTITY" "$FW/Versions/B/XPCServices/Downloader.xpc"
codesign -f -o runtime --timestamp -s "$SIGN_IDENTITY" "$FW/Versions/B/Autoupdate"
codesign -f -o runtime --timestamp -s "$SIGN_IDENTITY" "$FW/Versions/B/Updater.app"
codesign -f -o runtime --timestamp -s "$SIGN_IDENTITY" "$FW"
codesign --force --options runtime --timestamp --sign "$SIGN_IDENTITY" "$APP"
codesign --verify --deep --strict "$APP"

echo "==> Creating DMG"
STAGING="$(mktemp -d)"
cp -R "$APP" "$STAGING/"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname "$APP_NAME" -srcfolder "$STAGING" -ov -format UDZO "$DMG" > /dev/null
rm -rf "$STAGING"

echo "==> Signing and notarizing DMG"
codesign --force --timestamp --sign "$SIGN_IDENTITY" "$DMG"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
spctl -a -t open --context context:primary-signature "$DMG"

echo "==> Done: $DMG"
