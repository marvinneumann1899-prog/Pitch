import SwiftUI
import FirebaseCore
import FirebaseAuth

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
