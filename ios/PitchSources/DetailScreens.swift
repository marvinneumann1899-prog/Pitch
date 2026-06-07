import SwiftUI
import PhotosUI

// MARK: - Geteiltes Personen-Modell (für Navigation in Profile/Chat)

struct PersonRef: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let role: String          // "Spieler", "Coach", "Verein", "Scout", "Vereinsverantwortlicher"
    let icon: String
    var rating: String? = nil
    var sub: String = ""
}

// Rolle aus dem Icon ableiten (für Mitteilungen/Chats, wo keine Rolle mitkommt)
func roleForIcon(_ icon: String) -> String {
    switch icon {
    case "flame.fill":      return "Coach"
    case "trophy.fill":     return "Verein"
    case "binoculars.fill": return "Scout"
    default:                return "Spieler"
    }
}

// Wiederverwendbarer Zurück-Header (eigener statt System-NavBar)
private struct BackHeader: View {
    let title: String
    var trailing: AnyView? = nil
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.text)
            }
            Text(title).font(.pitchHead(18)).kerning(0.5).foregroundStyle(Theme.text)
            Spacer()
            if let trailing { trailing }
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)
    }
}

// MARK: - Fremd-Profil (hier lebt Pitch)

struct UserProfileView: View {
    let person: PersonRef

    @State private var following = false
    @State private var pitchSent = false
    @State private var showToast = false

    private let postIcons = ["soccerball", "trophy.fill", "flame.fill", "figure.soccer", "star.fill", "soccerball"]

    // PitchCard kennt Trainer/Scout/Spieler — Rollen mappen
    private var cardRole: String {
        switch person.role {
        case "Coach", "Trainer": return "Trainer"
        case "Scout": return "Scout"
        default: return "Spieler"
        }
    }
    // Viewer = Spieler (Demo): man pitcht nur rollenübergreifend, nicht Spieler→Spieler
    private var canPitch: Bool { person.role != "Spieler" }

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: person.name)
                ScrollView {
                    VStack(spacing: 16) {
                        PitchCard(name: person.name, rating: person.rating, roleLabel: cardRole)
                        actionRow
                        beitraege
                        linkedSection
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
                }
            }
            if showToast { toast }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    // Folgen (Content) + Pitch (Verbindung). Nach erfolgreichem Pitch: eigener Nachricht-Button.
    private var actionRow: some View {
        HStack(spacing: 10) {
            // Folgen — Toggle (sekundär, wenn daneben Pitch/Nachricht steht)
            Button {
                withAnimation(.spring(duration: 0.2)) { following.toggle() }
            } label: {
                actionLabel(following ? "Folge ich" : "Folgen",
                            icon: following ? "checkmark" : "plus",
                            filled: !following && !canPitch)
            }
            .buttonStyle(.plain)

            if pitchSent {
                // Pitch gesendet → Nachricht als eigener Button (kein Morph)
                NavigationLink {
                    ChatView(person: person)
                } label: {
                    actionLabel("Nachricht", icon: "bubble.left.fill", filled: true)
                }
                .buttonStyle(.plain)
            } else if canPitch {
                Button {
                    withAnimation(.spring(duration: 0.25)) { pitchSent = true; showToast = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                        withAnimation { showToast = false }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill").font(.system(size: 13, weight: .black))
                        Text("PITCH").font(.system(size: 14, weight: .heavy)).kerning(0.5)
                    }
                    .foregroundStyle(Theme.accentText)
                    .frame(maxWidth: .infinity).frame(height: 46)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func actionLabel(_ text: String, icon: String, filled: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 13, weight: .heavy))
            Text(text).font(.system(size: 14, weight: .heavy))
        }
        .foregroundStyle(filled ? Theme.accentText : Theme.text)
        .frame(maxWidth: .infinity).frame(height: 46)
        .background(filled ? Theme.accent : Theme.surfaceAlt)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(filled ? Color.clear : Theme.line, lineWidth: 1))
    }

    // Verlinkte externe Profile (Fupa / Fußball.de) — ganz unten auf dem Profil
    private var linkedSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Verlinkte Profile")
            VStack(spacing: 0) {
                linkRow("Fupa", "fupa.net/player/" + slug)
                Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 44)
                linkRow("Fußball.de", "fussball.de/spieler/" + slug)
            }
            .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
            .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var slug: String {
        person.name.lowercased().replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "ä", with: "ae").replacingOccurrences(of: "ö", with: "oe")
            .replacingOccurrences(of: "ü", with: "ue")
    }

    private func linkRow(_ name: String, _ url: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "link").font(.system(size: 14)).foregroundStyle(Theme.accent).frame(width: 24)
            VStack(alignment: .leading, spacing: 1) {
                Text(name).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text)
                Text(url).font(.system(size: 11)).foregroundStyle(Theme.textMuted).lineLimit(1)
            }
            Spacer()
            Image(systemName: "arrow.up.right").font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textFaint)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
    }

    private var beitraege: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel("Beiträge")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<6, id: \.self) { i in
                    ZStack {
                        Theme.surfaceAlt
                        Image(systemName: postIcons[i % postIcons.count])
                            .font(.system(size: 28)).foregroundStyle(Theme.textFaint)
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var toast: some View {
        HStack(spacing: 10) {
            Image(systemName: "bolt.fill").font(.system(size: 15, weight: .black)).foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 1) {
                Text("Pitch an \(person.name) gesendet").font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
                Text("1 von 5 diese Woche").font(.system(size: 11)).foregroundStyle(Theme.textMuted)
            }
            Spacer()
        }
        .padding(14)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.accent.opacity(0.4), lineWidth: 1))
        .padding(.horizontal, 20).padding(.bottom, 24)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Chat-Thread

struct ChatMsg: Identifiable {
    let id = UUID()
    let text: String
    let mine: Bool
}

struct ChatView: View {
    let person: PersonRef
    @State private var draft = ""
    @State private var messages: [ChatMsg] = [
        .init(text: "Pitch angenommen — lass uns reden!", mine: false),
        .init(text: "Stark, danke dir! Wann hättest du Zeit für ein Probetraining?", mine: true),
        .init(text: "Diese Woche Donnerstag 18 Uhr?", mine: false),
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header mit Avatar
                HStack(spacing: 12) {
                    BackChevron()
                    NavigationLink {
                        UserProfileView(person: PersonRef(name: person.name, role: roleForIcon(person.icon), icon: person.icon))
                    } label: {
                        HStack(spacing: 12) {
                            Avatar(size: 36, systemName: person.icon)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(person.name).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                                Text(person.role.isEmpty ? "Profil ansehen" : person.role)
                                    .font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 10) {
                        // System-Hinweis: erfolgreicher Pitch
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill").font(.system(size: 10, weight: .black))
                            Text("Pitch erfolgreich · ihr seid vernetzt")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.12)).clipShape(Capsule())
                        .padding(.vertical, 6)

                        ForEach(messages) { m in bubble(m) }
                    }
                    .padding(16)
                }

                // Eingabe
                HStack(spacing: 10) {
                    TextField("", text: $draft, prompt: Text("Nachricht…").foregroundColor(Theme.textFaint))
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 16).frame(height: 44)
                        .background(Theme.surface).clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                    Button {
                        let t = draft.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        messages.append(.init(text: t, mine: true)); draft = ""
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 17, weight: .black)).foregroundStyle(Theme.accentText)
                            .frame(width: 44, height: 44).background(Theme.accent).clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .top)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    private func bubble(_ m: ChatMsg) -> some View {
        HStack {
            if m.mine { Spacer(minLength: 40) }
            Text(m.text)
                .font(.system(size: 14)).foregroundStyle(m.mine ? Theme.accentText : Theme.text)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(m.mine ? Theme.accent : Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(m.mine ? Color.clear : Theme.line, lineWidth: 1))
            if !m.mine { Spacer(minLength: 40) }
        }
    }
}

// Kleiner Zurück-Pfeil für Header ohne Titel
private struct BackChevron: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.text)
        }
    }
}

// MARK: - Einstellungen

struct SettingsView: View {
    @AppStorage("appLanguage") private var lang = "de"
    @AppStorage("appPhase") private var phase = "auth"
    @State private var showLogout = false
    @State private var showDelete = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Einstellungen")
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        group("Konto") {
                            navRow("person.crop.circle", "Account", "E-Mail & Passwort ändern") { AccountSettingsView() }
                            divider()
                            navRow("lock.shield", "Sicherheit", "Zwei-Faktor, Geräte") {
                                SettingDetailView(title: "Sicherheit", rows: [("Zwei-Faktor-Authentifizierung", true), ("Aktive Geräte", false), ("Login-Aktivität", false)])
                            }
                            divider()
                            navRow("link", "Verknüpfte Profile", "Fupa, Fußball.de") { LinkProfilesView() }
                            divider()
                            navRow("bolt.fill", "Pitch-Limit", "5 / Woche · Reset Freitag 21:00") { PitchLimitView() }
                        }
                        group("App") {
                            navRow("bell.fill", "Push-Benachrichtigungen", "Pitch, Chat, Bewertungen") {
                                SettingDetailView(title: "Benachrichtigungen", rows: [("Neue Pitches", true), ("Nachrichten", true), ("Bewertungen", true), ("Neue Follower", true)])
                            }
                            divider()
                            navRow("lock.fill", "Privatsphäre", "Wer darf dich pitchen") {
                                SettingDetailView(title: "Privatsphäre", rows: [("Privates Profil", false), ("Wer darf dich pitchen", false), ("Aktivitätsstatus zeigen", true)])
                            }
                            divider()
                            navRow("globe", "Sprache", lang == "de" ? "Deutsch" : "English") { LanguageView() }
                        }
                        group("Support") {
                            navRow("questionmark.circle", "Hilfe-Center", "FAQ & Kontakt") {
                                SettingDetailView(title: "Hilfe-Center", rows: [("Häufige Fragen", false), ("Support kontaktieren", false), ("Nutzungsbedingungen", false), ("Datenschutz", false)])
                            }
                        }

                        VStack(spacing: 10) {
                            dangerButton("Abmelden", color: Theme.text) { showLogout = true }
                            dangerButton("Konto löschen", color: Theme.danger) { showDelete = true }
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
        .confirmationDialog("Wirklich abmelden?", isPresented: $showLogout, titleVisibility: .visible) {
            Button("Abmelden", role: .destructive) { phase = "auth" }
            Button("Abbrechen", role: .cancel) {}
        }
        .confirmationDialog("Konto endgültig löschen? Das lässt sich nicht rückgängig machen.", isPresented: $showDelete, titleVisibility: .visible) {
            Button("Konto löschen", role: .destructive) { phase = "auth" }
            Button("Abbrechen", role: .cancel) {}
        }
    }

    @ViewBuilder
    private func group<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title)
            VStack(spacing: 0) { content() }
                .background(Theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
        }
    }

    private func navRow<D: View>(_ icon: String, _ title: String, _ sub: String, @ViewBuilder dest: @escaping () -> D) -> some View {
        NavigationLink { dest() } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.accent).frame(width: 26)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.text)
                    if !sub.isEmpty { Text(sub).font(.system(size: 11)).foregroundStyle(Theme.textMuted) }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textFaint)
            }
            .padding(.horizontal, 14).padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func divider() -> some View {
        Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 50)
    }

    private func dangerButton(_ label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 15, weight: .heavy)).foregroundStyle(color)
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profil bearbeiten

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = "Marvin Neumann"
    @State private var position = "Innenverteidiger"
    @State private var verein = "SV Düsseldorf 04"
    @State private var liga = "Landesliga"
    @State private var location = "Düsseldorf"
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Profil bearbeiten")
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // Foto — öffnet die Galerie
                        PhotosPicker(selection: $photoItem, matching: .images) {
                            HStack(spacing: 14) {
                                ZStack {
                                    if let img = profileImage {
                                        Image(uiImage: img).resizable().scaledToFill()
                                    } else {
                                        Theme.surfaceAlt
                                        Image(systemName: "camera.fill").font(.system(size: 20)).foregroundStyle(Theme.accent.opacity(0.7))
                                    }
                                }
                                .frame(width: 72, height: 72).clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                                Text(profileImage == nil ? "Foto hinzufügen" : "Foto ändern")
                                    .font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.accent)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 4)
                        .onChange(of: photoItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let ui = UIImage(data: data) {
                                    profileImage = ui
                                }
                            }
                        }

                        field("Name", $name)
                        field("Position", $position)
                        field("Aktueller Verein", $verein)
                        field("Aktuelle Liga", $liga)
                        field("Location", $location)

                        PitchButton(label: "Speichern", systemImage: "checkmark") { dismiss() }
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    private func field(_ label: String, _ value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textFaint)
            TextField("", text: value).foregroundStyle(Theme.text).font(.system(size: 15, weight: .semibold))
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
    }
}

// MARK: - Pitches-Liste (erhalten / gesendet)

struct PitchesView: View {
    @State private var tab = 0  // 0 = erhalten, 1 = gesendet

    private let received: [PersonRef] = [
        .init(name: "Coach Demir", role: "Coach", icon: "flame.fill", sub: "möchte mit dir arbeiten"),
        .init(name: "TSV Eller 04", role: "Verein", icon: "trophy.fill", sub: "sucht Verstärkung"),
    ]
    private let sent: [PersonRef] = [
        .init(name: "SV Düsseldorf 04", role: "Verein", icon: "trophy.fill", sub: "ausstehend"),
        .init(name: "Lena Groß", role: "Scout", icon: "binoculars.fill", sub: "angenommen"),
        .init(name: "FC Beispiel", role: "Verein", icon: "trophy.fill", sub: "abgelehnt"),
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Pitches")
                // Umschalter
                HStack(spacing: 8) {
                    segment("Erhalten", 0)
                    segment("Gesendet", 1)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(tab == 0 ? received : sent) { p in
                            NavigationLink { UserProfileView(person: p) } label: { pitchRow(p) }
                                .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 4).padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    private func segment(_ label: String, _ idx: Int) -> some View {
        let active = tab == idx
        return Text(label)
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(active ? Theme.accentText : Theme.textMuted)
            .frame(maxWidth: .infinity).frame(height: 38)
            .background(active ? Theme.accent : Theme.surfaceAlt)
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.easeOut(duration: 0.15)) { tab = idx } }
    }

    private func pitchRow(_ p: PersonRef) -> some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Avatar(size: 46, systemName: p.icon)
                Image(systemName: "bolt.fill").font(.system(size: 8, weight: .black))
                    .foregroundStyle(Theme.bg).frame(width: 16, height: 16)
                    .background(Theme.accent).clipShape(Circle())
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(p.name).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                Text("\(p.role) · \(p.sub)").font(.system(size: 12)).foregroundStyle(Theme.textMuted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textFaint)
        }
        .padding(12)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
    }
}

// MARK: - Pitch-Limit (Nutzung + mehr Pitches kaufen)

struct PitchLimitView: View {
    @State private var reminder = true

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Pitch-Limit")
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Nutzung diese Woche
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Diese Woche").font(.system(size: 13, weight: .heavy)).foregroundStyle(Theme.textMuted)
                                Spacer()
                                Text("3 / 5").font(.pitchHead(20)).foregroundStyle(Theme.text)
                            }
                            GeometryReader { g in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Theme.surfaceAlt).frame(height: 10)
                                    Capsule().fill(Theme.accent).frame(width: g.size.width * 0.6, height: 10)
                                }
                            }
                            .frame(height: 10)
                            Text("Reset: Freitag 21:00 Uhr").font(.system(size: 12)).foregroundStyle(Theme.textFaint)
                        }
                        .padding(16).background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))

                        // Erinnerung
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Erinnerung bei Reset").font(.system(size: 15, weight: .bold)).foregroundStyle(Theme.text)
                                Text("Push, wenn neue Pitches verfügbar sind").font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                            }
                            Spacer()
                            Toggle("", isOn: $reminder).labelsHidden().tint(Theme.accent)
                        }
                        .padding(16).background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))

                        SectionLabel("Mehr Pitches")
                        Text("Pitches empfangen und antworten ist immer gratis — das Limit gilt nur, wenn du selbst jemanden pitchst.")
                            .font(.system(size: 12)).foregroundStyle(Theme.textMuted)
                        buyOption("3 Pitches", "9,99 €")
                        buyOption("5 Pitches", "14,99 €", highlight: true)
                        buyOption("10 Pitches", "24,99 €")
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    private func buyOption(_ title: String, _ price: String, highlight: Bool = false) -> some View {
        Button { } label: {
            HStack(spacing: 12) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 40, height: 40)
                    .background(Theme.accent.opacity(0.12)).clipShape(Circle())
                Text(title).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                if highlight {
                    Text("BELIEBT").font(.system(size: 9, weight: .heavy)).kerning(0.5)
                        .foregroundStyle(Theme.accentText)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Theme.accent).clipShape(Capsule())
                }
                Spacer()
                Text(price).font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.accent)
            }
            .padding(14).background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
            .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(highlight ? Theme.accent : Theme.line, lineWidth: highlight ? 1.5 : 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Follower-Liste

struct FollowersView: View {
    var startTab: Int = 0   // 0 = Follower, 1 = Folge ich
    @State private var tab = 0
    @State private var unfollowed: Set<UUID> = []

    private let followers: [PersonRef] = [
        .init(name: "Leon Bäcker",  role: "Spieler", icon: "soccerball",      sub: "Stürmer · Landesliga"),
        .init(name: "Jonas Weber",  role: "Spieler", icon: "soccerball",      sub: "Innenverteidiger · Kreisliga"),
        .init(name: "Coach Demir",  role: "Coach",   icon: "flame.fill",      sub: "A-Lizenz · Oberliga"),
        .init(name: "Lena Groß",    role: "Scout",   icon: "binoculars.fill", sub: "Talentscout · NRW"),
        .init(name: "Tim Albers",   role: "Spieler", icon: "soccerball",      sub: "Innenverteidiger · Kreisliga"),
    ]
    private let following: [PersonRef] = [
        .init(name: "SV Düsseldorf 04", role: "Verein",  icon: "trophy.fill",     sub: "Bezirksliga"),
        .init(name: "Coach Demir",      role: "Coach",   icon: "flame.fill",      sub: "A-Lizenz · Oberliga"),
        .init(name: "Lena Groß",        role: "Scout",   icon: "binoculars.fill", sub: "Talentscout · NRW"),
        .init(name: "Leon Bäcker",      role: "Spieler", icon: "soccerball",      sub: "Stürmer · Landesliga"),
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Verbindungen")
                HStack(spacing: 8) {
                    segment("Follower", 0)
                    segment("Folge ich", 1)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(tab == 0 ? followers : following) { p in
                            row(p, editable: tab == 1)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
        .onAppear { tab = startTab }
    }

    private func segment(_ label: String, _ idx: Int) -> some View {
        let active = tab == idx
        return Text(label)
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(active ? Theme.accentText : Theme.textMuted)
            .frame(maxWidth: .infinity).frame(height: 38)
            .background(active ? Theme.accent : Theme.surfaceAlt)
            .clipShape(Capsule())
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.easeOut(duration: 0.15)) { tab = idx } }
    }

    private func row(_ p: PersonRef, editable: Bool) -> some View {
        HStack(spacing: 12) {
            NavigationLink { UserProfileView(person: p) } label: {
                HStack(spacing: 12) {
                    Avatar(size: 46, systemName: p.icon)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.name).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                        Text("\(p.role) · \(p.sub)").font(.system(size: 12)).foregroundStyle(Theme.textMuted).lineLimit(1)
                    }
                }
            }
            .buttonStyle(.plain)
            Spacer()
            if editable {
                let isFollowing = !unfollowed.contains(p.id)
                Button {
                    withAnimation(.spring(duration: 0.2)) {
                        if isFollowing { unfollowed.insert(p.id) } else { unfollowed.remove(p.id) }
                    }
                } label: {
                    Text(isFollowing ? "Folge ich" : "Folgen")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(isFollowing ? Theme.text : Theme.accentText)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(isFollowing ? Theme.surfaceAlt : Theme.accent)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isFollowing ? Theme.line : Color.clear, lineWidth: 1))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.textFaint)
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 10)
        .overlay(Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 78), alignment: .bottom)
    }
}

// MARK: - Sprache

struct LanguageView: View {
    @AppStorage("appLanguage") private var lang = "de"
    private let options: [(String, String)] = [("de", "Deutsch"), ("en", "English")]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Sprache")
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(options.enumerated()), id: \.offset) { idx, o in
                            Button { lang = o.0 } label: {
                                HStack {
                                    Text(o.1).font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.text)
                                    Spacer()
                                    if lang == o.0 {
                                        Image(systemName: "checkmark").font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.accent)
                                    }
                                }
                                .padding(.horizontal, 16).padding(.vertical, 16)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            if idx < options.count - 1 {
                                Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 16)
                            }
                        }
                    }
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
                    .padding(.horizontal, 20).padding(.top, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }
}

// MARK: - Kommentare (Sheet vom Feed)

struct CommentItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let text: String
    let time: String
}

struct CommentsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var comments: [CommentItem] = [
        .init(name: "Coach Demir",  icon: "flame.fill",  text: "Stark gemacht! Wann kommst du mal vorbei?", time: "2 Std"),
        .init(name: "TSV Eller 04", icon: "trophy.fill", text: "Genau sowas suchen wir gerade.",            time: "1 Std"),
        .init(name: "Jonas Weber",  icon: "soccerball",  text: "Übelster Freistoß, Hut ab.",                time: "34 Min"),
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Kommentare").font(.pitchHead(18)).foregroundStyle(Theme.text)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").font(.system(size: 16, weight: .bold)).foregroundStyle(Theme.textMuted)
                    }
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(comments) { c in
                            HStack(alignment: .top, spacing: 12) {
                                Avatar(size: 38, systemName: c.icon)
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(c.name).font(.system(size: 13, weight: .heavy)).foregroundStyle(Theme.text)
                                        Text(c.time).font(.system(size: 11)).foregroundStyle(Theme.textFaint)
                                    }
                                    Text(c.text).font(.system(size: 14)).foregroundStyle(Theme.text).lineSpacing(2)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .overlay(Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 70), alignment: .bottom)
                        }
                    }
                }

                // Eingabe
                HStack(spacing: 10) {
                    TextField("", text: $draft, prompt: Text("Kommentieren…").foregroundColor(Theme.textFaint))
                        .foregroundStyle(Theme.text)
                        .padding(.horizontal, 16).frame(height: 44)
                        .background(Theme.surface).clipShape(Capsule())
                        .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                    Button {
                        let t = draft.trimmingCharacters(in: .whitespaces)
                        guard !t.isEmpty else { return }
                        comments.append(.init(name: "Marvin Neumann", icon: "soccerball", text: t, time: "jetzt")); draft = ""
                    } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 17, weight: .black)).foregroundStyle(Theme.accentText)
                            .frame(width: 44, height: 44).background(Theme.accent).clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .top)
            }
        }
        .preferredColorScheme(Theme.scheme)
    }
}

// MARK: - Fupa verknüpfen (Link einfügen)

struct LinkProfilesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fupa = ""
    @State private var fussballde = ""

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Profile verknüpfen")
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Verlinke deine externen Profile. Sie erscheinen für alle, die dein Profil besuchen.")
                            .font(.system(size: 13)).foregroundStyle(Theme.textMuted)

                        linkField("Fupa", "https://www.fupa.net/player/…", $fupa)
                        linkField("Fußball.de", "https://www.fussball.de/spieler/…", $fussballde)

                        PitchButton(label: "Verknüpfen") { dismiss() }.padding(.top, 4)
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    private func linkField(_ label: String, _ ph: String, _ value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "link").font(.system(size: 12)).foregroundStyle(Theme.accent)
                Text(label.uppercased()).font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textFaint)
            }
            TextField("", text: value, prompt: Text(ph).foregroundColor(Theme.textFaint))
                .foregroundStyle(Theme.text).font(.system(size: 15))
                .textInputAutocapitalization(.never).autocorrectionDisabled()
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
        }
    }
}

// MARK: - Account-Einstellungen (E-Mail / Passwort)

struct AccountSettingsView: View {
    @State private var email = "marvin@neumanns.de"
    @State private var password = "••••••••"
    @State private var saved = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: "Account")
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        labeled("E-Mail-Adresse", $email)
                        labeled("Passwort", $password, secure: true)
                        PitchButton(label: saved ? "Gespeichert" : "Änderungen speichern", systemImage: "checkmark") {
                            withAnimation { saved = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { saved = false } }
                        }.padding(.top, 8)
                    }
                    .padding(.horizontal, 20).padding(.top, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }

    private func labeled(_ label: String, _ value: Binding<String>, secure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased()).font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textFaint)
            if secure {
                SecureField("", text: value).foregroundStyle(Theme.text).font(.system(size: 15, weight: .semibold))
            } else {
                TextField("", text: value).foregroundStyle(Theme.text).font(.system(size: 15, weight: .semibold))
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Theme.surface).clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
    }
}

// MARK: - Generischer Einstellungs-Unterscreen (Push, Privatsphäre, Sicherheit, Hilfe)

struct SettingDetailView: View {
    let title: String
    let rows: [(String, Bool)]   // Label + ist-Schalter

    @State private var toggles: [String: Bool] = [:]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                BackHeader(title: title)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { idx, r in
                            HStack {
                                Text(r.0).font(.system(size: 15, weight: .semibold)).foregroundStyle(Theme.text)
                                Spacer()
                                if r.1 {
                                    Toggle("", isOn: Binding(
                                        get: { toggles[r.0] ?? true },
                                        set: { toggles[r.0] = $0 }))
                                        .labelsHidden().tint(Theme.accent)
                                } else {
                                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textFaint)
                                }
                            }
                            .padding(.horizontal, 16).padding(.vertical, 15)
                            if idx < rows.count - 1 {
                                Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 16)
                            }
                        }
                    }
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
                    .padding(.horizontal, 20).padding(.top, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }
}
