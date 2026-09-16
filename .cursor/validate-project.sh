#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# One Tap Survivor — Linux-seitige Projekt-Validierung
# ─────────────────────────────────────────────────────────────
# Die eigentliche iOS-App (SpriteKit/UIKit/GameKit + AppLovin SDK)
# kann NUR unter macOS mit Xcode/XcodeGen gebaut werden.
# Auf dem Linux-Cloud-Agent prüfen wir daher nur, dass alle
# Projekt-Artefakte strukturell gültig und vollständig sind.
# Dieses Skript ist idempotent und ohne Seiteneffekte.
set -euo pipefail

cd "$(dirname "$0")/.."
echo "== One Tap Survivor: Projekt-Validierung (Linux) =="

fail=0

# 1) Asset-Kataloge (JSON) validieren
while IFS= read -r f; do
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$f" 2>/dev/null; then
    echo "OK   json    $f"
  else
    echo "FEHLER json  $f"; fail=1
  fi
done < <(find OneTapSurvivor/Assets.xcassets -name '*.json')

# 2) plist-artige Dateien validieren
for f in OneTapSurvivor/Info.plist \
         OneTapSurvivor/OneTapSurvivor.entitlements \
         OneTapSurvivor/PrivacyInfo.xcprivacy; do
  if python3 -c "import plistlib,sys; plistlib.load(open(sys.argv[1],'rb'))" "$f" 2>/dev/null; then
    echo "OK   plist   $f"
  else
    echo "FEHLER plist $f"; fail=1
  fi
done

# 3) Pflicht-Quelldateien vorhanden?
for f in \
  OneTapSurvivor/App/AppDelegate.swift \
  OneTapSurvivor/App/SceneDelegate.swift \
  OneTapSurvivor/Game/GameScene.swift \
  OneTapSurvivor/Game/Player.swift \
  OneTapSurvivor/Game/ObstacleManager.swift \
  OneTapSurvivor/Game/PhysicsCategories.swift \
  OneTapSurvivor/UI/GameViewController.swift \
  OneTapSurvivor/UI/StartScreenView.swift \
  OneTapSurvivor/UI/GameOverlay.swift \
  OneTapSurvivor/UI/DailyBonusView.swift \
  OneTapSurvivor/Ads/AdManager.swift \
  OneTapSurvivor/Core/Constants.swift \
  OneTapSurvivor/Core/GameState.swift \
  OneTapSurvivor/Core/Extensions.swift \
  project.yml; do
  if [ -f "$f" ]; then echo "OK   datei   $f"; else echo "FEHLER fehlt  $f"; fail=1; fi
done

# 4) AppIcon 1024x1024?
python3 - <<'PY' || fail=1
import struct
d = open('OneTapSurvivor/Assets.xcassets/AppIcon.appiconset/AppIcon.png','rb').read()
w,h = struct.unpack('>II', d[16:24])
assert (w,h) == (1024,1024), f"AppIcon muss 1024x1024 sein, ist {w}x{h}"
print(f"OK   icon    AppIcon.png {w}x{h}")
PY

if [ "$fail" -ne 0 ]; then
  echo "== Validierung FEHLGESCHLAGEN =="
  exit 1
fi
echo "== Validierung erfolgreich =="
