import SwiftUI
import PhotosUI

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

// Feed aus EINER Quelle: den Posts der Demo-Personen (verschachtelt, damit es lebt).
// Tippt man auf einen Autor, landet man auf seinem echten Profil.
private let demoPosts: [FeedPost] = makeDemoFeed()

private func makeDemoFeed() -> [FeedPost] {
    let reasons = ["In deiner Nähe", "Weil du Fußball folgst",
                   "Dein Kontakt hat das bewertet", "Dein Kontakt folgt dem Profil"]
    // pro Person die Liste ihrer Posts; danach round-robin verschachteln
    let lists = demoPeople.map { person in person.posts.map { (person, $0) } }
    let maxLen = lists.map(\.count).max() ?? 0
    var out: [FeedPost] = []
    var r = 0
    for idx in 0..<maxLen {
        for list in lists where idx < list.count {
            let (person, post) = list[idx]
            out.append(FeedPost(user: person.name, role: person.role, time: post.time,
                                category: post.category, rating: post.rating,
                                caption: post.caption, icon: post.icon,
                                reason: reasons[r % reasons.count]))
            r += 1
        }
    }
    return out
}

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
                        Avatar(size: 34, name: post.user)
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
                MediaThumb(seed: post.caption, icon: post.icon)
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

            // Aktionsleiste: [Bewerten] [💬 12]   (Pitch lebt auf dem Profil)
            HStack(spacing: 16) {
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

// MARK: - Beitrag-Detail (von Mitteilungen: Kommentar/Bewertung öffnet den Post)

struct PostDetailView: View {
    let post: FeedPost
    var openComments: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var draft = ""
    @State private var comments: [CommentItem] = [
        .init(name: "Coach Demir",  icon: "flame.fill",  text: "Saubere Technik! Wann kommst du mal vorbei?", time: "2 Std"),
        .init(name: "TSV Eller 04", icon: "trophy.fill", text: "Genau sowas suchen wir gerade.",            time: "1 Std"),
        .init(name: "Jonas Weber",  icon: "soccerball",  text: "Übelster Freistoß, Hut ab.",                time: "34 Min"),
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.system(size: 18, weight: .bold)).foregroundStyle(Theme.text)
                    }
                    Text("Beitrag").font(.pitchHead(18)).kerning(0.5).foregroundStyle(Theme.text)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.vertical, 14)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            // Autor
                            HStack(spacing: 10) {
                                Avatar(size: 38, name: post.user)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(post.user).font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.text)
                                    Text("\(post.role) · \(post.time)").font(.system(size: 11)).foregroundStyle(Theme.textMuted)
                                }
                                Spacer()
                                Chip(label: post.category)
                            }

                            // Medien
                            MediaThumb(seed: post.caption, icon: post.icon)
                                .frame(height: 300)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))

                            Text(post.caption).font(.system(size: 14)).foregroundStyle(Theme.text).lineSpacing(4)

                            Rectangle().fill(Theme.line).frame(height: 1).padding(.vertical, 2)

                            Text("Kommentare").font(.pitchHead(16)).foregroundStyle(Theme.text).id("comments")

                            ForEach(comments) { c in
                                HStack(alignment: .top, spacing: 12) {
                                    Avatar(size: 38, name: c.name)
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text(c.name).font(.system(size: 13, weight: .heavy)).foregroundStyle(Theme.text)
                                            Text(c.time).font(.system(size: 11)).foregroundStyle(Theme.textFaint)
                                        }
                                        Text(c.text).font(.system(size: 14)).foregroundStyle(Theme.text).lineSpacing(2)
                                    }
                                    Spacer(minLength: 0)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 24)
                    }
                    .onAppear {
                        guard openComments else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation { proxy.scrollTo("comments", anchor: .top) }
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
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(Theme.scheme)
    }
}

// MARK: - Profil

struct ProfileView: View {
    private let postIcons = ["soccerball", "trophy.fill", "flame.fill", "figure.soccer", "star.fill", "soccerball"]

    @AppStorage("appRole") private var appRole = "Spieler"
    private var isPlayer: Bool { appRole == "Spieler" }
    private var ownName: String { appRole == "Verein" ? "TSV Beispiel 04" : "Marvin Neumann" }

    @State private var showEdit = false
    @State private var showAttrPicker = false
    @State private var attributes: [String] = ["Schnelligkeit", "Zweikampf", "Kopfball"]
    @State private var bio = "Innenverteidiger mit Drang nach vorne. Suche den nächsten Schritt — ehrgeizig, teamfähig, immer am Limit."
    // Pitch-Nutzung diese Woche (Bar füllt sich mit Verbrauch)
    private let pitchesUsed = 3
    private let pitchesMax = 5

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

                    // Pitch-Nutzung — freistehend (keine Box), liegt direkt über den Stats
                    NavigationLink { PitchLimitView() } label: {
                        VStack(spacing: 6) {
                            HStack {
                                Text("Pitches diese Woche")
                                    .font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.textMuted)
                                Spacer()
                                Text("\(pitchesUsed)/\(pitchesMax)")
                                    .font(.system(size: 12, weight: .heavy)).foregroundStyle(Theme.text)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Theme.surfaceAlt)
                                    Capsule().fill(Theme.accent)
                                        .frame(width: geo.size.width * CGFloat(pitchesUsed) / CGFloat(pitchesMax))
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(.plain)

                    // Stats: Netzwerk (Zwei-Wege-Kontakte) · Follower · Folge ich (Content)
                    HStack(spacing: 0) {
                        NavigationLink { PitchesView() } label: {
                            statCol(value: "34", label: "NETZWERK")
                        }
                        .buttonStyle(.plain)

                        Rectangle().fill(Theme.line).frame(width: 1, height: 34)

                        NavigationLink { FollowersView(startTab: 0) } label: {
                            statCol(value: "248", label: "FOLLOWER")
                        }
                        .buttonStyle(.plain)

                        Rectangle().fill(Theme.line).frame(width: 1, height: 34)

                        NavigationLink { FollowersView(startTab: 1) } label: {
                            statCol(value: "96", label: "FOLGE ICH")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 16)
                    .background(Theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                    .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))

                    if isPlayer {
                        PitchCard(roleLabel: "Spieler", attributes: attributes, onAddAttribute: { showAttrPicker = true })
                    } else {
                        ActorCard(name: ownName, roleLabel: appRole, bio: bio)
                    }

                    PitchButton(label: "Profil bearbeiten", variant: .ghost, systemImage: "pencil") { showEdit = true }

                    // Info über mich (Bio) — bei Akteuren steckt die Bio schon in der ActorCard
                    if isPlayer {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Info über mich")
                            Text(bio)
                                .font(.system(size: 13)).foregroundStyle(Theme.text).lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(Theme.surface)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.rLg))
                                .overlay(RoundedRectangle(cornerRadius: Theme.rLg).stroke(Theme.line, lineWidth: 1))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

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

                    // Exposé + Profil-Verknüpfung sind Spieler-Features (Scouting)
                    if isPlayer {
                    // Cloud-Link zu persönlichen Highlights (Exposé)
                    NavigationLink { ExposeView() } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "icloud.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 40, height: 40)
                                .background(Theme.accent.opacity(0.12))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Meine Highlights (Cloud)").font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                                Text("Clips & Dateien — sichtbar nach erfolgreichem Pitch")
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
                    } // Ende Spieler-Features (Exposé)

                    // Profile verknüpfen — für alle Rollen (rollenabhängige Felder)
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
            .navigationDestination(isPresented: $showEdit) { EditProfileView(role: appRole) }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
        .sheet(isPresented: $showAttrPicker) {
            AttributePicker(selected: $attributes, role: "Spieler")
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func statCol(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.pitchHead(20)).foregroundStyle(Theme.text)
            Text(label).font(.system(size: 9, weight: .heavy)).kerning(0.8)
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
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
    @State private var selectedMedia: PhotosPickerItem? = nil
    @State private var mediaImage: UIImage? = nil
    @State private var showSourceDialog = false
    @State private var showPhotoPicker = false
    @State private var showTagPeople = false
    @State private var taggedPeople: [String] = []
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
                        Button { showSourceDialog = true } label: {
                            ZStack {
                                if let img = mediaImage {
                                    Image(uiImage: img).resizable().scaledToFill()
                                } else {
                                    RoundedRectangle(cornerRadius: Theme.rMd).fill(Theme.surface)
                                        .overlay(RoundedRectangle(cornerRadius: Theme.rMd)
                                            .stroke(Theme.line, style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                                    VStack(spacing: 10) {
                                        Image(systemName: "video.badge.plus").font(.system(size: 34)).foregroundStyle(Theme.textMuted)
                                        Text("Clip oder Foto hinzufügen")
                                            .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textMuted)
                                    }
                                }
                            }
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                        }
                        .buttonStyle(.plain)

                        SectionLabel("Text")
                        TextField("Was ist passiert?", text: $text, axis: .vertical)
                            .lineLimit(3...6)
                            .foregroundStyle(Theme.text)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                            .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))

                        // Personen markieren
                        Button { showTagPeople = true } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.accent)
                                Text(taggedPeople.isEmpty ? "Personen markieren"
                                     : taggedPeople.joined(separator: ", "))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(taggedPeople.isEmpty ? Theme.textMuted : Theme.text)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textFaint)
                            }
                            .padding(14)
                            .background(Theme.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
                            .overlay(RoundedRectangle(cornerRadius: Theme.rMd).stroke(Theme.line, lineWidth: 1))
                        }
                        .buttonStyle(.plain)

                        PitchButton(label: "Posten", action: onDone).padding(.top, 8)
                    }
                    .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(Theme.scheme)
        .confirmationDialog("Medien hinzufügen", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("Fotos & Videos") { showPhotoPicker = true }
            Button("Dateien") { showPhotoPicker = true }  // TODO: fileImporter für Dokumente
            Button("Abbrechen", role: .cancel) { }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedMedia, matching: .any(of: [.images, .videos]))
        .onChange(of: selectedMedia) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    await MainActor.run { mediaImage = img }
                }
            }
        }
        .sheet(isPresented: $showTagPeople) {
            TagPeopleView(selected: $taggedPeople)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

// Personen markieren (Sheet) — Nutzer/Scouts/Coaches suchen & antippen
struct TagPeopleView: View {
    @Binding var selected: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    private let people: [(String, String, String)] = [
        ("Jonas Weber", "Spieler · Köln", "soccerball"),
        ("Mehmet Demir", "Coach · Düsseldorf", "flame.fill"),
        ("Lena Groß", "Scout · NRW", "binoculars.fill"),
        ("TSV Eller 04", "Verein · Bezirksliga", "trophy.fill"),
        ("Tim Albers", "Spieler · Essen", "soccerball"),
    ]
    private var filtered: [(String, String, String)] {
        query.isEmpty ? people : people.filter { $0.0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("MARKIEREN").font(.pitchHead(18)).kerning(0.5).foregroundStyle(Theme.text)
                    Spacer()
                    Button("Fertig") { dismiss() }
                        .font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.accent)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .bottom)

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass").foregroundStyle(Theme.textMuted)
                    TextField("", text: $query, prompt: Text("Nutzer suchen…").foregroundColor(Theme.textFaint))
                        .foregroundStyle(Theme.text).autocorrectionDisabled()
                }
                .padding(.horizontal, 14).frame(height: 44)
                .background(Theme.surface).clipShape(Capsule())
                .overlay(Capsule().stroke(Theme.line, lineWidth: 1))
                .padding(.horizontal, 20).padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filtered, id: \.0) { p in
                            let active = selected.contains(p.0)
                            Button {
                                withAnimation(.easeOut(duration: 0.12)) {
                                    if active { selected.removeAll { $0 == p.0 } } else { selected.append(p.0) }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Avatar(size: 42, name: p.0)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(p.0).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                                        Text(p.1).font(.system(size: 12)).foregroundStyle(Theme.textMuted)
                                    }
                                    Spacer()
                                    Image(systemName: active ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20)).foregroundStyle(active ? Theme.accent : Theme.line)
                                }
                                .padding(.horizontal, 20).padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
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
    .init(name: "Lena Groß", last: "Hab dich am Samstag spielen sehen — stark!", time: "Di", icon: "binoculars.fill", unread: true),
    .init(name: "Jonas Weber", last: "Kommst du Freitag zum Training?", time: "Di", icon: "soccerball", unread: false),
    .init(name: "Leon Bäcker", last: "Stark, danke dir!", time: "Mo", icon: "soccerball", unread: false),
    .init(name: "SV Düsseldorf 04", last: "Wir melden uns nächste Woche bei dir.", time: "So", icon: "trophy.fill", unread: false),
    .init(name: "Marco Stein", last: "Brudi, der Doppelpack 🤝", time: "Sa", icon: "soccerball", unread: false),
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
                        Image(systemName: "magnifyingglass").font(.system(size: 18, weight: .semibold)).foregroundStyle(Theme.text)
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
                                    Avatar(size: 48, name: chat.name)
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
    .init(type: .pitch,   senderName: "Coach Demir",     icon: "flame.fill",      detail: "",                  time: "vor 3 Min"),
    .init(type: .pitch,   senderName: "Lena Groß",       icon: "binoculars.fill", detail: "",                  time: "vor 25 Min"),
    .init(type: .follow,  senderName: "Leon Bäcker",     icon: "soccerball",      detail: "",                  time: "vor 1 Std"),
    .init(type: .rating,  senderName: "Jonas Weber",     icon: "soccerball",      detail: "9.0",               time: "vor 2 Std"),
    .init(type: .comment, senderName: "TSV Eller 04",    icon: "trophy.fill",     detail: "Genau sowas suchen wir.", time: "vor 3 Std"),
    .init(type: .follow,  senderName: "Marco Stein",     icon: "soccerball",      detail: "",                  time: "vor 5 Std"),
    .init(type: .pitch,   senderName: "SV Düsseldorf 04", icon: "trophy.fill",    detail: "",                  time: "gestern"),
    .init(type: .rating,  senderName: "Tim Albers",      icon: "soccerball",      detail: "8.5",               time: "gestern"),
    .init(type: .comment, senderName: "Coach Demir",     icon: "flame.fill",      detail: "Saubere Technik!",  time: "vor 2 Tagen"),
]

struct NotificationsView: View {
    @State private var pitchStates:  [UUID: Bool] = [:]   // true=angenommen, false=abgelehnt
    @State private var followStates: [UUID: Bool] = [:]   // true=folgt zurück (reiner Content-Follow)

    // Repräsentativer eigener Beitrag — Kommentar/Bewertung öffnet ihn
    private var ownPost: FeedPost {
        FeedPost(user: "Marvin Neumann", role: "Spieler", time: "vor 3 Std", category: "Highlight",
                 rating: "8.9", caption: "Freistoßtor von der Strafraumkante. Wochenende war stark.",
                 icon: "soccerball", reason: "Dein Beitrag")
    }

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
        // Kompakte Zeile: Avatar · Text · Aktionen rechts daneben
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Avatar(size: 44, name: n.senderName)
                typeBadge(n.type)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    NavigationLink {
                        UserProfileView(person: PersonRef(name: n.senderName, role: roleForIcon(n.icon), icon: n.icon))
                    } label: {
                        Text(n.senderName)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Theme.text)
                    }
                    .buttonStyle(.plain)
                    // Pitch-Kennzeichnung (Glitzer)
                    if n.type == .pitch {
                        HStack(spacing: 3) {
                            Image(systemName: "sparkles").font(.system(size: 9, weight: .heavy))
                            Text("PITCH").font(.system(size: 9, weight: .heavy)).kerning(0.5)
                        }
                        .foregroundStyle(Theme.accent)
                    }
                }
                notifText(n)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textMuted)
                    .lineLimit(2)
                Text(n.time).font(.system(size: 10)).foregroundStyle(Theme.textFaint)
            }

            Spacer(minLength: 6)

            rightActions(n)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(
            // offene Pitches dezent hervorheben (statischer Tint, kein Effekt)
            (n.type == .pitch && pitchStates[n.id] == nil ? Theme.accent.opacity(0.06) : Color.clear)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.rMd))
    }

    // Aktionen rechts: kleine Kästchen — gleiche Form bei Pitch & Follow
    @ViewBuilder
    private func rightActions(_ n: NotificationItem) -> some View {
        let person = PersonRef(name: n.senderName, role: roleForIcon(n.icon), icon: n.icon)
        switch n.type {
        case .pitch:
            if let accepted = pitchStates[n.id] {
                if accepted {
                    // angenommen → Lime-Haken (Pitch-Style); Chat öffnet beim Tippen
                    NavigationLink {
                        ChatView(person: person)
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundStyle(Theme.accentText)
                            .frame(width: 34, height: 34)
                            .background(Theme.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .buttonStyle(.plain)
                } else {
                    // abgelehnt → dezentes X, gedämpft
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(Theme.textFaint)
                        .frame(width: 34, height: 34)
                        .background(Theme.surfaceAlt)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
            } else {
                // offen → dezentes X (ablehnen) + Lime-Haken (annehmen), im Pitch-Style
                HStack(spacing: 8) {
                    squareBtn("xmark", fg: Theme.textMuted, bg: Theme.surfaceAlt, border: true) {
                        withAnimation(.spring(duration: 0.2)) { pitchStates[n.id] = false }
                    }
                    squareBtn("checkmark", fg: Theme.accentText, bg: Theme.accent, border: false) {
                        withAnimation(.spring(duration: 0.2)) { pitchStates[n.id] = true }
                        // TODO: Firestore: Chat freischalten + System-Nachricht "⚡ Pitch erfolgreich"
                    }
                }
            }
        case .follow:
            if followStates[n.id] == true {
                // zurückgefolgt → reiner Content-Follow, KEIN Chat (Chat nur via Pitch)
                // nur ein gedämpfter Haken (gleiche 34×34-Form, kein Layout-Sprung)
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Theme.textMuted)
                    .frame(width: 34, height: 34)
                    .background(Theme.surfaceAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Theme.line, lineWidth: 1))
            } else {
                squareBtn("plus", fg: Theme.accentText, bg: Theme.accent, border: false) {
                    withAnimation(.spring(duration: 0.2)) { followStates[n.id] = true }
                }
            }
        case .comment, .rating:
            // führt zum Beitrag; bei Kommentar scrollt es direkt zur Kommentarsektion
            NavigationLink {
                PostDetailView(post: ownPost, openComments: n.type == .comment)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(Theme.text)
                    .frame(width: 34, height: 34)
                    .background(Theme.surfaceAlt)
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Theme.text.opacity(0.3), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    private func squareBtn(_ icon: String, fg: Color, bg: Color, border: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(fg)
                .frame(width: 34, height: 34)
                .background(bg)
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .stroke(border ? fg.opacity(0.3) : Color.clear, lineWidth: 1))
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
                                    Avatar(size: 46, name: r.name)
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
