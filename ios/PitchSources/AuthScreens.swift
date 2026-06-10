import SwiftUI
import PhotosUI

// MARK: - Auth (Login + Registrierung)

struct AuthView: View {
    var onLogin: () -> Void = {}      // bestehender Account → direkt zur App
    var onSignUp: () -> Void = {}     // neuer Account → Onboarding

    @AppStorage("appRole") private var appRole = "Spieler"
    @AppStorage("userName") private var userName = ""

    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var password2 = ""
    @State private var isLoading = false
    @State private var errorMsg: String? = nil

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 16) {
                    PitchMark(fg: Theme.accentText)
                        .padding(13)
                        .frame(width: 72, height: 72)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                    Text("PITCH")
                        .font(.pitchDisplay(34)).kerning(4)
                        .foregroundStyle(Theme.text)
                }
                .padding(.bottom, 40)

                VStack(spacing: 12) {
                    authField("E-Mail", text: $email)
                    authField("Passwort", text: $password, secure: true)
                    if isSignUp {
                        authField("Passwort wiederholen", text: $password2, secure: true)
                    }

                    if let err = errorMsg {
                        Text(err).font(.system(size: 12)).foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Primärer Button: Einloggen (Standard) oder Registrieren
                    PitchButton(
                        label: isLoading ? "…" : (isSignUp ? "Registrieren" : "Einloggen"),
                        action: handlePrimary
                    )
                    .opacity(isLoading ? 0.6 : 1)
                    .disabled(isLoading)

                    HStack(spacing: 12) {
                        Rectangle().fill(Theme.line).frame(height: 1)
                        Text("ODER").font(.system(size: 11, weight: .heavy)).kerning(1)
                            .foregroundStyle(Theme.textFaint)
                        Rectangle().fill(Theme.line).frame(height: 1)
                    }
                    PitchButton(label: "Mit Apple anmelden", variant: .outline, systemImage: "applelogo", action: handleApple)
                    PitchButton(label: "Mit Google anmelden", variant: .outline, systemImage: "globe", action: handleApple)
                }

                Spacer()

                // Footer: toggle zwischen Login und Registrierung
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isSignUp.toggle()
                        errorMsg = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isSignUp ? "Schon dabei?" : "Noch nicht dabei?")
                            .foregroundStyle(Theme.textMuted)
                        Text(isSignUp ? "Jetzt einloggen" : "Jetzt registrieren")
                            .foregroundStyle(Theme.accent).fontWeight(.heavy)
                    }
                    .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(Theme.scheme)
    }

    private func handlePrimary() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMsg = "Bitte E-Mail und Passwort eingeben."; return
        }
        if isSignUp {
            guard password.count >= 6 else { errorMsg = "Passwort: mindestens 6 Zeichen."; return }
            guard password == password2 else { errorMsg = "Die Passwörter stimmen nicht überein."; return }
        }
        isLoading = true
        errorMsg = nil
        Task { @MainActor in
            defer { isLoading = false }
            // Demo-Modus, solange kein Firebase-Projekt hinterlegt ist
            guard AuthService.shared.isConfigured else {
                try? await Task.sleep(nanoseconds: 400_000_000)
                isSignUp ? onSignUp() : onLogin()
                return
            }
            do {
                if isSignUp {
                    try await AuthService.shared.signUp(email: email, password: password)
                    onSignUp()
                } else {
                    try await AuthService.shared.signIn(email: email, password: password)
                    // Profil aus Firestore ziehen → App rendert die echte Rolle/den echten Namen
                    await ProfileStore.shared.load()
                    if let p = ProfileStore.shared.profile {
                        appRole = p.role
                        userName = p.name
                        onLogin()
                    } else {
                        onSignUp()   // Konto existiert, aber noch kein Profil → Onboarding nachholen
                    }
                }
            } catch {
                errorMsg = authErrorText(error)
            }
        }
    }

    private func handleApple() {
        // Apple/Google kommen später — bis dahin nur Hinweis, kein Durchlass
        withAnimation(.easeOut(duration: 0.15)) {
            errorMsg = "Kommt bald — bitte mit E-Mail & Passwort anmelden."
        }
    }

    private func authField(_ placeholder: String, text: Binding<String>, secure: Bool = false) -> some View {
        Group {
            if secure {
                SecureField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.textFaint))
            } else {
                TextField("", text: text, prompt: Text(placeholder).foregroundColor(Theme.textFaint))
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
        }
        .foregroundStyle(Theme.text)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
    }
}

// Rückwärtskompatibilität — PitchApp.swift referenziert SignUpView
typealias SignUpView = AuthView

// MARK: - Onboarding (4-Schritt-Wizard: Rolle → Ziel → Profil → Fertig)

struct OnboardingView: View {
    var onDone: () -> Void = {}

    @AppStorage("appRole") private var appRole = "Spieler"
    @AppStorage("userName") private var userName = ""
    @AppStorage("appPhase") private var appPhase = "auth"

    @State private var step = 0
    @State private var role = ""
    @State private var goals: Set<String> = []
    @State private var name = ""
    @State private var accepted = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    // schlanke Felder für Coach / Scout / Verein
    @State private var club = ""
    @State private var location = ""
    @State private var bio = ""

    private let totalSteps = 4
    private var isPlayer: Bool { role == "Spieler" }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                ScrollView {
                    Group {
                        switch step {
                        case 0: roleStep
                        case 1: goalStep
                        case 2: profileStep
                        default: finishStep
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                footer
            }
        }
        .preferredColorScheme(Theme.scheme)
    }

    // Header: Fortschritt + Zurück
    private var header: some View {
        VStack(spacing: 14) {
            HStack {
                if step > 0 {
                    Button { withAnimation(.easeInOut(duration: 0.2)) { step -= 1 } } label: {
                        Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.text)
                    }
                } else {
                    Color.clear.frame(width: 20, height: 20)
                }
                Spacer()
                Text("Schritt \(step + 1) von \(totalSteps)")
                    .font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textMuted)
                Spacer()
                // Raus aus dem falschen Account → zurück zum Login
                Button {
                    AuthService.shared.signOut()
                    UserDefaults.standard.removeObject(forKey: "userName")
                    appPhase = "auth"
                } label: {
                    Text("Abmelden").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textFaint)
                }
                .buttonStyle(.plain)
            }
            HStack(spacing: 6) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    Capsule().fill(i <= step ? Theme.accent : Theme.surfaceAlt).frame(height: 4)
                }
            }
        }
        .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 14)
    }

    // Schritt 1 — Rolle
    private var roleStep: some View {
        VStack(alignment: .leading, spacing: 12) {
            stepTitle("Was bist du?", "Wähle deine Rolle. Danach richtet sich Pitch auf dich aus.")
            roleCardWide("Spieler", "soccerball")
            roleCardWide("Trainer", "flame.fill")
            roleCardWide("Scout", "binoculars.fill")
            roleCardWide("Verein", "shield.fill")
        }
    }

    // Spieler — die primäre Rolle, prominente Karte über die volle Breite
    private func roleCardWide(_ r: String, _ icon: String) -> some View {
        let active = role == r
        return HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(active ? Theme.accentText : Theme.accent)
                .frame(width: 46, height: 46)
                .background(active ? Theme.accent : Theme.surfaceAlt)
                .clipShape(Circle())
            Text(r).font(.system(size: 16, weight: .heavy)).foregroundStyle(Theme.text)
            Spacer()
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22)).foregroundStyle(active ? Theme.accent : Theme.line)
        }
        .padding(16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(active ? Theme.accent : Theme.line, lineWidth: active ? 1.5 : 1))
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeOut(duration: 0.12)) { role = r; goals = [] } }
    }

    // Talent-suchende Rollen — kompakte Kacheln nebeneinander
    private func roleTile(_ r: String, _ icon: String) -> some View {
        let active = role == r
        return VStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(active ? Theme.accentText : Theme.accent)
                .frame(width: 46, height: 46)
                .background(active ? Theme.accent : Theme.surfaceAlt)
                .clipShape(Circle())
            Text(r).font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 16)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(active ? Theme.accent : Theme.line, lineWidth: active ? 1.5 : 1))
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeOut(duration: 0.12)) { role = r; goals = [] } }
    }

    // Schritt 2 — Ziel
    private var goalOptions: [String] {
        switch role {
        case "Spieler": return ["Verein finden", "Stipendium", "Netzwerk aufbauen", "Mich zeigen", "Einfach mal abchecken"]
        case "Trainer": return ["Spieler finden", "Verein finden", "Netzwerk aufbauen"]
        case "Scout": return ["Talente entdecken", "Netzwerk aufbauen"]
        case "Verein": return ["Spieler finden", "Verein präsentieren", "Netzwerk aufbauen"]
        default: return ["Verein finden", "Netzwerk aufbauen", "Mich zeigen"]
        }
    }

    private var goalStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            stepTitle("Was willst du erreichen?", "Mehrfachauswahl möglich — so zeigen wir dir die richtigen Leute.")
            VStack(spacing: 10) {
                ForEach(goalOptions, id: \.self) { goalRow($0) }
            }
        }
    }

    private func goalRow(_ g: String) -> some View {
        let active = goals.contains(g)
        return HStack(spacing: 12) {
            Text(g).font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.text)
            Spacer()
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20)).foregroundStyle(active ? Theme.accent : Theme.line)
        }
        .padding(.horizontal, 16).frame(height: 54)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(active ? Theme.accent : Theme.line, lineWidth: active ? 1.5 : 1))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.12)) {
                if active { goals.remove(g) } else { goals.insert(g) }
            }
        }
    }

    // Schritt 3 — Profil (rollenspezifisch)
    @ViewBuilder
    private var profileStep: some View {
        if isPlayer { playerProfileStep } else { actorProfileStep }
    }

    // Spieler — Pitchkarte
    private var playerProfileStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepTitle("Deine Pitchkarte", "So sehen dich andere. Alles später änderbar.")
            SectionLabel("Live-Vorschau")
            PitchCard(name: name.isEmpty ? "Dein Name" : name, profileImage: profileImage, roleLabel: role)
            SectionLabel("Angaben")
            VStack(spacing: 8) {
                photoUpload
                labeledField("Name", value: $name)
                staticField("Alter", "23")
                staticField("Position", "Innenverteidiger")
                staticField("Ort", "Düsseldorf")
                staticField("Aktueller Verein", "SV Düsseldorf 04")
                staticField("Aktuelle Liga", "Landesliga")
            }
        }
    }

    // Coach / Scout / Verein — schlankes Profil, keine Pitchkarte
    private var actorProfileStep: some View {
        let isClub = role == "Verein"
        return VStack(alignment: .leading, spacing: 16) {
            stepTitle(isClub ? "Euer Vereinsprofil" : "Dein Profil",
                      "Schlicht halten — Name, Details, kurze Beschreibung. Später änderbar.")
            SectionLabel("Live-Vorschau")
            ActorCard(name: name.isEmpty ? (isClub ? "Vereinsname" : "Dein Name") : name,
                      roleLabel: role, profileImage: profileImage,
                      fields: previewFields(isClub: isClub),
                      bio: bio)
            SectionLabel("Angaben")
            VStack(spacing: 8) {
                photoUpload
                labeledField(isClub ? "Vereinsname" : "Name", value: $name)
                if !isClub {
                    labeledField("Verein (oder leer lassen)", value: $club)
                }
                labeledField("Ort", value: $location)
                // Beschreibung
                VStack(alignment: .leading, spacing: 2) {
                    Text(isClub ? "Vereinsbeschreibung" : "Kurzbeschreibung")
                        .font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textFaint)
                    TextField("", text: $bio, axis: .vertical).lineLimit(2...4)
                        .foregroundStyle(Theme.text).font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
            }
        }
    }

    // Vorschau-Felder aus den Eingaben (fällt auf Defaults zurück, solange leer)
    private func previewFields(isClub: Bool) -> [PitchField] {
        var f: [PitchField] = []
        if isClub {
            f.append(.init(icon: "trophy.fill", label: "Liga", value: "Bezirksliga"))
            f.append(.init(icon: "mappin.and.ellipse", label: "Ort", value: location.isEmpty ? "—" : location))
        } else {
            f.append(.init(icon: "shield.fill", label: "Verein", value: club.isEmpty ? "Vereinslos" : club))
            f.append(.init(icon: "mappin.and.ellipse", label: "Ort", value: location.isEmpty ? "—" : location))
        }
        return f
    }

    // Foto-Upload (geteilt zwischen den Rollen)
    private var photoUpload: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            HStack(spacing: 12) {
                Image(systemName: profileImage == nil ? "camera.fill" : "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.accentText)
                    .frame(width: 36, height: 36)
                    .background(Theme.accent)
                    .clipShape(Circle())
                Text(profileImage == nil ? "Profilbild hinzufügen" : "Bild ausgewählt ✓")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(profileImage == nil ? Theme.text : Theme.accent)
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Theme.textFaint)
            }
            .padding(14)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
            .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(
                profileImage == nil ? Theme.line : Theme.accent, lineWidth: profileImage == nil ? 1 : 1.5))
        }
        .onChange(of: selectedPhoto) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run { profileImage = img }
                }
            }
        }
    }

    // Schritt 4 — Fertig
    private var finishStep: some View {
        VStack(spacing: 18) {
            PitchMark(fg: Theme.accentText)
                .padding(20).frame(width: 84, height: 84)
                .background(Theme.accent).clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                .padding(.top, 12)
            Text("Fast geschafft!").font(.pitchHead(26)).foregroundStyle(Theme.text)
            Text("Dein Profil ist startklar. Willkommen bei Pitch.")
                .font(.system(size: 14)).foregroundStyle(Theme.textMuted).multilineTextAlignment(.center)
            if isPlayer {
                PitchCard(name: name.isEmpty ? "Dein Name" : name, profileImage: profileImage, roleLabel: role).padding(.top, 4)
            } else {
                ActorCard(name: name.isEmpty ? (role == "Verein" ? "Vereinsname" : "Dein Name") : name,
                          roleLabel: role, profileImage: profileImage,
                          fields: previewFields(isClub: role == "Verein"), bio: bio).padding(.top, 4)
            }
            Button { withAnimation(.easeOut(duration: 0.12)) { accepted.toggle() } } label: {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: accepted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22)).foregroundStyle(accepted ? Theme.accent : Theme.textMuted)
                    Text("Ich stimme den AGB und der Datenschutzerklärung zu.")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.text).multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(accepted ? Theme.accent : Theme.line, lineWidth: accepted ? 1.5 : 1))
            }
            .buttonStyle(.plain).padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    // Footer-Button
    private var footer: some View {
        VStack(spacing: 8) {
            // Hinweis, warum der Button (noch) gesperrt ist
            if !canAdvance {
                Text(blockHint)
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.textMuted)
            }
            PitchButton(label: step == totalSteps - 1 ? "Loslegen" : "Weiter", action: advance)
                .opacity(canAdvance ? 1 : 0.45)
                .disabled(!canAdvance)
        }
        .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
        .background(Theme.bg)
    }

    private var blockHint: String {
        switch step {
        case 0: return "Wähle eine Rolle, um fortzufahren"
        case 1: return "Wähle mindestens ein Ziel"
        case 3: return "Bitte AGB & Datenschutz bestätigen"
        default: return ""
        }
    }

    private var canAdvance: Bool {
        switch step {
        case 0: return !role.isEmpty
        case 1: return !goals.isEmpty
        case 2: return true
        default: return accepted
        }
    }

    private func advance() {
        if step < totalSteps - 1 { withAnimation(.easeInOut(duration: 0.2)) { step += 1 } }
        else {
            appRole = role.isEmpty ? "Spieler" : role   // Rolle merken → App rendert rollenabhängig
            if !name.isEmpty { userName = name }
            // Echtes Profil in Firestore ablegen (users/{uid}) — im Demo-Modus ohne Wirkung
            ProfileStore.shared.save(UserProfile(
                name: name, role: appRole, club: club, location: location, bio: bio))
            onDone()
        }
    }

    // Helpers
    private func stepTitle(_ title: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 27, weight: .black)).foregroundStyle(Theme.text)
            Text(sub).font(.system(size: 13)).foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func labeledField(_ label: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textFaint)
            TextField("", text: value).foregroundStyle(Theme.text).font(.system(size: 15, weight: .semibold))
        }
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
    }

    private func staticField(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textFaint)
            Text(value).foregroundStyle(Theme.text).font(.system(size: 15, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16).padding(.vertical, 8)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
    }
}

#Preview("Sign-up") { SignUpView() }
#Preview("Onboarding") { OnboardingView() }
