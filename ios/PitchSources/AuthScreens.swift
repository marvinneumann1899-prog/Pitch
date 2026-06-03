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

// MARK: - Onboarding / Pitchkarte erstellen

struct OnboardingPitchView: View {
    var onDone: () -> Void = {}
    @State private var role = "Spieler"
    @State private var name = "Marvin Neumann"
    @State private var accepted = false
    private let roles = ["Spieler", "Coach", "Scout", "Verein"]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Spacer()
                        Button("Überspringen") { onDone() }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.textMuted)
                    }
                    .padding(.bottom, 12)

                    Text("Deine Pitchkarte")
                        .font(.pitchHead(26)).kerning(0.5)
                        .foregroundStyle(Theme.text)
                    Text("Das Herzstück deines Profils. So sehen dich andere.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textMuted)
                        .padding(.top, 4).padding(.bottom, 20)

                    SectionLabel("Rolle")
                    HStack(spacing: 8) {
                        ForEach(roles, id: \.self) { r in
                            Chip(label: r, active: role == r)
                                .onTapGesture { role = r }
                        }
                    }
                    .padding(.bottom, 20)

                    SectionLabel("Live-Vorschau")
                    PitchCard(name: name, rating: nil)
                        .padding(.bottom, 20)

                    SectionLabel("Angaben")
                    VStack(spacing: 8) {
                        labeledField("Name", value: $name)
                        staticField("Alter", "23")
                        staticField("Position", "Innenverteidiger")
                        staticField("Location", "Düsseldorf")
                        staticField("Ziel", "Verein in Oberliga")
                        staticField("Aktuelle Liga", "Landesliga")
                    }

                    Button { accepted.toggle() } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: accepted ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundStyle(accepted ? Theme.accent : Theme.textMuted)
                            Text("Ich stimme den AGB und der Datenschutzerklärung zu.")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.textMuted)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)

                    PitchButton(label: "Pitchkarte fertigstellen", action: { if accepted { onDone() } })
                        .opacity(accepted ? 1 : 0.45)
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(Theme.scheme)
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
#Preview("Onboarding") { OnboardingPitchView() }
