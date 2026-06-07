import SwiftUI

// MARK: - Feed

struct FeedPost: Identifiable {
    let id = UUID()
    let user: String
    let role: String
    let time: String
    let category: String
    let rating: String?  // nil = unter 5 Bewertungen (rating-system: min. 5)
    let caption: String
    let icon: String
    let reason: String   // feed-algorithm: Transparenz warum dieser Post erscheint

    var person: PersonRef { PersonRef(name: user, role: role, icon: icon, rating: rating) }
}

private let demoPosts: [FeedPost] = [
    .init(user: "Leon Bäcker", role: "Spieler", time: "vor 2 Std", category: "Highlight",
          rating: "8.9", caption: "Freistoßtor von der Strafraumkante. Wochenende war gut.",
          icon: "soccerball", reason: "In deiner Nähe"),
    .init(user: "TSV Eller 04", role: "Vereinsverantwortlicher", time: "vor 5 Std", category: "Erfolg",
          rating: nil, caption: "Aufstieg in die Bezirksliga klargemacht! Wir suchen Verstärkung.",
          icon: "trophy.fill", reason: "Dein Kontakt hat das bewertet"),
    .init(user: "Coach Demir", role: "Coach", time: "gestern", category: "Highlight",
          rating: nil, caption: "Pressing-Drill aus dem Training. Erst 3 Bewertungen.",
          icon: "flame.fill", reason: "Weil du Fußball folgst"),
]

struct FeedView: View {
    @State private var showSearch = false
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Button { showSearch = true } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.text)
                        }
                        Spacer()
                        Text("PITCH").font(.pitchDisplay(20)).kerning(2)
                            .foregroundStyle(Theme.text)
                        Spacer()
                        Image(systemName: "magnifyingglass").font(.system(size: 18)).opacity(0)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(demoPosts) { PostCard(post: $0) }
                        }
                        .padding(.horizontal, 10).padding(.vertical, 12)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
        .sheet(isPresented: $showSearch) { SearchView() }
    }
}

private struct PostCard: View {
    let post: FeedPost
    @State private var ratingActive = false
    @State private var ratingValue: Double = 8.0
    @State private var following = false
    @State private var pitched = false
    @State private var showComments = false

    var body: some View {
        VStack(spacing: 0) {
            // LinkedIn-Stil: Grund-Leiste über dem Beitrag
            reasonBar
            ZStack(alignment: .bottomLeading) {
                cardBody
                    .opacity(ratingActive ? 0.55 : 1)
                if ratingActive {
                    RatingBar(value: ratingValue)
                        .padding(.leading, 13)
                        .offset(y: -16)
                        .transition(.scale(scale: 0.18, anchor: .bottom).combined(with: .opacity))
                        .allowsHitTesting(false)
                }
            }
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
        .sheet(isPresented: $showComments) {
            CommentsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // Grund-Leiste (warum dieser Post im Feed)
    private var reasonBar: some View {
        HStack(spacing: 5) {
            Image(systemName: reasonIcon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Theme.accent)
            Text(post.reason)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textMuted)
            Spacer()
        }
        .padding(.horizontal, 13).padding(.vertical, 8)
        .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)
    }

    private var reasonIcon: String {
        if post.reason.contains("Nähe") { return "mappin.fill" }
        if post.reason.contains("Kontakt") { return "person.2.fill" }
        return "soccerball"
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Avatar + Name (→ Profil) + Follow(+) + Kategorie
            HStack(spacing: 10) {
                NavigationLink {
                    UserProfileView(person: post.person)
                } label: {
                    HStack(spacing: 10) {
                        Avatar(size: 34, systemName: post.icon)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(post.user).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text)
                            Text("\(post.role) · \(post.time)").font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Follow-Button (+)
                if !following {
                    Button { withAnimation(.spring(duration: 0.2)) { following = true } } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundStyle(Theme.accentText)
                            .frame(width: 17, height: 17)
                            .background(Theme.accent)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 17, height: 17)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(Circle())
                }

                Spacer()
                Chip(label: post.category)
            }

            // Video/Bild
            ZStack {
                Theme.surfaceAlt
                Image(systemName: post.icon).font(.system(size: 56)).foregroundStyle(Theme.textFaint.opacity(0.6))
                Circle().fill(Color.black.opacity(0.55)).frame(width: 56, height: 56)
                    .overlay(Circle().stroke(Theme.line, lineWidth: 1))
                    .overlay(Image(systemName: "play.fill").foregroundStyle(Theme.text).font(.system(size: 18)))
                // Rating-Badge (nur Spieler + Highlight)
                VStack { HStack {
                    if post.role == "Spieler" && post.category == "Highlight" {
                        if let r = post.rating {
                            HStack(spacing: 4) {
                                PitchMark(fg: Theme.accent).frame(width: 12, height: 12)
                                Text(r).font(.system(size: 13, weight: .black))
                            }
                            .foregroundStyle(Theme.accent)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(Theme.bg).clipShape(Capsule())
                            .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                        } else {
                            Text("Noch zu wenige Bewertungen")
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.textFaint)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Theme.bg.opacity(0.8)).clipShape(Capsule())
                        }
                    }
                    Spacer()
                }; Spacer() }.padding(12)
            }
            .frame(height: 340)
            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))

            Text(post.caption).font(.system(size: 13)).foregroundStyle(Theme.text).lineSpacing(4)

            // Aktionsleiste: [Bewerten] [💬 12]          [⚡ PITCH]
            HStack(spacing: 10) {
                // Bewerten — PitchMark-Logo, gedrückt halten + wischen = Regler
                PitchMark(fg: Theme.accentText)
                    .padding(9)
                    .frame(width: 34, height: 34)
                    .background(ratingActive ? Theme.accent.opacity(0.4) : Theme.accent)
                    .clipShape(Circle())
                    .opacity(ratingActive ? 0 : 1)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { g in
                                if !ratingActive {
                                    withAnimation(.easeOut(duration: 0.12)) { ratingActive = true }
                                }
                                let v = 8.5 + Double(-g.translation.height) / 24.0
                                ratingValue = min(10, max(7, (v * 10).rounded() / 10))
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.15)) { ratingActive = false }
                            }
                    )

                // Kommentar — schlichtes Bubble-Icon (Instagram-Stil), öffnet Bottom-Sheet
                Button { showComments = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Theme.text)
                        Text("12").font(.system(size: 13, weight: .bold)).foregroundStyle(Theme.textMuted)
                    }
                    .frame(height: 34)
                }
                .buttonStyle(.plain)
                .opacity(ratingActive ? 0 : 1)

                Spacer()

                // Pitch-Button rechts
                Button {
                    withAnimation(.spring(duration: 0.25)) { pitched.toggle() }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(pitched ? Theme.accent : Theme.accentText)
                        Text("PITCH")
                            .font(.system(size: 12, weight: .heavy)).kerning(0.5)
                            .foregroundStyle(pitched ? Theme.accent : Theme.accentText)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(pitched ? Theme.accent.opacity(0.15) : Theme.accent)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(pitched ? Theme.accent : Color.clear, lineWidth: 1.5))
                }
                .buttonStyle(.plain)
                .opacity(ratingActive ? 0 : 1)
            }
            .padding(.top, 10)
            .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .top)
        }
        .padding(13)
    }
}

// Bewerten: der Stern-Kreis öffnet sich nach oben zu einer Kapsel mit Farbverlauf
// (rot unten/7 → grün oben/10). Mittig über dem Button, fest. Knopf + Zahl folgen dem Daumen.
private struct RatingBar: View {
    let value: Double
    private let w: CGFloat = 34          // = Durchmesser des Bewerten-Kreises
    private let barH: CGFloat = 188

    var body: some View {
        let frac = CGFloat((value - 7) / 3)        // 0 bei 7 … 1 bei 10
        let travel = barH - w - 8                  // Knopf-Weg
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(LinearGradient(
                    colors: [Color(hex: 0xFF4D4D), Color(hex: 0xFFD23E), Color(hex: 0xC6FF3A), Color(hex: 0x16A34A)],
                    startPoint: .bottom, endPoint: .top))
                .frame(width: w, height: barH)
                .shadow(color: .black.opacity(0.4), radius: 12, y: 4)

            // PitchMark unten — füllt den Kreis
            PitchMark(fg: Theme.accentText)
                .padding(3)
                .frame(width: w, height: w)

            // Knopf (folgt dem Daumen)
            Capsule().fill(Theme.text)
                .frame(width: w - 12, height: 5)
                .offset(y: -(w * 0.7) - frac * travel)

            // Zahl rechts vom Knopf (verhindert Abschneiden am Rand)
            Text(String(format: "%.1f", value))
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Theme.surface)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.accent, lineWidth: 1))
                .offset(x: w + 6, y: -(w * 0.7) - frac * travel)
                .fixedSize()
        }
        .frame(width: w, height: barH, alignment: .bottom)
    }
}

// MARK: - Profil

struct ProfileView: View {
    private let postIcons = ["soccerball", "trophy.fill", "flame.fill", "figure.soccer", "star.fill", "soccerball"]

    @State private var showEdit = false

    var body: some View {
        NavigationStack {
        ZStack {
            Theme.bg.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("PROFIL").font(.pitchHead(24)).kerning(1).foregroundStyle(Theme.text)
                        Spacer()
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape.fill").font(.system(size: 20)).foregroundStyle(Theme.textMuted)
                        }
                        .buttonStyle(.plain)
                    }

                    // Stats: Follower & Folge ich (aus Folgen/Content) + Netzwerk (aus Pitches)
                    HStack(spacing: 0) {
                        NavigationLink { FollowersView(startTab: 0) } label: {
                            VStack(spacing: 3) {
                                Text("248").font(.pitchHead(20)).foregroundStyle(Theme.text)
                                Text("FOLLOWER").font(.system(size: 9, weight: .heavy)).kerning(0.8)
                                    .foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)

                        Rectangle().fill(Theme.line).frame(width: 1, height: 34)

                        NavigationLink { FollowersView(startTab: 1) } label: {
                            VStack(spacing: 3) {
                                Text("96").font(.pitchHead(20)).foregroundStyle(Theme.text)
                                Text("FOLGE ICH").font(.system(size: 9, weight: .heavy)).kerning(0.8)
                                    .foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)

                        Rectangle().fill(Theme.line).frame(width: 1, height: 34)

                        NavigationLink { PitchesView() } label: {
                            VStack(spacing: 3) {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 12, weight: .black))
                                        .foregroundStyle(Theme.accent)
                                    Text("34").font(.pitchHead(20)).foregroundStyle(Theme.text)
                                }
                                Text("NETZWERK").font(.system(size: 9, weight: .heavy)).kerning(0.8)
                                    .foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))

                    // Pitch-Limit-Karte → öffnet Pitch-Limit-Screen (Nutzung + kaufen)
                    NavigationLink {
                        PitchLimitView()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 34, height: 34)
                                .background(Theme.accent.opacity(0.12))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text("3 / 5 Pitches diese Woche")
                                    .font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
                                Text("Reset · Freitag 21:00 Uhr")
                                    .font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                            }
                            Spacer()
                            ZStack(alignment: .leading) {
                                Capsule().fill(Theme.surfaceAlt).frame(width: 60, height: 6)
                                Capsule().fill(Theme.accent).frame(width: 36, height: 6)
                            }
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textFaint)
                        }
                        .padding(14)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    PitchCard()

                    PitchButton(label: "Profil bearbeiten", variant: .ghost, systemImage: "pencil") { showEdit = true }

                    // Deine Beiträge
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Deine Beiträge")
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

                    // integrations: externe Profile verlinken (Fupa, Fußball.de …)
                    NavigationLink {
                        LinkProfilesView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "link")
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 40, height: 40)
                                .background(Theme.accent.opacity(0.12))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Profile verknüpfen").font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                                Text("Fupa, Fußball.de & mehr direkt verlinken")
                                    .font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.textFaint)
                        }
                        .padding(16)
                        .background(Theme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                        .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $showEdit) { EditProfileView() }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
    }

    private func stat(_ v: String, _ l: String) -> some View {
        VStack(spacing: 2) {
            Text(v).font(.pitchHead(20)).foregroundStyle(Theme.text)
            Text(l).font(.system(size: 11, weight: .bold)).kerning(0.5).foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }
    private func divider() -> some View { Rectangle().fill(Theme.line).frame(width: 1, height: 32) }
}

// MARK: - Beitrag erstellen (＋-Tab)

struct CreatePostView: View {
    var onDone: () -> Void = {}
    @State private var category = "Highlight"
    @State private var text = ""
    private let categories = ["Highlight", "Erfolg", "Information"]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Button(action: onDone) {
                        Image(systemName: "xmark").font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.textMuted)
                    }
                    Spacer()
                    Text("BEITRAG ERSTELLEN").font(.pitchHead(15)).kerning(0.5).foregroundStyle(Theme.text)
                    Spacer()
                    Image(systemName: "xmark").font(.system(size: 17)).opacity(0)
                }
                .padding(.horizontal, 20).padding(.vertical, 14)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionLabel("Kategorie")
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { c in
                                Chip(label: c, active: category == c).onTapGesture { category = c }
                            }
                        }

                        SectionLabel("Medien")
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.rMd).fill(Theme.surface)
                                .overlay(RoundedRectangle(cornerRadius: Theme.rMd)
                                    .stroke(Theme.line, style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                            VStack(spacing: 10) {
                                Image(systemName: "video.badge.plus").font(.system(size: 34)).foregroundStyle(Theme.textMuted)
                                Text("Clip oder Foto hinzufügen")
                                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textMuted)
                            }
                        }
                        .frame(height: 180)

                        SectionLabel("Text")
                        TextField("Was ist passiert?", text: $text, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Theme.text)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                            .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))

                        PitchButton(label: "Posten", action: onDone).padding(.top, 8)
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(Theme.scheme)
    }
}

// MARK: - Nachrichten

struct ChatRow: Identifiable {
    let id = UUID()
    let name: String
    let last: String
    let time: String
    let icon: String
    let unread: Bool
}

private let demoChats: [ChatRow] = [
    .init(name: "Coach Demir", last: "Pitch angenommen — lass uns reden!", time: "09:14", icon: "flame.fill", unread: true),
    .init(name: "TSV Eller 04", last: "Wann hättest du Zeit für ein Probetraining?", time: "gestern", icon: "trophy.fill", unread: true),
    .init(name: "Leon Bäcker", last: "Stark, danke dir!", time: "Mo", icon: "soccerball", unread: false),
]

struct MessagesView: View {
    @State private var showNewChat = false
    var body: some View {
        NavigationStack {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("NACHRICHTEN").font(.pitchHead(20)).kerning(1).foregroundStyle(Theme.text)
                    Spacer()
                    Button { showNewChat = true } label: {
                        Image(systemName: "square.and.pencil").font(.system(size: 18)).foregroundStyle(Theme.text)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(demoChats) { chat in
                            NavigationLink {
                                ChatView(person: PersonRef(name: chat.name, role: "", icon: chat.icon))
                            } label: {
                                HStack(spacing: 12) {
                                    Avatar(size: 48, systemName: chat.icon)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(chat.name).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                                        Text(chat.last).font(.system(size: 13)).foregroundStyle(Theme.textMuted).lineLimit(1)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text(chat.time).font(.system(size: 11)).foregroundStyle(Theme.textFaint)
                                        if chat.unread { Circle().fill(Theme.accent).frame(width: 9, height: 9) }
                                    }
                                }
                                .padding(.horizontal, 20).padding(.vertical, 14)
                                .overlay(Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 80), alignment: .bottom)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
        .sheet(isPresented: $showNewChat) { SearchView() }
    }
}

// MARK: - Mitteilungen

enum NotifType { case pitch, follow, comment, rating }

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotifType
    let senderName: String
    let icon: String
    let detail: String   // Bewertung, Kommentartext, etc.
    let time: String
}

private let demoNotifs: [NotificationItem] = [
    .init(type: .pitch,   senderName: "Coach Demir",  icon: "flame.fill",         detail: "",        time: "vor 3 Min"),
    .init(type: .follow,  senderName: "Leon Bäcker",  icon: "soccerball",         detail: "",        time: "vor 1 Std"),
    .init(type: .rating,  senderName: "Jonas Weber",  icon: "soccerball",         detail: "9.0",     time: "vor 2 Std"),
    .init(type: .comment, senderName: "TSV Eller 04", icon: "trophy.fill",        detail: "Stark!",  time: "gestern"),
]

struct NotificationsView: View {
    @State private var pitchStates:  [UUID: Bool] = [:]   // true=angenommen, false=abgelehnt
    @State private var followStates: [UUID: Bool] = [:]   // true=folge zurück

    var body: some View {
        NavigationStack {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("MITTEILUNGEN").font(.pitchHead(20)).kerning(1).foregroundStyle(Theme.text)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(demoNotifs) { n in
                            notifRow(n)
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .overlay(Rectangle().fill(Theme.line).frame(height: 1)
                                    .padding(.leading, 68), alignment: .bottom)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
    }

    @ViewBuilder
    private func notifRow(_ n: NotificationItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                // Avatar mit Typ-Badge
                ZStack(alignment: .bottomTrailing) {
                    Avatar(size: 44, systemName: n.icon)
                    typeBadge(n.type)
                }

                VStack(alignment: .leading, spacing: 3) {
                    // Name — tippt man auf Profil
                    NavigationLink {
                        UserProfileView(person: PersonRef(name: n.senderName, role: roleForIcon(n.icon), icon: n.icon))
                    } label: {
                        Text(n.senderName)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Theme.text)
                    }
                    .buttonStyle(.plain)

                    // Beschreibung
                    notifText(n)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textMuted)

                    Text(n.time)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.textFaint)
                }
                Spacer(minLength: 0)
            }

            // Aktions-Buttons je nach Typ
            switch n.type {
            case .pitch:
                pitchActions(n)
            case .follow:
                followAction(n)
            case .comment, .rating:
                // Kein Button — der Tap auf den Namen führt aufs Profil
                EmptyView()
            }
        }
    }

    // Pitch-Aktionen: Ablehnen (✗) + Annehmen (✓)
    @ViewBuilder
    private func pitchActions(_ n: NotificationItem) -> some View {
        if let accepted = pitchStates[n.id] {
            // Ergebnis anzeigen
            HStack(spacing: 6) {
                Image(systemName: accepted ? "bolt.fill" : "xmark")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(accepted ? Theme.accent : Theme.textFaint)
                Text(accepted ? "⚡ Pitch erfolgreich · Chat geöffnet" : "Abgelehnt")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(accepted ? Theme.accent : Theme.textFaint)
            }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background((accepted ? Theme.accent : Theme.surfaceAlt).opacity(accepted ? 0.12 : 1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
        } else {
            HStack(spacing: 10) {
                // Ablehnen
                Button {
                    withAnimation(.spring(duration: 0.2)) { pitchStates[n.id] = false }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity).frame(height: 40)
                        .background(Theme.danger.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                        .overlay(RoundedRectangle(cornerRadius: Theme.rMd)
                            .stroke(Theme.danger.opacity(0.3), lineWidth: 1))
                }
                .buttonStyle(.plain)

                // Annehmen
                Button {
                    withAnimation(.spring(duration: 0.2)) {
                        pitchStates[n.id] = true
                        // TODO: Firestore: vernetzen + Chat-Nachricht "⚡ Pitch erfolgreich" anlegen
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark").font(.system(size: 13, weight: .heavy))
                        Text("Annehmen").font(.system(size: 14, weight: .heavy))
                    }
                    .foregroundStyle(Theme.accentText)
                    .frame(maxWidth: .infinity).frame(height: 40)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // Follow-Aktion: Folgen / Folge ich (zurückfolgen — keine Vernetzung)
    @ViewBuilder
    private func followAction(_ n: NotificationItem) -> some View {
        Button {
            withAnimation(.spring(duration: 0.2)) {
                followStates[n.id] = true
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: followStates[n.id] == true ? "checkmark" : "plus")
                    .font(.system(size: 12, weight: .heavy))
                Text(followStates[n.id] == true ? "Folge ich" : "Folgen")
                    .font(.system(size: 13, weight: .heavy))
            }
            .foregroundStyle(followStates[n.id] == true ? Theme.accent : Theme.accentText)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(followStates[n.id] == true ? Theme.accent.opacity(0.12) : Theme.accent)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(
                followStates[n.id] == true ? Theme.accent : Color.clear, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func notifText(_ n: NotificationItem) -> Text {
        switch n.type {
        case .pitch:   return Text("hat dir einen Pitch gesendet")
        case .follow:  return Text("folgt dir jetzt")
        case .rating:  return Text("hat dein Highlight mit ") + Text(n.detail).bold().foregroundStyle(Theme.accent) + Text(" bewertet")
        case .comment: return Text("hat kommentiert: ") + Text(n.detail).italic()
        }
    }

    @ViewBuilder
    private func typeBadge(_ type: NotifType) -> some View {
        let (icon, color): (String, Color) = {
            switch type {
            case .pitch:   return ("bolt.fill",         Theme.accent)
            case .follow:  return ("person.badge.plus", Theme.success)
            case .rating:  return ("star.fill",         Theme.accent)
            case .comment: return ("bubble.left.fill",  Theme.textMuted)
            }
        }()
        Image(systemName: icon)
            .font(.system(size: 8, weight: .heavy))
            .foregroundStyle(Theme.bg)
            .frame(width: 16, height: 16)
            .background(color)
            .clipShape(Circle())
    }
}

// Pitch-Logo — aufsteigende Chevrons („Aufstieg", gewählt 03.06.2026)
struct PitchMark: View {
    var fg: Color
    var body: some View {
        GeometryReader { g in
            let w = g.size.width, h = g.size.height
            let lw = max(5, w * 0.12)
            ZStack {
                ForEach(0..<3) { i in
                    let dy = CGFloat(i) * h * 0.24
                    Path { p in
                        p.move(to: CGPoint(x: w*0.20, y: h*0.66 + dy))
                        p.addLine(to: CGPoint(x: w*0.5, y: h*0.42 + dy))
                        p.addLine(to: CGPoint(x: w*0.80, y: h*0.66 + dy))
                    }.stroke(fg.opacity(1 - Double(i) * 0.3),
                             style: StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

// MARK: - Suche (Spieler / Coaches / Vereine finden)

struct SearchResult: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let sub: String
    let icon: String
}

private let demoResults: [SearchResult] = [
    .init(name: "Jonas Weber", role: "Spieler", sub: "Stürmer · Landesliga · Köln", icon: "soccerball"),
    .init(name: "Mehmet Demir", role: "Coach", sub: "A-Lizenz · Oberliga · Düsseldorf", icon: "flame.fill"),
    .init(name: "SV Düsseldorf 04", role: "Verein", sub: "Bezirksliga · sucht Stürmer", icon: "trophy.fill"),
    .init(name: "Lena Groß", role: "Scout", sub: "Talentscout · NRW", icon: "binoculars.fill"),
    .init(name: "Tim Albers", role: "Spieler", sub: "Innenverteidiger · Kreisliga · Essen", icon: "soccerball"),
]

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var filter = "Alle"
    private let filters = ["Alle", "Spieler", "Coach", "Scout", "Verein"]

    var results: [SearchResult] {
        demoResults.filter { r in
            (filter == "Alle" || r.role == filter) &&
            (query.isEmpty || r.name.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        NavigationStack {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                // Suchfeld + Abbrechen
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(Theme.textMuted)
                        TextField("", text: $query,
                                  prompt: Text("Spieler, Vereine, Coaches…").foregroundColor(Theme.textFaint))
                            .foregroundStyle(Theme.text)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 14).frame(height: 44)
                    .background(Theme.surface).clipShape(Capsule())
                    .overlay(Capsule().stroke(Theme.line, lineWidth: 1))

                    Button("Abbrechen") { dismiss() }
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)

                // Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.self) { f in
                            Chip(label: f, active: filter == f).onTapGesture { filter = f }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 10)

                // Ergebnisse
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(results) { r in
                            NavigationLink {
                                UserProfileView(person: PersonRef(name: r.name, role: r.role, icon: r.icon, sub: r.sub))
                            } label: {
                                HStack(spacing: 12) {
                                    Avatar(size: 46, systemName: r.icon)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(r.name).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                                        Text("\(r.role) · \(r.sub)").font(.system(size: 12)).foregroundStyle(Theme.textMuted).lineLimit(1)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Theme.textFaint)
                                        .frame(width: 40, height: 40)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                .overlay(Rectangle().fill(Theme.line).frame(height: 1).padding(.leading, 74), alignment: .bottom)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
    }
}

#Preview("Feed") { FeedView() }
#Preview("Suche") { SearchView() }
#Preview("Mitteilungen") { NotificationsView() }
#Preview("Chats") { MessagesView() }
#Preview("Beitrag") { CreatePostView() }
#Preview("Profil") { ProfileView() }
