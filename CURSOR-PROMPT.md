# CURSOR PROMPT — Exakt so in den Cursor Chat einfügen

---

Bitte lies zuerst die `.cursorrules` Datei in diesem Ordner vollständig durch.
Sie enthält alle Projekt-Infos, Tech-Stack und Qualitäts-Standards.

Dann führe folgende Schritte der Reihe nach aus:

---

## SCHRITT 1 — XcodeGen installieren und Projekt erstellen

Führe im Terminal aus:
```bash
brew install xcodegen
```

Dann im Projektordner:
```bash
xcodegen generate
```

Das erstellt das `.xcodeproj` automatisch aus der `project.yml`.
Wenn xcodegen noch nicht installiert ist, installiere es zuerst.
Wenn brew nicht installiert ist, führe zuerst aus:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## SCHRITT 2 — Ordnerstruktur erstellen

Erstelle exakt diese Ordner und leere Swift-Dateien:
```
OneTapSurvivor/
├── App/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Game/
│   ├── GameScene.swift
│   ├── Player.swift
│   ├── ObstacleManager.swift
│   └── PhysicsCategories.swift
├── UI/
│   ├── GameViewController.swift
│   ├── StartScreenView.swift
│   ├── GameOverlay.swift
│   └── DailyBonusView.swift
├── Ads/
│   └── AdManager.swift
├── Core/
│   ├── Constants.swift
│   ├── GameState.swift
│   └── Extensions.swift
└── Assets.xcassets/
    ├── Contents.json
    └── AppIcon.appiconset/
        └── Contents.json
```

---

## SCHRITT 3 — Alle Swift-Dateien vollständig befüllen

Befülle jede Datei vollständig, produktionsbereit, keine Platzhalter.
Reihenfolge wie in .cursorrules definiert.

Die App muss:
- Ohne Storyboard starten (AppDelegate setzt rootViewController)
- Ein SpriteKit Spiel mit einem-Tap-Mechanik haben
- Alle drei Rewarded-Ad-Momente implementieren
- UserDefaults Persistenz haben
- Game Center Leaderboard integrieren
- Im Debug-Modus Werbung simulieren
- Im Release echte AppLovin MAX Ads zeigen
- Das komplette Design-System aus .cursorrules verwenden

---

## SCHRITT 4 — Info.plist erstellen

Mit allen Keys laut .cursorrules:
- ATT Usage Description (Deutsch)
- AppLovin SDK Key Placeholder
- SKAdNetwork Items (alle 8 Netzwerke)
- Portrait only
- Status Bar hidden
- Game Center

---

## SCHRITT 5 — Assets.xcassets befüllen

Erstelle:
- `AppIcon.appiconset/Contents.json` mit allen required sizes
- `AccentColor.colorset/Contents.json` mit Farbe #00E5FF

---

## SCHRITT 6 — Projekt bauen und Fehler beheben

Führe aus:
```bash
xcodebuild \
  -scheme OneTapSurvivor \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build 2>&1 | tail -50
```

Alle Build-Fehler sofort beheben ohne nachzufragen.

---

## SCHRITT 7 — Abschlussbericht

Wenn alles kompiliert, sage mir:
1. ✅ Projekt kompiliert erfolgreich
2. 📝 Welche Keys ich in Constants.swift eintragen muss
3. 🔑 Wo ich mein Apple Developer Team eintragen muss
4. 📱 Wie ich auf dem Simulator teste (Cmd+R in Xcode)
5. 🚀 Nächste Schritte für App Store Upload

---

Fang jetzt mit Schritt 1 an. Arbeite die Schritte der Reihe nach ab.
Bei Problemen löse sie selbst ohne zu fragen — außer du brauchst
einen API-Key oder Account-Zugang von mir.
