# Pitch — Build-Roadmap

> Für Marvin + Nick. Gebaut wird von AI-Agenten (Claude + Codex), wir dirigieren.
> [[STATE]] · Quelle-Idee: `source/Idee-Pitch.docx`

## Stack-Entscheidung (fix)

- **App:** **Swift / SwiftUI**, nativ iOS-only (Entscheidung 02.06.2026 — nach Marvins Recherche; native Standard-Weg + SwiftUI-Preview = das gewünschte Live-iPhone neben dem Editor)
- **Dev-Umgebung:** **Xcode** (enthält Swift, iOS-SDK, Simulator, SwiftUI-Preview). Pflicht für iOS — kein swiftly/CLI-Toolchain, das baut keine iOS-Apps.
- **Backend:** **Firebase** (natives iOS-SDK) — Auth (Apple Sign-in + E-Mail), Firestore (DB), Storage (Clips), FCM (Push)
- **Video:** MVP = Firebase Storage + nativer Player. Bei Wachstum → Cloudflare Stream / Mux
- **Design-Sprache:** KickBase-clean — monochrom, hoher Kontrast, fette sportliche Headlines, viel Weißraum, Karten-basiert, 1 Akzentfarbe

**Warum Firebase statt Supabase:** Push eingebaut (FCM), reifere Mobile-SDKs, meiste AI-Trainingsdaten. Supabase-Vorteil (SQL, Portabilität) zählt erst bei Skalierung.

**Verworfen:** Expo/React Native (Web-Preview fühlte sich für eine iOS-App falsch an; SwiftUI gibt nativ den besseren Live-Preview-Workflow). Der Expo-Prototyp in `app/` bleibt als **Design-Referenz** (Farben, Pitchkarte, 4 Screens) und wird nach SwiftUI übersetzt.

---

## Zusammenarbeit (Marvin ↔ Nick ↔ AI)

- **1 geteiltes GitHub-Repo**, beide haben Zugriff. `main` bleibt immer lauffähig.
- **Arbeits-Loop:** Aufgabe nehmen → eigenem AI-Agent geben → Agent arbeitet auf **Feature-Branch** → **Pull Request** → der andere schaut drüber & merged. Aufgaben klein halten.
- **Koordination:** `STATE.md` im Repo ist die Wahrheit — wer gerade woran sitzt. Vor dem Start kurz abstimmen, damit ihr nicht dieselbe Datei anfasst.
- **Entscheidungen** kommen in `decisions/` (kurze Notizen), damit nichts doppelt diskutiert wird.

---

## MVP-Scope (das — und nur das — zuerst)

Der Kern-Loop, der die Wette testet „lädt ein Amateurkicker freiwillig einen Clip hoch?":

> **Sign-up → Spieler-Pitchkarte anlegen → Clip hochladen → Kumpels sehen ihn im Feed → folgen**

**Nicht** im MVP: Chat, Pitch/Scout-Flow, Rating 7–10, Exposé/Cloud, Fupa-Sync, Vorstand/Scout-Rollen. Alles Phase 3+.

---

## Phasen

### Phase 0 — Design (START HIER)
- [ ] Design-System festlegen: Farben (mono + 1 Akzent), Typo, Spacing, Karten, Buttons
- [ ] Die 4 MVP-Screens entwerfen: **Sign-up/Login · Pitchkarte erstellen · Feed · Profil**
- [ ] Pitchkarte-Layout (Spieler): Rating-Platzhalter o. l., Bild ~35 %, Felder ab Mitte
- [ ] Ergebnis: klickbarer Figma-Prototyp **oder** statische Screens als Referenz für die Agenten

### Phase 1 — Repo + Gerüst
- [ ] GitHub-Repo `pitch` anlegen, beide einladen, `STATE.md` + `decisions/` rein
- [ ] Expo-App scaffolden, auf echtem iPhone via Expo Go laufen lassen
- [ ] Firebase-Projekt anlegen, App verbinden
- [ ] **Apple Sign-in + E-Mail-Auth** lauffähig (erster echter Meilenstein)

### Phase 2 — Kern-Loop bauen
- [ ] Datenmodell: `users`, `profiles` (Pitchkarte), `clips`, `follows`
- [ ] Onboarding: Rolle wählen (MVP nur **Spieler**) → Pitchkarte-Felder → Profilbild
- [ ] Clip-Upload (Kamera/Galerie → Firebase Storage), leichtgewichtig, wenig Pressure
- [ ] Feed: Clips von Kontakten + Umgebung, flüssiges Scroll-Playback
- [ ] Folgen + Profil ansehen
- [ ] **MVP fertig** = der Loop oben läuft end-to-end auf dem iPhone

### Phase 3 — Auflegen (nach MVP-Validierung)
- Chat (nur mit Vernetzten) · Pitch-Flow + Benachrichtigungen · Rating-Logik (⚠️ Konflikt „kein Pressure" vorher lösen) · weitere Rollen (Coach/Scout/Vorstand/Verein) · Exposé · Fupa-Sync

---

## Offene Entscheidungen (vor/während Phase 3)
- Pitch-Anfragen: wohin, wenn der „Netzwerk"-Tab raus ist? (Glocke / Profil / Chat-Badge)
- Rating 7–10 öffentlich vs. „kein Pressure" — auflösen, bevor Rating gebaut wird
- Video-Host-Wechsel-Punkt (Firebase Storage → Cloudflare/Mux)
