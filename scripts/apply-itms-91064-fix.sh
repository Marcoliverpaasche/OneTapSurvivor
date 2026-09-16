#!/bin/bash
# Bringt das Desktop-Projekt auf den ITMS-91064-Fix — ohne GitHub/Xcode-Git.
set -euo pipefail
ROOT="${1:-$HOME/Desktop/OneTapSurvivor}"
cd "$ROOT"
echo "→ Ordner: $ROOT"

cat > OneTapSurvivor/PrivacyInfo.xcprivacy <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<false/>
	<key>NSPrivacyTrackingDomains</key>
	<array/>
	<key>NSPrivacyCollectedDataTypes</key>
	<array>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeDeviceID</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<false/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<false/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeThirdPartyAdvertising</string>
			</array>
		</dict>
	</array>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>CA92.1</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
PLIST

if [[ -f project.yml ]]; then
  sed -i '' 's/CURRENT_PROJECT_VERSION: ".*"/CURRENT_PROJECT_VERSION: "6"/' project.yml
fi
if [[ -f OneTapSurvivor.xcodeproj/project.pbxproj ]]; then
  sed -i '' 's/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = 6;/g' OneTapSurvivor.xcodeproj/project.pbxproj
fi

echo "→ NSPrivacyTracking:"
grep -A1 'NSPrivacyTracking</key>' OneTapSurvivor/PrivacyInfo.xcprivacy | head -2
echo "→ Build:"
grep CURRENT_PROJECT_VERSION OneTapSurvivor.xcodeproj/project.pbxproj | sort -u
echo "Fertig. Xcode: Clean Build Folder → Archive (Build 6) → Upload."
