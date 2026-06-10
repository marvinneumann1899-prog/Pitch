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
    var image: String? = nil   // gebündelter Clip
    var authorId: String? = nil   // Firestore-uid des Autors (echte Posts)

    var person: PersonRef { PersonRef(name: user, role: role, icon: icon, rating: rating, uid: authorId) }
}

// Echte Beiträge aus Firestore → Feed-Karten
private func makeRealFeed() async -> [FeedPost] {
    await SocialStore.shared.fetchPosts().map { p in
        FeedPost(user: p.authorName, role: p.authorRole, time: timeAgo(p.createdAt),
                 category: p.category, rating: nil, caption: p.caption,
                 icon: iconForRole(p.authorRole), reason: "", image: nil, authorId: p.authorId)
    }
}

struct FeedView: View {
    @State private var showSearch = false
    @State private var ratingLock = false   // sperrt den Scroll, während bewertet wird
    @State private var posts: [FeedPost] = []
    @State private var loaded = false
    @StateObject private var social = SocialStore.shared
    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()
                VStack(spacing: 0) {
                    // Schwebender, randloser Header
                    HStack {
                        Button { showSearch = true } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.text)
                                .frame(width: 40, height: 40)
                                .glassCard(Theme.rPill)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Text("PITCH").font(.pitchDisplay(22)).kerning(2)
                            .foregroundStyle(Theme.text)
                        Spacer()
                        Color.clear.frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 18).padding(.vertical, 8)

                    PitchRefresh(scrollLocked: ratingLock) {
                        posts = await makeRealFeed()
                    } content: {
                        LazyVStack(spacing: 8) {
                            if loaded && posts.isEmpty {
                                VStack(spacing: 12) {
                                    PitchMark(fg: Theme.accent).frame(width: 40, height: 40)
                                    Text("Noch keine Beiträge").font(.pitchHead(17)).foregroundStyle(Theme.text)
                                    Text("Poste dein erstes Highlight über das ＋ unten\noder folge Leuten über die Suche.")
                                        .font(.system(size: 13)).foregroundStyle(Theme.textMuted)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity).padding(.vertical, 80)
                                .glassCard()
                                .padding(.horizontal, 16).padding(.top, 40)
                            }
                            ForEach(posts) { post in
                                PostCard(post: post, onRatingActive: { ratingLock = $0 })
                            }
                        }
                        .padding(.top, 4).padding(.bottom, 16)   // randlos: volle Breite
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
        .sheet(isPresented: $showSearch) { SearchView() }
        .task(id: social.feedVersion) {
            posts = await makeRealFeed()
            loaded = true
        }
    }
}

// Feed-Karte: quadratisches Medium (nichts beschnitten), alle Infos als dunkles
// Liquid-Glas darauf. showHeader=false → ohne Name-Pille (für eigenes Profil).
private struct PostCard: View {
    let post: FeedPost
    var showHeader: Bool = true
    var onRatingActive: (Bool) -> Void = { _ in }   // true = Feed-Scroll sperren
    @State private var ratingActive = false
    @State private var ratingValue: Double = 8.0
    @State private var following = false
    @State private var showComments = false

    private var showRating: Bool { post.role == "Spieler" && post.rating != nil }

    var body: some View {
        // Vordergrund = Steuerelemente (immer tappbar); Medium liegt als Hintergrund dahinter.
        VStack(spacing: 0) {
            topRow
            Spacer(minLength: 0)
            bottomGlass.opacity(ratingActive ? 0 : 1)   // bleibt montiert → Geste reißt nicht ab
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            ZStack {
                MediaThumb(seed: post.caption, icon: post.icon, imageName: post.image, showPlay: true, playSize: 58)
                    .clipped()
                LinearGradient(colors: [.clear, .black.opacity(0.35)], startPoint: .center, endPoint: .bottom)
            }
            .allowsHitTesting(false)
        }
        .containerRelativeFrame(.vertical) { length, _ in length * 0.74 }
        .overlay(alignment: .bottomLeading) {
            if ratingActive {
                RatingBar(value: ratingValue)
                    .padding(.leading, 22).padding(.bottom, 18)
                    .transition(.scale(scale: 0.2, anchor: .bottomLeading).combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.rLg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.rLg, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.6)
                .allowsHitTesting(false)
        )
        .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
        .sheet(isPresented: $showComments) {
            CommentsView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    // Oben: Name-Pille (links, nur im Feed) + Rating-Pille (rechts)
    private var topRow: some View {
        HStack(alignment: .top, spacing: 8) {
            if showHeader {
                HStack(spacing: 9) {
                    NavigationLink { UserProfileView(person: post.person) } label: {
                        HStack(spacing: 9) {
                            Avatar(size: 30, name: post.user)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(post.user).font(.system(size: 13, weight: .heavy)).foregroundStyle(.white)
                                Text("\(post.role) · \(post.time)").font(.system(size: 10)).foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    if let authorId = post.authorId, authorId != AuthService.shared.user?.uid {
                        Button {
                            withAnimation(.spring(duration: 0.2)) { following = true }
                            Task { await SocialStore.shared.follow(id: authorId, name: post.user, role: post.role) }
                        } label: {
                            Image(systemName: following ? "checkmark" : "plus")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(following ? Theme.accent : .black)
                                .frame(width: 22, height: 22)
                                .background(following ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(Theme.accent))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.leading, 6).padding(.trailing, 10).padding(.vertical, 6)
                .mediaGlass(Theme.rPill)
            }

            Spacer(minLength: 0)

            if showRating, let r = post.rating {
                HStack(spacing: 4) {
                    PitchMark(fg: Theme.glow).frame(width: 13, height: 13)
                    Text(r).font(.system(size: 14, weight: .black)).foregroundStyle(Theme.glow)
                }
                .padding(.horizontal, 11).padding(.vertical, 7)
                .mediaGlass(Theme.rPill)
            }
        }
    }

    // Unten: schmaler Streifen — Bewerten + Kommentar + Beschreibung (mit „mehr")
    private var bottomGlass: some View {
        HStack(spacing: 12) {
            // Bewerten — Logo halten + nach RECHTS wischen (7 → 10). Horizontal = kein Scroll-Konflikt.
            PitchMark(fg: .black)
                .padding(7)
                .frame(width: 34, height: 34)
                .background(Theme.glow)
                .clipShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { g in
                            if !ratingActive {
                                withAnimation(.easeOut(duration: 0.12)) { ratingActive = true }
                                onRatingActive(true)   // Feed-Scroll sperren
                            }
                            let v = 8.5 + Double(-g.translation.height) / 24.0
                            ratingValue = min(10, max(7, (v * 10).rounded() / 10))
                        }
                        .onEnded { _ in
                            withAnimation(.easeOut(duration: 0.15)) { ratingActive = false }
                            onRatingActive(false)
                        }
                )

            Button { showComments = true } label: {
                HStack(spacing: 5) {
                    Image(systemName: "bubble.left").font(.system(size: 18)).foregroundStyle(.white)
                    Text("12").font(.system(size: 12, weight: .bold)).foregroundStyle(.white.opacity(0.85))
                }
            }
            .buttonStyle(.plain)

            Text(post.caption)
                .font(.system(size: 12)).foregroundStyle(.white.opacity(0.9))
                .lineLimit(1)
            Spacer(minLength: 2)

            // „mehr" öffnet den ganzen Beitrag (kein janky Inline-Aufklappen)
            NavigationLink { PostDetailView(post: post) } label: {
                Text("mehr").font(.system(size: 12, weight: .heavy)).foregroundStyle(Theme.glow)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12).padding(.vertical, 9)
        .mediaGlass(Theme.rMd)
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
                            MediaThumb(seed: post.caption, icon: post.icon, imageName: post.image)
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
    @AppStorage("userName") private var userName = ""
    private var isPlayer: Bool { appRole == "Spieler" }
    private var ownName: String {
        if !userName.isEmpty { return userName }                       // echter Name (Onboarding/Firestore)
        return appRole == "Verein" ? "TSV Beispiel 04" : "Marvin Neumann"
    }

    @State private var showEdit = false
    @State private var showAttrPicker = false
    @State private var attributes: [String] = ["Schnelligkeit", "Zweikampf", "Kopfball"]
    @State private var bio = ""

    // Echte Daten aus Firestore
    @State private var followerCount = 0
    @State private var followingCount = 0
    @State private var ownPosts: [FeedPost] = []
    @StateObject private var social = SocialStore.shared

    private func loadOwn() async {
        if let p = ProfileStore.shared.profile, !p.bio.isEmpty { bio = p.bio }
        followerCount = await SocialStore.shared.fetchRelations(kind: "followers").count
        followingCount = await SocialStore.shared.fetchRelations(kind: "following").count
        let myUid = AuthService.shared.user?.uid
        ownPosts = await SocialStore.shared.fetchPosts()
            .filter { $0.authorId == myUid }
            .map { FeedPost(user: $0.authorName, role: $0.authorRole, time: timeAgo($0.createdAt),
                            category: $0.category, rating: nil, caption: $0.caption,
                            icon: iconForRole($0.authorRole), reason: "", authorId: $0.authorId) }
    }

    var body: some View {
        NavigationStack {
        ZStack {
            AmbientBackground()
            PitchRefresh {
                await loadOwn()
            } content: {
                VStack(spacing: 16) {
                    HStack {
                        Text("PROFIL").font(.pitchHead(24)).kerning(1).foregroundStyle(Theme.text)
                        Spacer()
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 17)).foregroundStyle(Theme.text)
                                .frame(width: 40, height: 40)
                                .glassCard(Theme.rPill)
                        }
                        .buttonStyle(.plain)
                    }

                    // Stats: Beiträge · Follower · Folge ich — alles echte Zahlen
                    HStack(spacing: 0) {
                        statCol(value: "\(ownPosts.count)", label: "BEITRÄGE")

                        Rectangle().fill(Theme.line.opacity(0.6)).frame(width: 1, height: 30)

                        NavigationLink { FollowersView(startTab: 0) } label: {
                            statCol(value: "\(followerCount)", label: "FOLLOWER")
                        }
                        .buttonStyle(.plain)

                        Rectangle().fill(Theme.line.opacity(0.6)).frame(width: 1, height: 30)

                        NavigationLink { FollowersView(startTab: 1) } label: {
                            statCol(value: "\(followingCount)", label: "FOLGE ICH")
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 18)
                    .glassCard()

                    if isPlayer {
                        PitchCard(name: ownName, roleLabel: "Spieler", attributes: attributes, onAddAttribute: { showAttrPicker = true })
                    } else {
                        ActorCard(name: ownName, roleLabel: appRole, bio: bio)
                    }

                    PitchButton(label: "Profil bearbeiten", variant: .ghost, systemImage: "pencil") { showEdit = true }

                    // Info über mich (Bio) — bei Akteuren steckt die Bio schon in der ActorCard
                    if isPlayer {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionLabel("Info über mich")
                            Text(bio.isEmpty ? "Noch keine Info — füge über Profil bearbeiten eine kurze Beschreibung hinzu." : bio)
                                .font(.system(size: 13))
                                .foregroundStyle(bio.isEmpty ? Theme.textMuted : Theme.text).lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .glassCard()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Deine Beiträge — EIN Fenster über die ganze Breite, innen scrollbar.
                    // Beiträge 1:1 wie im Feed (Rating, Beschreibung, Kommentar, Bewerten) — nur ohne Kopf.
                    VStack(alignment: .leading, spacing: 10) {
                        SectionLabel("Deine Beiträge")
                        if ownPosts.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.square.dashed").font(.system(size: 26)).foregroundStyle(Theme.textFaint)
                                Text("Noch keine Beiträge").font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
                                Text("Poste dein erstes Highlight über das ＋ unten.")
                                    .font(.system(size: 12)).foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 40)
                            .glassCard()
                        } else {
                            ScrollView(showsIndicators: false) {
                                LazyVStack(spacing: 14) {
                                    ForEach(ownPosts) { PostCard(post: $0, showHeader: false) }
                                }
                                .padding(12)
                            }
                            .frame(height: 460)
                            .glassCard()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Exposé + Profil-Verknüpfung sind Spieler-Features (Scouting)
                    if isPlayer {
                    // Cloud-Link zu persönlichen Highlights (Exposé)
                    NavigationLink { ExposeView() } label: {
                        rowCard(icon: "icloud.fill", title: "Meine Highlights (Cloud)",
                                sub: "Clips & Dateien für interessierte Vereine & Coaches")
                    }
                    .buttonStyle(.plain)
                    } // Ende Spieler-Features (Exposé)

                    // Profile verknüpfen — für alle Rollen (rollenabhängige Felder)
                    NavigationLink { LinkProfilesView() } label: {
                        rowCard(icon: "link", title: "Profile verknüpfen",
                                sub: "Fupa, Fußball.de & mehr direkt verlinken")
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 40)
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
        .task(id: social.feedVersion) { await loadOwn() }
    }

    private func statCol(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value).font(.pitchHead(20)).foregroundStyle(Theme.text)
            Text(label).font(.system(size: 9, weight: .heavy)).kerning(0.8)
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // Glas-Zeile mit Icon + Titel + Untertitel (für Exposé / Verknüpfen)
    private func rowCard(icon: String, title: String, sub: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(Theme.accent)
                .frame(width: 40, height: 40)
                .background(Theme.accent.opacity(0.12))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 15, weight: .heavy)).foregroundStyle(Theme.text)
                Text(sub).font(.system(size: 11)).foregroundStyle(Theme.textMuted)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.textFaint)
        }
        .padding(16)
        .glassCard()
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
    @State private var posting = false
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

                        PitchButton(label: posting ? "Wird gepostet…" : "Posten") {
                            let caption = text.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !caption.isEmpty, !posting else { return }
                            posting = true
                            Task { @MainActor in
                                await SocialStore.shared.createPost(caption: caption, category: category)
                                posting = false
                                text = ""
                                onDone()
                            }
                        }
                        .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                        .padding(.top, 8)
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
    var uid: String? = nil    // Gegenseite (Firestore)
    var role: String = ""
}

struct MessagesView: View {
    @State private var showNewChat = false
    @State private var realChats: [ChatRow] = []
    @State private var chatsLoaded = false

    // Echte Chats aus Firestore → Zeilen (Name/Rolle der Gegenseite + letzte Nachricht)
    private func loadChats() async {
        let myUid = AuthService.shared.user?.uid
        realChats = await SocialStore.shared.fetchChats().compactMap { c in
            guard let other = c.participants.first(where: { $0 != myUid }) else { return nil }
            return ChatRow(name: c.names[other] ?? "?", last: c.lastMessage,
                           time: timeAgo(c.lastAt), icon: iconForRole(c.roles[other] ?? "Spieler"),
                           unread: false, uid: other, role: c.roles[other] ?? "")
        }
        chatsLoaded = true
    }

    var body: some View {
        NavigationStack {
        ZStack {
            AmbientBackground()
            VStack(spacing: 0) {
                HStack {
                    Text("NACHRICHTEN").font(.pitchHead(20)).kerning(1).foregroundStyle(Theme.text)
                    Spacer()
                    Button { showNewChat = true } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17, weight: .semibold)).foregroundStyle(Theme.text)
                            .frame(width: 40, height: 40)
                            .glassCard(Theme.rPill)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18).padding(.vertical, 8)

                PitchRefresh {
                    await loadChats()
                } content: {
                    VStack(spacing: 8) {
                        if chatsLoaded && realChats.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 26)).foregroundStyle(Theme.textFaint)
                                Text("Noch keine Chats").font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
                                Text("Finde Leute über die Lupe und schreib ihnen.")
                                    .font(.system(size: 12)).foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 60)
                        }
                        ForEach(realChats) { chat in
                            NavigationLink {
                                ChatView(person: PersonRef(name: chat.name, role: chat.role, icon: chat.icon, uid: chat.uid))
                            } label: {
                                HStack(spacing: 12) {
                                    Avatar(size: 50, name: chat.name)
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
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .glassCard(Theme.rLg)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8).padding(.top, 4).padding(.bottom, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
        .sheet(isPresented: $showNewChat) { SearchView() }
        .task { await loadChats() }
    }
}

// MARK: - Mitteilungen

enum NotifType { case follow, comment, rating }

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotifType
    let senderName: String
    let icon: String
    let detail: String   // Bewertung, Kommentartext, etc.
    let time: String
}

struct NotificationsView: View {
    @State private var followStates: [UUID: Bool] = [:]   // true=folgt zurück
    @State private var items: [NotificationItem] = []
    @State private var uidByItem: [UUID: String] = [:]    // Mitteilung → Absender-uid
    @State private var notifsLoaded = false

    // Echte Mitteilungen (Follows) aus Firestore
    private func loadNotifs() async {
        let docs = await SocialStore.shared.fetchNotifications()
        var mapped: [NotificationItem] = []
        var uids: [UUID: String] = [:]
        for d in docs {
            let item = NotificationItem(type: .follow, senderName: d.fromName,
                                        icon: iconForRole(d.fromRole), detail: "",
                                        time: timeAgo(d.createdAt))
            mapped.append(item)
            uids[item.id] = d.fromId
        }
        items = mapped
        uidByItem = uids
        notifsLoaded = true
    }

    var body: some View {
        NavigationStack {
        ZStack {
            AmbientBackground()
            VStack(spacing: 0) {
                HStack {
                    Text("MITTEILUNGEN").font(.pitchHead(20)).kerning(1).foregroundStyle(Theme.text)
                    Spacer()
                }
                .padding(.horizontal, 20).padding(.vertical, 10)

                PitchRefresh {
                    await loadNotifs()
                } content: {
                    VStack(spacing: 8) {
                        if notifsLoaded && items.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "bell").font(.system(size: 26)).foregroundStyle(Theme.textFaint)
                                Text("Noch keine Mitteilungen").font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
                                Text("Hier siehst du, wenn dir jemand folgt.")
                                    .font(.system(size: 12)).foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 60)
                        }
                        ForEach(items) { n in
                            notifRow(n)
                                .padding(.horizontal, 14).padding(.vertical, 12)
                                .glassCard(Theme.rLg)
                        }
                    }
                    .padding(.horizontal, 8).padding(.top, 4).padding(.bottom, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        }
        .preferredColorScheme(Theme.scheme)
        .task { await loadNotifs() }
    }

    @ViewBuilder
    private func notifRow(_ n: NotificationItem) -> some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Avatar(size: 44, name: n.senderName)
                typeBadge(n.type)
            }

            VStack(alignment: .leading, spacing: 2) {
                NavigationLink {
                    UserProfileView(person: PersonRef(name: n.senderName, role: roleForIcon(n.icon), icon: n.icon, uid: uidByItem[n.id]))
                } label: {
                    Text(n.senderName).font(.system(size: 14, weight: .heavy)).foregroundStyle(Theme.text)
                }
                .buttonStyle(.plain)

                notifText(n)
                    .font(.system(size: 12)).foregroundStyle(Theme.textMuted).lineLimit(2)
                Text(n.time).font(.system(size: 10)).foregroundStyle(Theme.textFaint)
            }

            Spacer(minLength: 6)

            rightActions(n)
        }
    }

    @ViewBuilder
    private func rightActions(_ n: NotificationItem) -> some View {
        switch n.type {
        case .follow:
            if followStates[n.id] == true {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 36, height: 36)
                    .background(Theme.accent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
            } else {
                Button {
                    withAnimation(.spring(duration: 0.2)) { followStates[n.id] = true }
                    if let uid = uidByItem[n.id] {
                        Task { await SocialStore.shared.follow(id: uid, name: n.senderName, role: roleForIcon(n.icon)) }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .heavy))
                        .foregroundStyle(Theme.accentText)
                        .frame(width: 36, height: 36)
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        case .comment, .rating:
            // (kommt mit echten Kommentaren/Bewertungen)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(Theme.text)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
    }

    private func notifText(_ n: NotificationItem) -> Text {
        switch n.type {
        case .follow:  return Text("folgt dir jetzt")
        case .rating:  return Text("hat dein Highlight mit ") + Text(n.detail).bold().foregroundStyle(Theme.accent) + Text(" bewertet")
        case .comment: return Text("hat kommentiert: ") + Text(n.detail).italic()
        }
    }

    @ViewBuilder
    private func typeBadge(_ type: NotifType) -> some View {
        let (icon, color): (String, Color) = {
            switch type {
            case .follow:  return ("person.badge.plus", Theme.accent)
            case .rating:  return ("star.fill",         Theme.accent)
            case .comment: return ("bubble.left.fill",  Theme.textMuted)
            }
        }()
        Image(systemName: icon)
            .font(.system(size: 8, weight: .heavy))
            .foregroundStyle(.white)
            .frame(width: 16, height: 16)
            .background(color)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
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
    var uid: String? = nil
}

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var filter = "Alle"
    @State private var allUsers: [SearchResult] = []
    private let filters = ["Alle", "Spieler", "Coach", "Scout", "Verein"]

    var results: [SearchResult] {
        allUsers.filter { r in
            (filter == "Alle" || normalizedRole(r.role) == normalizedRole(filter)) &&
            (query.isEmpty || r.name.localizedCaseInsensitiveContains(query))
        }
    }

    // Echte registrierte User aus Firestore laden (ohne dich selbst)
    private func loadUsers() async {
        let myUid = AuthService.shared.user?.uid
        let users = await ProfileStore.shared.fetchAllUsers().filter { $0.id != myUid }
        allUsers = users.map { u in
            let sub = [u.profile.club, u.profile.location].filter { !$0.isEmpty }.joined(separator: " · ")
            return SearchResult(name: u.profile.name.isEmpty ? "Ohne Namen" : u.profile.name,
                                role: u.profile.role,
                                sub: sub.isEmpty ? "Neu bei Pitch" : sub,
                                icon: iconForRole(u.profile.role),
                                uid: u.id)
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
                        if results.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "person.2").font(.system(size: 28)).foregroundStyle(Theme.textFaint)
                                Text(allUsers.isEmpty ? "Noch keine registrierten Nutzer" : "Keine Treffer")
                                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(Theme.textMuted)
                            }
                            .frame(maxWidth: .infinity).padding(.top, 60)
                        }
                        ForEach(results) { r in
                            NavigationLink {
                                UserProfileView(person: PersonRef(name: r.name, role: r.role, icon: r.icon, sub: r.sub, uid: r.uid))
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
        .task { await loadUsers() }
    }
}

#Preview("Feed") { FeedView() }
#Preview("Suche") { SearchView() }
#Preview("Mitteilungen") { NotificationsView() }
#Preview("Chats") { MessagesView() }
#Preview("Beitrag") { CreatePostView() }
#Preview("Profil") { ProfileView() }
