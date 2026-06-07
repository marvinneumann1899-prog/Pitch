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
**Onboarding (gebaut 04.06.):** 4-Schritt-Wizard (`OnboardingView`, ersetzt das alte Ein-Screen) — Rolle (Spieler/Trainer/Verein/Scout, gruppiert Talent-zeigen vs Talent-suchen) → Ziel (rollenabhängige Mehrfachauswahl, fürs Matching) → Profil (Pitchkarte + Felder) → Fertig (AGB + „Loslegen"). Fortschrittsbalken + Zurück, „Weiter" gated. Offen: Profil-Felder noch nur Spieler-Variante; Ziele später an Algorithmus.
**Design-Feinschliff (04.06., 2. Runde):** Login = „Pitch your play" raus (cleaner). Onboarding-Rolle: Titel nicht mehr expanded/„verzogen" (jetzt `.black` statt `pitchHead`), Spieler als prominente Vollbreit-Karte ohne Untertitel, Trainer/Verein/Scout als kompakte Kacheln 2-spaltig nebeneinander. Ziel: „Einfach zum Spaß — Clips teilen" als Spieler-Option ergänzt. Feed: Video jetzt Hero (340pt), Außenränder schlanker, Name oben leichter. Profil neu sortiert: Follower-Karte ZUERST → Pitchkarte → „Profil bearbeiten" (Vollbreite, „Teilen" raus) → Beiträge → „Profil verknüpfen" ganz unten.

**★ PRODUKT-ENTSCHEIDUNG Folgen/Vernetzen/Pitchen (04.06., aus Nicks Doc geklärt):** Drei Stufen, messen verschiedene Dinge —
- **Folgen** = einseitig, keine Erlaubnis, personalisiert den Feed (Instagram-Logik). *Aufmerksamkeit.*
- **Vernetzen** = beidseitig (Anfrage→annehmen), schaltet Chat frei, zählt als Kontakt (LinkedIn-Logik). *Beziehung.*
- **Pitch** = rollenabhängig (Spieler↔Verein/Coach, beide Richtungen), auffällig annehmen/ablehnen → bei Annahme auto-vernetzt + Chat öffnet mit „Pitch erfolgreich". *Absicht zur Zusammenarbeit.*
- **Bewerten ≠ Pitchen:** Bewerten = Qualität *eines Beitrags* (Regler 7–10, 0,1-Schritte, nur Highlights zählen fürs Rating). Pitchen = Interesse *an einer Person/Club*.
- **Pitch lebt NUR auf dem Profil**, nicht im Feed (Marvin-Entscheidung 04.06. — macht Pitch bewusst/knapp, kein Like-Gefühl).

**Feed-Aktionsleiste (gebaut 04.06., doc-treu):** Bewerten LINKS (Swipe-Regler, Stern-Griff statt Chevron, Skala **7–10**), Kommentar RECHTS (Neon-Kreis + Count). Pitch aus dem Feed entfernt.

**Durchklickbare Demo (gebaut 06.06., `DetailScreens.swift`):** Ziel = komplette Demo, fast alles klickbar; Marvin klickt durch & gibt Feedback, dann iterieren. Neu:
- **Fremd-Profil** (`UserProfileView`) — öffnet beim Tippen auf Namen/Avatar im Feed, in Suche, in Mitteilungen. Zeigt Pitchkarte (rollenabhängige Felder), Aktions-Reihe **Folgen→Vernetzen→Nachricht** + **PITCH** (⚡, nur rollenübergreifend: Spieler kann nicht Spieler pitchen), Beiträge-Grid, Pitch-Toast „1 von 5 diese Woche".
- **Chat-Thread** (`ChatView`) — öffnet aus Nachrichten-Liste; System-Pille „Pitch erfolgreich · vernetzt", Bubbles, funktionierende Eingabe (lokal).
- **Einstellungen** (`SettingsView`) — Zahnrad im Profil; Konto (Account/Pitch-Limit/Verknüpfte Profile) + App (Benachrichtigungen/Privatsphäre/Hilfe) + Abmelden.
- **Profil bearbeiten** (`EditProfileView`) — Button im Profil; Felder + Speichern.
- **Pitches-Liste** (`PitchesView`) — Pitches-Zahl im Profil; Reiter Erhalten/Gesendet, Zeilen → Profil.
- **Login**: „Ohne Anmeldung ansehen →" (Demo-Skip). Navigation via NavigationStack pro Tab + eigener Zurück-Header (System-NavBar versteckt).
- Verifiziert: alle 7 Screens gebaut & gescreenshottet, BUILD SUCCEEDED, stilkonsistent.

**Klick-Iteration (06.–07.06.):** Aus Marvins Durchklick umgesetzt — „Vernetzen" komplett raus → nur **Folgen** (Content) + **Pitch** (Verbindung); Nachricht erscheint als eigener Button nach angenommenem Pitch. Profil-Stats = **Follower | Folge ich | Netzwerk** (Folge-ich-Liste editierbar/entfolgbar). Kommentare = halbhohes Bottom-Sheet + schlichtes Icon. Chat-Senden & Posten on-brand (↑, kein Pfeil-Logo). Chat-Header → Profil. Nachrichten: Compose → neuer Chat per Suche. Profil bearbeiten: Foto-Picker (Galerie). **Profile verknüpfen** = Fupa **+ Fußball.de**; Fremd-Profil zeigt verlinkte Profile unten. **Einstellungen** voll ausgebaut + klickbar (Account E-Mail/Passwort, Sicherheit, **Sprache DE/EN** (nur Auswahl, echte Lokalisierung offen), Push, Privatsphäre, Hilfe, **Abmelden**=Logout via `@AppStorage("appPhase")`, **Konto löschen** mit Rückfrage). **Pitch-Limit-Screen**: Nutzung 3/5, Reset-Erinnerung, **Pakete kaufen 3/9,99€ · 5/14,99€ (beliebt) · 10/24,99€ — KEIN Unbegrenzt** (Marvin-Entscheidung). Alles via `DetailScreens.swift`, NavigationStack pro Tab.

**★ OFFENE PRODUKT-FRAGE — Chat-Zugang (Marvin fragt, Claude-Empfehlung):** Wann darf man schreiben? Empfehlung: **Chat nur über angenommenen Pitch** (egal welche Richtung). Folgen (auch gegenseitig) schaltet Chat NICHT frei — sonst wäre Pitch wertlos. Marvins Sorge „wenn Pitches alle sind, kann man niemanden mehr schreiben" ist gelöst durch: **Empfangen + Annehmen + Antworten ist immer gratis/unbegrenzt** — das Wochen-Limit gilt nur fürs *selbst-Pitchen* (Initiieren). Man ist also nie unerreichbar. (In Pitch-Limit-Screen schon so erklärt.) → Marvin muss final bestätigen.

**Noch offen (für Iteration nach Marvins Durchklick):** (1) Pitch-Ort final: Codex hat Pitch zusätzlich im Feed (⚡-Kapsel) — Marvin wollte „nur Profil"; Wochen-Limit (5/Wo) hält es ohnehin knapp → beim Durchklicken entscheiden. (2) Verein/Coach Onboarding-Profilfelder. (3) Verein-Pitchkarte eigene Felder (aktuell Spieler-Default). (4) Netzwerk-Übersicht (Anfragen/Follower) als eigener Bereich. (5) Fupa-Verknüpfen-Zeile noch ohne Ziel.
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
