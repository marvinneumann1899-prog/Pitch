import SwiftUI

// MARK: - Sign-up

struct SignUpView: View {
    var onContinue: () -> Void = {}
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                // Brand
                VStack(spacing: 16) {
                    PitchMark(fg: Theme.accentText)
                        .padding(13)
                        .frame(width: 72, height: 72)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                    Text("PITCH")
                        .font(.pitchDisplay(34)).kerning(4)
                        .foregroundStyle(Theme.text)
                    Text("Pitch your play")
                        .font(.system(size: 15)).kerning(0.5)
                        .foregroundStyle(Theme.textMuted)
                }
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 12) {
                    field("E-Mail", text: $email)
                    field("Passwort", text: $password, secure: true)
                    PitchButton(label: "Konto erstellen", action: onContinue)

                    HStack(spacing: 12) {
                        Rectangle().fill(Theme.line).frame(height: 1)
                        Text("ODER").font(.system(size: 11, weight: .heavy)).kerning(1)
                            .foregroundStyle(Theme.textFaint)
                        Rectangle().fill(Theme.line).frame(height: 1)
                    }
                    PitchButton(label: "Mit Apple anmelden", variant: .outline, systemImage: "applelogo", action: onContinue)
                    PitchButton(label: "Mit Google anmelden", variant: .outline, systemImage: "globe", action: onContinue)
                }

                Spacer()
                HStack(spacing: 4) {
                    Text("Schon dabei?").foregroundStyle(Theme.textMuted)
                    Text("Einloggen").foregroundStyle(Theme.accent).fontWeight(.heavy)
                }
                .font(.system(size: 13))
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .preferredColorScheme(Theme.scheme)
    }

    private func field(_ placeholder: String, text: Binding<String>, secure: Bool = false) -> some View {
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

// MARK: - Onboarding (4-Schritt-Wizard: Rolle → Ziel → Profil → Fertig)

struct OnboardingView: View {
    var onDone: () -> Void = {}

    @State private var step = 0
    @State private var role = ""
    @State private var goals: Set<String> = []
    @State private var name = "Marvin Neumann"
    @State private var accepted = false

    private let totalSteps = 4

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
                Color.clear.frame(width: 20, height: 20)
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
        VStack(alignment: .leading, spacing: 22) {
            stepTitle("Was bist du?", "Wähl deine Rolle. Danach richten wir Pitch auf dich aus.")
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Ich zeige mein Talent")
                roleCard("Spieler", "Sportler, der gesehen werden will", "soccerball")
            }
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("Ich suche Talent")
                roleCard("Trainer", "Coach auf der Suche", "flame.fill")
                roleCard("Verein", "Klub, der Spieler & Coaches sucht", "trophy.fill")
                roleCard("Scout", "Talentscout", "binoculars.fill")
            }
        }
    }

    private func roleCard(_ r: String, _ desc: String, _ icon: String) -> some View {
        let active = role == r
        return HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(active ? Theme.accentText : Theme.accent)
                .frame(width: 44, height: 44)
                .background(active ? Theme.accent : Theme.surfaceAlt)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(r).font(.system(size: 16, weight: .heavy)).foregroundStyle(Theme.text)
                Text(desc).font(.system(size: 12)).foregroundStyle(Theme.textMuted)
            }
            Spacer()
            Image(systemName: active ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20)).foregroundStyle(active ? Theme.accent : Theme.line)
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(active ? Theme.accent : Theme.line, lineWidth: active ? 1.5 : 1))
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeOut(duration: 0.12)) { role = r; goals = [] } }
    }

    // Schritt 2 — Ziel
    private var goalOptions: [String] {
        switch role {
        case "Spieler": return ["Verein finden", "Stipendium", "Mitspieler & Netzwerk", "Mich zeigen", "Besser werden"]
        case "Trainer": return ["Spieler finden", "Verein finden", "Netzwerk aufbauen"]
        case "Verein": return ["Spieler finden", "Coach finden", "Verein präsentieren"]
        case "Scout": return ["Talente entdecken", "Netzwerk aufbauen"]
        default: return ["Verein finden", "Netzwerk", "Mich zeigen"]
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

    // Schritt 3 — Profil
    private var profileStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepTitle("Deine Pitchkarte", "So sehen dich andere. Alles später änderbar.")
            SectionLabel("Live-Vorschau")
            PitchCard(name: name, rating: nil)
            SectionLabel("Angaben")
            VStack(spacing: 8) {
                labeledField("Name", value: $name)
                staticField("Alter", "23")
                staticField("Position", "Innenverteidiger")
                staticField("Location", "Düsseldorf")
                staticField("Aktueller Verein", "SV Düsseldorf 04")
                staticField("Aktuelle Liga", "Landesliga")
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
            PitchCard(name: name, rating: nil).padding(.top, 4)
            Button { accepted.toggle() } label: {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: accepted ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20)).foregroundStyle(accepted ? Theme.accent : Theme.textMuted)
                    Text("Ich stimme den AGB und der Datenschutzerklärung zu.")
                        .font(.system(size: 12)).foregroundStyle(Theme.textMuted).multilineTextAlignment(.leading)
                    Spacer()
                }
            }
            .buttonStyle(.plain).padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
    }

    // Footer-Button
    private var footer: some View {
        PitchButton(label: step == totalSteps - 1 ? "Loslegen" : "Weiter", action: advance)
            .opacity(canAdvance ? 1 : 0.45)
            .disabled(!canAdvance)
            .padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 20)
            .background(Theme.bg)
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
        else { onDone() }
    }

    // Helpers
    private func stepTitle(_ title: String, _ sub: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.pitchHead(26)).foregroundStyle(Theme.text)
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
