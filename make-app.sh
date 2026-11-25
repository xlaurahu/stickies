#!/bin/bash
set -e   # stop if anything fails

APP="Laura's Stickies.app"

# 1. Build the finished version
swift build -c release

# 2. Make the app folder layout
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# 3. Copy the program (and any resource bundles) inside
cp .build/release/StickyNotes "$APP/Contents/MacOS/StickyNotes"
for b in .build/release/*.bundle; do
  [ -e "$b" ] && cp -R "$b" "$APP/Contents/Resources/"
done

# 3b. Make the app icon from LH.png
mkdir -p AppIcon.iconset
for s in 16 32 128 256 512; do
  sips -z $s $s LH.png --out AppIcon.iconset/icon_${s}x${s}.png > /dev/null
  d=$((s*2))
  sips -z $d $d LH.png --out AppIcon.iconset/icon_${s}x${s}@2x.png > /dev/null
done
iconutil -c icns AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf AppIcon.iconset

# 4. Write the Info.plist (the app's "ID card")
cat > "$APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>             <string>Laura's Stickies</string>
  <key>CFBundleDisplayName</key>      <string>Laura's Stickies</string>
  <key>CFBundleExecutable</key>       <string>StickyNotes</string>
  <key>CFBundleIdentifier</key>       <string>com.laurahu.stickies</string>
  <key>CFBundlePackageType</key>      <string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleVersion</key>          <string>1</string>
  <key>LSMinimumSystemVersion</key>   <string>15.0</string>
  <key>NSHighResolutionCapable</key>  <true/>
  <key>NSPrincipalClass</key>         <string>NSApplication</string>
  <key>CFBundleIconFile</key>         <string>AppIcon</string>
</dict>
</plist>
EOF

# 5. Give it a free "ad-hoc" signature so macOS will run it
codesign --force --deep --sign - "$APP"

echo "Done! Made $APP"