# Pitch — STATE

> [[../README|Personal]] | [[../../INDEX|INDEX]]

**Was:** „LinkedIn für Sport" — Plattform, auf der Sportler, Coaches und Vereine sich vernetzen, Highlights zeigen und über die *Pitch*-Aktion gezielt in Kontakt treten.
**Slogan:** Pitch your play
**Mit wem:** Marvin + sein Bruder Nick
**Klasse:** proof (vorläufig)
**Plattform (V1):** iOS-only, **nativ Swift/SwiftUI** (Wechsel von Expo am 02.06.2026 — SwiftUI-Preview = gewünschtes Live-iPhone). Backend: Firebase. Dev: Xcode (Pflicht).
**Stand:** 2026-06-02 — ✅ **Native iOS-App läuft im Simulator.** Stack = Swift/SwiftUI. Xcode 26.5 installiert, Lizenz ok, `Pitch.xcodeproj` via XcodeGen erzeugt (`ios/project.yml`), **BUILD SUCCEEDED**, App startet auf iPhone-17-Simulator (Sign-up rendert korrekt, Bundle `de.neumanns.pitch`). 4 Screens + Design-System + Pitchkarte + Tab-Nav in `ios/PitchSources/`. Build: `xcodegen generate && xcodebuild ... -scheme Pitch`. Editieren: Xcode-Preview oder Sweetpad in VS Code. Setup-Doku: `ios/SETUP.md`. Expo-Prototyp `app/` = Referenz.
**Design-Stand (02.06.):** Emojis komplett raus → SF Symbols überall. Headlines = breite konstruierte Caps (`Font.pitchDisplay/pitchHead` via `.width(.expanded)`, Platzhalter für echte Grotesk). Akzent = lime `#C6FF3A` (kein Orange, KickBase-inspiriert). ＋-Tab = „Beitrag erstellen", Onboarding mit „Überspringen". KickBase nutzt eigene Fonts KB Volksans/KB Pitch (proprietär) → wir nehmen Charakter, freie Alternative (Kandidat: Archivo Expanded).
**Paletten:** `Theme.active` schaltet um. `.lime` = dark + electric lime (unsere Version, committed `f4664a2`). `.classic` = Bruders Farben (Primär #CC0000 rot [aus „#CCOOO" interpretiert], Sekundär #E8F4FD hellblau) als Light-Theme. Beide gebaut & gescreenshottet 02.06. Aktuell aktiv: `.classic` (zum Vergleich). **Entscheidung offen:** Claude empfiehlt Dark-Basis + ggf. Rot als Akzont (Hybrid) — Light rot/blau wirkt vereinsmäßig/klassisch, widerspricht „jung, kein Cringe". Marvin + Nick entscheiden.
**Screens-Stand (03.06.):** Login (E-Mail + Apple + Google, „Schon dabei? Einloggen"-Link); Onboarding (Rolle Spieler/Coach/Scout/Verein, Live-Pitchkarte OHNE Rating bei neuer Karte, Terms-Häkchen gated den Button, „Überspringen"); Feed (Rating nur bei Spieler-Posts, Pitch = lime Pill, Kommentar-Icon links); CreatePost; **Nachrichten** (Chat-Liste); Profil (Stats `Posts·Follower·Following` ÜBER der Pitchkarte, „Profil bearbeiten", „Profil verknüpfen" Fußball.de/Fupa, „Deine Beiträge"-Grid, Einstellungs-Zahnrad). Pitchkarte-Feld „Ziel"→„Aktueller Verein". Nav = 4 Tabs: Feed · Chats · ＋ · Profil.
**Logo (gewählt 03.06.):** „Aufstieg" — drei aufsteigende Chevrons (custom Vektor, `PitchMark` in MainScreens.swift). Im Login-Badge + als Pitch-Button im Feed. Passt zur Positionierung (hoch = entdeckt werden). Kreis klein, Chevrons groß.
**Rating-Interaktion (gebaut 03.06.):** Pitch-Button im Feed *gedrückt halten* → dünner rot(6)→grün(10)-Balken wächst aus dem Kreis hoch → Daumen hoch/runter swipen → loslassen = Bewertung. `RatingBar` + DragGesture in PostCard. Skala aktuell **6–10** (Doc sagt 7–10 — offen). Nav-Leiste = nur Icons, Feed·Mitteilungen·＋·Chats·Profil.
**GitHub:** Privates Repo `marvinneumann1899-prog/Pitch` (`main`, Remote `origin`, von Codex erstellt/gepusht, sauber: 41 Dateien, keine Build-Artefakte). **Nick (`nickneumann381-dev`) eingeladen mit write-Rechten (04.06.)** — muss Einladung noch annehmen, dann klonen + Xcode-Setup (`ios/SETUP.md`).
**Offen / nächste:** (1) **Pitch vs. Rating klären:** Feed-Button = jetzt Bewerten-per-Swipe. Ist „Pitch=Person connecten" damit vereint (A) oder separat (B)? Skala 6–10 vs 7–10. (2) Pitch-Aktion bei Verein/Coach. (3) Palette final (lime vs Bruders rot/hellblau — Tendenz schwarz-grün). (4) Echte Grotesk-Schrift. (5) Nick als Collaborator hinzufügen. (6) Firebase echt.

## Kern-Idee in einem Satz
Sportliche Job- & Networking-Plattform ohne Mittelmann: gesehen werden, Gleichgesinnte finden, und über *Pitch* direkt Verein/Spieler/Coach connecten.

## Offen / nächste Schritte
- [ ] Block-für-Block-Review des Konzept-Docs abschließen (rote Kommentare)
- [ ] V1-Scope (MVP) vs. V2-Liste schärfen
- [ ] Rollen-Aufteilung Marvin ↔ Bruder
- [ ] Tech-Stack (iOS nativ vs. cross-platform; Backend; Auth)
- [ ] Pitch-Mechanik & Rating (7–10, 0,1-Schritte) auf Tragfähigkeit prüfen

## Verweise
- `source/Idee-Pitch.docx` — Original vom Bruder
- `review/` — annotierte Fassung mit roten Kommentaren
