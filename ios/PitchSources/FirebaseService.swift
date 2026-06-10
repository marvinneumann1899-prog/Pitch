import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// MARK: - Auth-Schicht
//
// Läuft nur, wenn eine GoogleService-Info.plist im Bundle liegt (echtes Firebase-Projekt).
// Ohne plist → isConfigured == false → die App bleibt im Demo-Modus (kein Crash).

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var user: User? = nil
    let isConfigured: Bool

    private init() {
        isConfigured = FirebaseApp.app() != nil
        guard isConfigured else { return }
        user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { [weak self] _, u in
            self?.user = u
        }
    }

    var isLoggedIn: Bool { user != nil }

    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        user = result.user
        // Bestätigungsmail (Verifizierung) — Versand darf das Onboarding nicht blockieren
        try? await result.user.sendEmailVerification()
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        user = result.user
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
        ProfileStore.shared.profile = nil   // kein Profil-Rest für den nächsten Account
    }

    var isVerified: Bool { user?.isEmailVerified ?? false }

    // Status neu vom Server holen (nach Klick auf den Mail-Link)
    func refreshVerification() async -> Bool {
        guard let u = Auth.auth().currentUser else { return false }
        try? await u.reload()
        user = Auth.auth().currentUser
        return user?.isEmailVerified ?? false
    }

    // nil = erfolgreich, sonst Fehlertext (z. B. Rate-Limit)
    func resendVerification() async -> String? {
        do {
            try await Auth.auth().currentUser?.sendEmailVerification()
            return nil
        } catch {
            let code = AuthErrorCode(rawValue: (error as NSError).code)
            if code == .tooManyRequests {
                return "Zu viele Versuche — warte ein paar Minuten, dann erneut senden."
            }
            return authErrorText(error)
        }
    }
}

// MARK: - Nutzerprofil (Firestore: users/{uid})

struct UserProfile: Codable {
    var name: String
    var role: String       // Spieler / Trainer / Scout / Verein
    var club: String
    var location: String
    var bio: String
}

@MainActor
final class ProfileStore: ObservableObject {
    static let shared = ProfileStore()
    @Published var profile: UserProfile? = nil

    // Beim Onboarding-Abschluss: Profil unter users/{uid} ablegen
    func save(_ p: UserProfile) {
        profile = p
        guard AuthService.shared.isConfigured, let uid = AuthService.shared.user?.uid else { return }
        try? Firestore.firestore().collection("users").document(uid).setData(from: p, merge: true)
    }

    // Beim Login: Profil laden (falls vorhanden)
    func load() async {
        guard AuthService.shared.isConfigured, let uid = AuthService.shared.user?.uid else { return }
        if let snap = try? await Firestore.firestore().collection("users").document(uid).getDocument(),
           let p = try? snap.data(as: UserProfile.self) {
            profile = p
        }
    }

    // Alle registrierten User (für Suche etc.)
    func fetchAllUsers() async -> [AppUser] {
        guard AuthService.shared.isConfigured,
              let snap = try? await Firestore.firestore().collection("users").getDocuments() else { return [] }
        return snap.documents.compactMap { doc in
            guard let p = try? doc.data(as: UserProfile.self) else { return nil }
            return AppUser(id: doc.documentID, profile: p)
        }
    }
}

// Registrierter User mit uid (Firestore-Dokument)
struct AppUser: Identifiable {
    let id: String
    let profile: UserProfile
}

// MARK: - Social-Schicht (Beiträge, Follows, Chats, Mitteilungen)

struct PostDoc: Codable, Identifiable {
    @DocumentID var id: String?
    var authorId: String
    var authorName: String
    var authorRole: String
    var caption: String
    var category: String
    var createdAt: Date
}

struct ChatDoc: Codable, Identifiable {
    @DocumentID var id: String?
    var participants: [String]
    var names: [String: String]
    var roles: [String: String]
    var lastMessage: String
    var lastAt: Date
    var lastSenderId: String? = nil
    var reads: [String: Date]? = nil   // pro Nutzer: zuletzt gelesen
}

struct CommentDoc: Codable, Identifiable {
    @DocumentID var id: String?
    var authorId: String
    var authorName: String
    var text: String
    var createdAt: Date
}

struct MessageDoc: Codable, Identifiable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var createdAt: Date
}

struct NotifDoc: Codable, Identifiable {
    @DocumentID var id: String?
    var type: String        // "follow"
    var fromId: String
    var fromName: String
    var fromRole: String
    var createdAt: Date
}

@MainActor
final class SocialStore: ObservableObject {
    static let shared = SocialStore()
    @Published var feedVersion = 0          // erhöht sich nach eigenem Post → Feed lädt neu

    private var db: Firestore { Firestore.firestore() }
    private var uid: String? { AuthService.shared.isConfigured ? AuthService.shared.user?.uid : nil }
    private var me: UserProfile? { ProfileStore.shared.profile }

    // --- Beiträge ---
    func createPost(caption: String, category: String) async {
        guard let uid else { return }
        if ProfileStore.shared.profile == nil { await ProfileStore.shared.load() }   // nie mit altem Profil posten
        guard let me else { return }
        let post = PostDoc(authorId: uid, authorName: me.name, authorRole: me.role,
                           caption: caption, category: category, createdAt: Date())
        _ = try? db.collection("posts").addDocument(from: post)
        feedVersion += 1
    }

    func fetchPosts() async -> [PostDoc] {
        guard uid != nil else { return [] }
        let snap = try? await db.collection("posts")
            .order(by: "createdAt", descending: true).limit(to: 100).getDocuments()
        return snap?.documents.compactMap { try? $0.data(as: PostDoc.self) } ?? []
    }

    // Eigenen Beitrag löschen (inkl. Kommentare)
    func deletePost(_ postId: String) async {
        guard uid != nil else { return }
        let ref = db.collection("posts").document(postId)
        if let comments = try? await ref.collection("comments").getDocuments() {
            for c in comments.documents { try? await c.reference.delete() }
        }
        try? await ref.delete()
        feedVersion += 1
    }

    // Nur Beiträge eines bestimmten Autors — serverseitig gefiltert
    func fetchPosts(by authorId: String) async -> [PostDoc] {
        guard uid != nil else { return [] }
        let snap = try? await db.collection("posts")
            .whereField("authorId", isEqualTo: authorId).getDocuments()
        let posts = snap?.documents.compactMap { try? $0.data(as: PostDoc.self) } ?? []
        return posts.sorted { $0.createdAt > $1.createdAt }
    }

    // Feed: nur Beiträge von Leuten, denen ich folge — plus meine eigenen
    func fetchFeedPosts() async -> [PostDoc] {
        guard let uid else { return [] }
        var allowed = Set(await fetchRelations(kind: "following").map(\.id))
        allowed.insert(uid)
        return await fetchPosts().filter { allowed.contains($0.authorId) }
    }

    // --- Follows ---
    func follow(id targetId: String, name: String, role: String) async {
        guard let uid, let me, targetId != uid else { return }
        let now = Timestamp(date: Date())
        try? await db.collection("users").document(uid).collection("following").document(targetId)
            .setData(["name": name, "role": role, "createdAt": now])
        try? await db.collection("users").document(targetId).collection("followers").document(uid)
            .setData(["name": me.name, "role": me.role, "createdAt": now])
        let notif = NotifDoc(type: "follow", fromId: uid, fromName: me.name, fromRole: me.role, createdAt: Date())
        _ = try? db.collection("users").document(targetId).collection("notifications").addDocument(from: notif)
    }

    func unfollow(id targetId: String) async {
        guard let uid else { return }
        try? await db.collection("users").document(uid).collection("following").document(targetId).delete()
        try? await db.collection("users").document(targetId).collection("followers").document(uid).delete()
    }

    func isFollowing(id targetId: String) async -> Bool {
        guard let uid else { return false }
        let doc = try? await db.collection("users").document(uid).collection("following").document(targetId).getDocument()
        return doc?.exists ?? false
    }

    // Follower/Folge-ich-Listen (eigene oder fremde)
    func fetchRelations(of userId: String? = nil, kind: String) async -> [(id: String, name: String, role: String)] {
        guard let owner = userId ?? uid else { return [] }
        let snap = try? await db.collection("users").document(owner).collection(kind).getDocuments()
        return snap?.documents.map {
            (id: $0.documentID,
             name: $0.data()["name"] as? String ?? "?",
             role: $0.data()["role"] as? String ?? "Spieler")
        } ?? []
    }

    // --- Mitteilungen ---
    func fetchNotifications() async -> [NotifDoc] {
        guard let uid else { return [] }
        let snap = try? await db.collection("users").document(uid).collection("notifications")
            .order(by: "createdAt", descending: true).limit(to: 50).getDocuments()
        return snap?.documents.compactMap { try? $0.data(as: NotifDoc.self) } ?? []
    }

    // --- Chats ---
    func chatId(with other: String) -> String? {
        guard let uid else { return nil }
        return [uid, other].sorted().joined(separator: "_")
    }

    func sendMessage(to otherId: String, otherName: String, otherRole: String, text: String) async {
        guard let uid, let me, let cid = chatId(with: otherId), otherId != uid else { return }
        var names = [uid: me.name];  names[otherId] = otherName
        var roles = [uid: me.role];  roles[otherId] = otherRole
        try? await db.collection("chats").document(cid).setData([
            "participants": [uid, otherId],
            "names": names,
            "roles": roles,
            "lastMessage": text,
            "lastAt": Timestamp(date: Date()),
            "lastSenderId": uid
        ], merge: true)
        let msg = MessageDoc(senderId: uid, text: text, createdAt: Date())
        _ = try? db.collection("chats").document(cid).collection("messages").addDocument(from: msg)
    }

    func fetchChats() async -> [ChatDoc] {
        guard let uid else { return [] }
        let snap = try? await db.collection("chats")
            .whereField("participants", arrayContains: uid).getDocuments()
        let chats = snap?.documents.compactMap { try? $0.data(as: ChatDoc.self) } ?? []
        return chats.sorted { $0.lastAt > $1.lastAt }
    }

    // Live-Listener für einen Chat (Nachrichten in Echtzeit)
    func listenMessages(chatId: String, onChange: @escaping ([MessageDoc]) -> Void) -> ListenerRegistration? {
        guard uid != nil else { return nil }
        return db.collection("chats").document(chatId).collection("messages")
            .order(by: "createdAt")
            .addSnapshotListener { snap, _ in
                onChange(snap?.documents.compactMap { try? $0.data(as: MessageDoc.self) } ?? [])
            }
    }

    // Chat als gelesen markieren (für den Ungelesen-Punkt)
    func markChatRead(with otherId: String) async {
        guard let uid, let cid = chatId(with: otherId) else { return }
        try? await db.collection("chats").document(cid)
            .setData(["reads": [uid: Timestamp(date: Date())]], merge: true)
    }

    // --- Kommentare ---
    func fetchComments(postId: String) async -> [CommentDoc] {
        guard uid != nil else { return [] }
        let snap = try? await db.collection("posts").document(postId).collection("comments")
            .order(by: "createdAt").getDocuments()
        return snap?.documents.compactMap { try? $0.data(as: CommentDoc.self) } ?? []
    }

    func addComment(postId: String, postAuthorId: String?, text: String) async {
        guard let uid else { return }
        if ProfileStore.shared.profile == nil { await ProfileStore.shared.load() }
        guard let me else { return }
        let c = CommentDoc(authorId: uid, authorName: me.name, text: text, createdAt: Date())
        _ = try? db.collection("posts").document(postId).collection("comments").addDocument(from: c)
        // Mitteilung an den Beitrags-Autor (nicht an sich selbst)
        if let author = postAuthorId, author != uid {
            let notif = NotifDoc(type: "comment", fromId: uid, fromName: me.name, fromRole: me.role, createdAt: Date())
            _ = try? db.collection("users").document(author).collection("notifications").addDocument(from: notif)
        }
    }

    // Profil einer fremden Person nachladen
    func fetchProfile(of userId: String) async -> UserProfile? {
        guard uid != nil else { return nil }
        let snap = try? await db.collection("users").document(userId).getDocument()
        return try? snap?.data(as: UserProfile.self)
    }
}

// Relative Zeit auf Deutsch („vor 5 Min")
func timeAgo(_ date: Date) -> String {
    let s = Int(Date().timeIntervalSince(date))
    if s < 60 { return "gerade eben" }
    if s < 3600 { return "vor \(s/60) Min" }
    if s < 86400 { return "vor \(s/3600) Std" }
    return "vor \(s/86400) Tg"
}

// Icon je Rolle (für echte User ohne Demo-Icon)
func iconForRole(_ role: String) -> String {
    switch normalizedRole(role) {
    case "Coach":  return "flame.fill"
    case "Scout":  return "binoculars.fill"
    case "Verein": return "trophy.fill"
    default:       return "soccerball"
    }
}

// Nutzerfreundliche Fehlertexte (statt roher Firebase-Codes)
func authErrorText(_ error: Error) -> String {
    let code = AuthErrorCode(rawValue: (error as NSError).code)
    switch code {
    case .emailAlreadyInUse:   return "Diese E-Mail ist schon registriert."
    case .invalidEmail:        return "Ungültige E-Mail-Adresse."
    case .weakPassword:        return "Passwort zu schwach (mind. 6 Zeichen)."
    case .wrongPassword,
         .invalidCredential:   return "E-Mail oder Passwort stimmt nicht."
    case .userNotFound:        return "Kein Konto mit dieser E-Mail."
    case .networkError:        return "Netzwerkfehler — bitte erneut versuchen."
    default:                   return "Anmeldung fehlgeschlagen. Bitte erneut versuchen."
    }
}
