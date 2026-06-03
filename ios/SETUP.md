# Pitch iOS — Setup (sobald Xcode fertig installiert ist)

SwiftUI-Quellcode liegt in `PitchSources/`. Projekt wird per XcodeGen aus `project.yml` erzeugt.

## Einmalig nach der Xcode-Installation

**1. Xcode-Lizenz bestätigen** (einmal Xcode öffnen und zustimmen) oder im Terminal:
```
sudo xcodebuild -license accept
```

**2. Aktive Toolchain auf Xcode zeigen** (statt nur Command Line Tools):
```
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

**3. XcodeGen installieren** (scheiterte vorher nur an der fehlenden Lizenz):
```
brew install xcodegen
```

## Projekt erzeugen (jederzeit nach Code-Änderungen wiederholbar)
```
cd Cloud/personal/Pitch/ios
xcodegen generate --spec project.yml      # erzeugt Pitch.xcodeproj
```

## Starten

**A) In VS Code mit Sweetpad** (in VS Code bleiben):
1. Den `ios/`-Ordner in VS Code öffnen — Sweetpad erkennt `Pitch.xcodeproj`.
2. In der Sweetpad-Leiste: **Scheme „Pitch"** + einen **iPhone-Simulator** wählen.
3. **Build & Run** → App startet im Simulator-Fenster neben VS Code.
   - Live-Loop: Code ändern → erneut Run. (Inline-Canvas-Preview gibt's nur in Xcode.)

**B) In Xcode** (für die echte Live-Preview):
1. `Pitch.xcodeproj` öffnen.
2. Eine `*.swift`-Datei öffnen → **Canvas/Preview** an → iPhone aktualisiert sich live beim Tippen.
3. Oben Simulator wählen → **Run** für die volle App.

## Schritte 1–2 brauchen dein Passwort (sudo) — die mache ich nicht, die klickst/tippst du.
## Schritt 3 + „Projekt erzeugen" + Starten übernehme ich bzw. Sweetpad.
