# One Tap Survivor — Setup-Anleitung
**Von Code zu echtem Geld in ca. 2 Stunden**

---

## Was du bekommst

| Datei | Inhalt |
|---|---|
| `GameScene.swift` | Komplettes SpriteKit-Spiel |
| `GameViewController.swift` | UI, Overlays, Game Flow |
| `AdManager.swift` | AppLovin MAX Integration |
| `Constants.swift` | Deine Keys (hier eintragen) |
| `AppDelegate.swift` | App-Start, GameCenter |
| `Info.plist` | ATT, SKAdNetwork, Permissions |

---

## SCHRITT 1 — Xcode-Projekt erstellen (5 Min)

1. Xcode öffnen → "Create New Project"
2. iOS → App
3. **Product Name:** `One Tap Survivor`
4. **Bundle Identifier:** `eu.design-code.OneTapSurvivor`
5. **Interface:** Storyboard (dann löschen wir es)
6. **Language:** Swift
7. Speichern in deinem Projektordner

8. **Storyboard löschen:**
   - `Main.storyboard` → Delete → Move to Trash
   - In `Info.plist`: Eintrag `Main storyboard file base name` löschen
   - In Xcode: Target → Info → Main storyboard file... → Wert löschen

9. **Alle `.swift`-Dateien** aus diesem Ordner in dein Xcode-Projekt ziehen
   (Copy items if needed = ✓)

10. Die alte `ContentView.swift` und `ViewController.swift` löschen

---

## SCHRITT 2 — AppLovin MAX SDK einbinden (3 Min)

In Xcode:
1. File → Add Package Dependencies
2. URL eingeben: `https://github.com/AppLovin/AppLovin-MAX-Swift-Package`
3. Version: `12.0.0` oder höher
4. Produkt: `AppLovinSDK` → Add to Target: `OneTapSurvivor`

---

## SCHRITT 3 — AppLovin Account + Keys (10 Min)

### Account anlegen
1. https://dash.applovin.com → Sign Up (kostenlos)
2. "Add New App" → iOS → Bundle ID: `eu.design-code.OneTapSurvivor`

### SDK Key holen
- Dashboard → Account → Keys → SDK Key kopieren
- In `Constants.swift` eintragen: `maxSdkKey`
- Auch in `Info.plist` bei `AppLovinSdkKey`

### Rewarded Ad Unit erstellen
- Dashboard → MAX → Ad Units → Create Ad Unit
- Format: **Rewarded**
- Deine App auswählen
- Ad Unit ID kopieren → in `Constants.swift` bei `maxRewardedAdUnitID`

### Mediation Networks (empfohlen für höhere eCPMs)
In AppLovin Dashboard → Mediation → Manage Networks:
- Google AdMob aktivieren → eigene AdMob App-ID eintragen
- Meta Audience Network aktivieren
- Unity Ads aktivieren
- Vungle aktivieren

Jedes aktive Netzwerk = höherer Wettbewerb = mehr Geld pro Ad.

---

## SCHRITT 4 — App Store Connect einrichten (15 Min)

1. https://appstoreconnect.apple.com
2. "My Apps" → + → New App
3. **Name:** One Tap Survivor
4. **Bundle ID:** eu.design-code.OneTapSurvivor
5. **SKU:** OneTapSurvivor2024
6. Primary Language: Deutsch

### Game Center aktivieren
- App Store Connect → App → Features → Game Center → Enable
- Leaderboard hinzufügen:
  - ID: `ots.highscore`
  - Name: Highscore
  - Score Format: Integer (aufsteigend → Höher ist besser)

### Capabilities in Xcode
- Target → Signing & Capabilities → + Capability
- "Game Center" hinzufügen

---

## SCHRITT 5 — App bauen & testen (10 Min)

1. Xcode → Simulator oder echtes iPhone auswählen
2. `Cmd + R` → Build & Run
3. Spiel testen — Werbung läuft im DEBUG-Modus simuliert

**Release Build:**
1. Xcode → Product → Archive
2. Distribute App → App Store Connect
3. Upload

---

## SCHRITT 6 — App Store Listing (30 Min)

App Store Connect → App → App Information:

| Feld | Empfehlung |
|---|---|
| Name | One Tap Survivor |
| Subtitle | Wie weit kommst du? |
| Keywords | hyper casual, endless, tap, runner, highscore, reaktion |
| Beschreibung | siehe unten |
| Kategorie | Games → Action |

### Beschreibung (DE)
```
Wie weit kannst du kommen?

One Tap Survivor ist das süchtig machende Reaktionsspiel,
das du mit einem einzigen Finger spielst.

• Tap zum Springen — einfacher geht's nicht
• Hindernisse werden schneller und tückischer
• Schlag deinen eigenen Highscore
• Tritt gegen Spieler weltweit an
• Hole deinen täglichen Bonus ab

Kostenlos spielen. Kein Abo. Keine versteckten Kosten.
Werbung nur wenn du es willst — und bekommst dafür Belohnungen.
```

### Screenshots
- Minimum 3 Screenshots für iPhone 6.7"
- App auf echtem Gerät / Simulator aufnehmen
- In App Store Connect hochladen

---

## Google Play Store (Android — später)

Für Android brauchst du:
- Unity oder React Native für Cross-Platform
- Oder: der aktuelle Code läuft nur auf iOS

Empfehlung: erst iOS launchen, dann Android via Unity portieren.

---

## Umsatz realistisch einschätzen

| Downloads/Monat | Annahmen | Umsatz/Monat |
|---|---|---|
| 500 | 2 Ads/Session, 30% Ad-Rate, eCPM 12€ | ~36 € |
| 5.000 | gleiche Annahmen | ~360 € |
| 50.000 | gleiche Annahmen | ~3.600 € |

**Marketing ist der entscheidende Faktor.**
Ohne aktive User Acquisition (TikTok-Videos, Instagram Reels,
bezahlte Kampagnen) bleibst du unter 500 Downloads.

---

## Support-Kontakt AppLovin

- Docs: https://developers.applovin.com
- Dashboard: https://dash.applovin.com
- Support: support@applovin.com

Auszahlung: monatlich via PayPal oder Banküberweisung,
Mindestbetrag 50 USD.
