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

> Hinweis: Wenn du das Projekt mit `xcodegen generate` erzeugst, sind
> **beide** Pakete bereits in `project.yml` deklariert und werden von Xcode
> automatisch aufgelöst. Die manuellen Schritte unten sind nur nötig, wenn du
> das Projekt ohne XcodeGen aufsetzt.

In Xcode:
1. File → Add Package Dependencies
2. URL eingeben: `https://github.com/AppLovin/AppLovin-MAX-Swift-Package`
3. Version: `13.0.0` oder höher
4. Produkt: `AppLovinSDK` → Add to Target: `OneTapSurvivor`

Zusätzlich für den GDPR-Consent-Flow (Google UMP) — **Pflicht in DE/EU**:
1. File → Add Package Dependencies
2. URL: `https://github.com/googleads/swift-package-manager-google-user-messaging-platform`
3. Version: `2.3.0` oder höher
4. Produkt: `UserMessagingPlatform` → Add to Target: `OneTapSurvivor`

---

## SCHRITT 3 — AppLovin Account + Keys (10 Min)

### Account anlegen
1. https://dash.applovin.com → Sign Up (kostenlos)
2. "Add New App" → iOS → Bundle ID: `eu.design-code.OneTapSurvivor`

### SDK Key holen
- Dashboard → Account → Keys → SDK Key kopieren
- In `Constants.swift` eintragen: `maxSdkKey`
- **Nur noch hier** — seit AppLovin SDK v12+/v13 wird der Key ausschließlich
  im Code (`ALSdkInitializationConfiguration`) genutzt. Der frühere
  `AppLovinSdkKey`-Eintrag in der `Info.plist` ist nicht mehr nötig und wurde
  entfernt.

### Rewarded Ad Unit erstellen
- Dashboard → MAX → Ad Units → Create Ad Unit
- Format: **Rewarded**
- Deine App auswählen (Bundle `eu.design-code.OneTapSurvivor`,
  App-Store-ID `6811169822`)
- Ad Unit ID kopieren → in `Constants.swift` bei `maxRewardedAdUnitID`

### Mediation Networks (später, für höhere eCPMs — optional)
Aktuell läuft die App mit **AppLovin Exchange** (kein Extra-Adapter nötig).
Für mehr Umsatz später in AppLovin Dashboard → Mediation → Manage Networks
weitere Netzwerke (AdMob, Meta, Unity, Vungle …) aktivieren und die
jeweiligen Adapter-Pakete einbinden. Jedes zusätzliche Netzwerk, das du
aktivierst, musst du auch in der GDPR-Consent-Nachricht (siehe SCHRITT 3.5)
als Ad-Partner ergänzen.

---

## SCHRITT 3.5 — GDPR-Einwilligung (Google UMP) — PFLICHT in DE/EU

Ohne gültige Einwilligung liefern Werbenetzwerke in Deutschland/EU praktisch
keine (oder nur sehr schlecht bezahlte) Anzeigen aus. Der Code aktiviert
bereits AppLovins eingebauten **Terms-&-Privacy-Flow** (Google UMP) — dieser
zeigt in EU-Regionen automatisch den Einwilligungsdialog und danach den
ATT-Systemdialog. Damit der Dialog erscheint, brauchst du eine in Google
konfigurierte Consent-Nachricht:

### 1. Kostenlosen AdMob-Account anlegen (hostet die UMP-Nachricht)
- https://apps.admob.com → anmelden (kostenlos)
- Apps → App hinzufügen → deine iOS-App (One Tap Survivor,
  App-Store-ID `6811169822`) registrieren
- Das ist auch dann nötig, wenn du (noch) kein AdMob als Mediation nutzt —
  Google UMP verwaltet die Consent-Nachricht im AdMob-Dashboard.

### 2. GDPR-Nachricht erstellen & veröffentlichen
- AdMob → Privacy & messaging → GDPR → **Create message**
- App(s) auswählen, Sprachen (mind. Deutsch) wählen
- User consent options: **Consent** oder **Manage options** wählen
  (NICHT „Close/do not consent“ ankreuzen)
- Targeting: **Everywhere** → Continue
- Message benennen → **Publish**

### 3. Ad-Partner ergänzen (wichtig für Umsatz)
- In der GDPR-Nachricht unter „Review your ad partners“ alle Netzwerke
  auswählen, die du integrierst (mind. AppLovin/AppLovin Exchange).
- Fehlende Partner ⇒ diese Netzwerke liefern keine Ads. Fehlende Netzwerke
  siehst du später im Mediation Debugger unter „Missing …“.

### 4. Datenschutz-URL prüfen
- In `Constants.swift` ist `privacyPolicyURL` auf die GitHub-Pages-Seite aus
  `docs/` gesetzt. Stelle sicher, dass GitHub Pages aktiv ist (Repo →
  Settings → Pages → Branch `main`, Ordner `/docs`) oder trage deine eigene
  Datenschutz-URL ein.

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
3. Spiel testen — Werbung läuft im DEBUG-Modus **simuliert** (Alert mit 5s-Countdown)

**Echte Ads + Consent testen (Release / TestFlight, echtes Gerät):**
1. Keys in `Constants.swift` müssen echt sein (kein `HIER_…`).
2. Build im **Release**-Konfig auf ein echtes Gerät oder via TestFlight
   (im Debug werden Ads absichtlich simuliert).
3. Beim ersten Start erscheint in EU-Regionen der Google-UMP-Consent-Dialog,
   danach der ATT-Dialog. Anschließend liefern die drei Trigger echte
   Rewarded Ads: +1 Leben, Score ×2, täglicher Bonus.
4. **Mediation Debugger** öffnen (temporär im Code, z. B. nach SDK-Init:
   `ALSdk.shared().showMediationDebugger()`), um zu prüfen:
   - Privacy → CMP zeigt „Google consent management solutions“
   - Rewarded Ad Unit lädt (Test-Ad anzeigbar)
   - keine „Missing …“-Netzwerke, die du integriert hast
5. UMP außerhalb der EU testen: einmalig
   `ALSdk.shared().termsAndPrivacyPolicyFlowSettings.debugUserGeography = .GDPR`
   setzen (nur zum Testen!). Der Flow erscheint nur bei Neuinstallation —
   App löschen & neu installieren, um ihn erneut zu sehen.

**Release Build / App-Store-Update:**
1. Version erhöhen (z. B. `MARKETING_VERSION` 1.1) und `CURRENT_PROJECT_VERSION`
   hochzählen (in `project.yml`, dann `xcodegen generate`).
2. Xcode → Product → Archive → Distribute App → App Store Connect → Upload.
3. In App Store Connect in den **Review-Notes** vermerken: ATT wird nur für
   iOS 14.5+ genutzt (sonst mögliche Ablehnung).

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
