# Pitch — App (Expo / React Native)

iOS-first Prototyp. Stack: Expo SDK 56, React Native 0.85, TypeScript.
Roadmap & Kontext: `../ROADMAP.md`, `../STATE.md`.

## Auf dem iPhone ansehen (Prototyp)

1. **Expo Go** aus dem App Store installieren.
2. iPhone + Mac im **gleichen WLAN**.
3. Im Projektordner: `npm start` → QR-Code mit der iPhone-Kamera scannen.
   - Alternativ in Expo Go „Enter URL manually": `exp://<deine-Mac-IP>:8081`

## Struktur

- `App.tsx` — Navigation (Prototyp: state-basiert, dependency-frei)
- `src/theme.ts` — Design-System (Farben/Spacing/Typo als Token)
- `src/components/` — `ui.tsx` (Button, Chip, Avatar, Card), `PitchCard.tsx`
- `src/screens/` — `SignUp`, `OnboardingPitch` (Pitchkarte), `Feed`, `Profile`

## Bewusste Prototyp-Vereinfachungen (noch nicht echt)

- Navigation per `useState` statt expo-router (kommt bei echtem Build)
- Keine Logik/Backend — reine Optik zum Durchklicken
- Schrift = System-Bold als Platzhalter für die „KickBase-Optik" (echte Schrift später)
- Akzentfarbe (`colors.accent`) frei swappbar — Farben laut Marvin noch offen
- Rating-Badge ist drin, aber: Konflikt „kein Pressure vs. 7–10-Rating" noch ungelöst
