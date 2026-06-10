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
    }

    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        user = result.user
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
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
