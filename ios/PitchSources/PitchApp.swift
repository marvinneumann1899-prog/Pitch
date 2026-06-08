import SwiftUI

@main
struct PitchApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    // geteilte App-Phase, damit z. B. „Abmelden" aus den Einstellungen funktioniert
    @AppStorage("appPhase") private var phase = "auth"

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            switch phase {
            case "onboarding":
                OnboardingView { phase = "main" }
            case "main":
                MainTabView()
            default:
                AuthView(
                    onLogin: { phase = "main" },       // Login → direkt zur App
                    onSignUp: { phase = "onboarding" } // Registrierung → Onboarding
                )
            }
        }
        .preferredColorScheme(Theme.scheme)
    }
}

struct MainTabView: View {
    @State private var tab = 0
    // Reset-Zähler pro Tab: erhöhen → View re-mountet → zurück zur Wurzel (pop-to-root)
    @State private var resetIDs = [0, 0, 0, 0, 0]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Alle Tabs bleiben am Leben → jeder behält seinen Navigationsstand.
            ZStack {
                slot(0) { FeedView() }
                slot(1) { NotificationsView() }
                slot(2) { CreatePostView { tab = 0 } }
                slot(3) { MessagesView() }
                slot(4) { ProfileView() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Schwebende Glas-Tableiste
            PitchTabBar(tab: tab) { tapped in
                if tapped == tab { resetIDs[tapped] += 1 }   // aktiv erneut → zur Wurzel
                else { tab = tapped }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
        .background(Theme.bg)
    }

    @ViewBuilder
    private func slot<V: View>(_ index: Int, @ViewBuilder _ content: () -> V) -> some View {
        content()
            .id(resetIDs[index])                  // ändert sich → Reset zur Wurzel
            .opacity(tab == index ? 1 : 0)
            .allowsHitTesting(tab == index)
            .zIndex(tab == index ? 1 : 0)
    }
}

// Schwebende Liquid-Glas-Pille (BeReal-inspiriert): + mittig als Akzent, aktiver Tab grün.
struct PitchTabBar: View {
    let tab: Int
    var onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 0) {
            tabItem(icon: "house.fill", index: 0)
            tabItem(icon: "bell.fill", index: 1)
            plusItem()
            tabItem(icon: "bubble.left.and.bubble.right.fill", index: 3)
            tabItem(icon: "person.fill", index: 4)
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .background(Theme.surface.opacity(0.4))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.7))
        .shadow(color: .black.opacity(0.12), radius: 20, y: 8)
    }

    private func tabItem(icon: String, index: Int) -> some View {
        let active = tab == index
        return Image(systemName: icon)
            .font(.system(size: 21, weight: active ? .bold : .regular))
            .foregroundStyle(active ? Theme.accent : Theme.textMuted)
            .frame(maxWidth: .infinity).frame(height: 44)
            .contentShape(Rectangle())
            .onTapGesture { onSelect(index) }
    }

    private func plusItem() -> some View {
        Image(systemName: "plus")
            .font(.system(size: 21, weight: .bold))
            .foregroundStyle(Theme.accentText)
            .frame(width: 46, height: 46)
            .background(
                LinearGradient(colors: [Theme.accent, Theme.accent.opacity(0.85)],
                               startPoint: .top, endPoint: .bottom)
            )
            .clipShape(Circle())
            .shadow(color: Theme.accent.opacity(0.45), radius: 9, y: 3)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { onSelect(2) }
    }
}

// Debug: Fremdprofil je Rolle per Launch-Argument -dbgRole <Spieler|Coach|Scout|Verein>
struct DebugProfileHost: View {
    @ViewBuilder
    var body: some View {
        if UserDefaults.standard.string(forKey: "dbg") == "notif" {
            NotificationsView().preferredColorScheme(Theme.scheme)
        } else {
            let r = UserDefaults.standard.string(forKey: "dbgRole") ?? "Spieler"
            let icon = ["Spieler": "soccerball", "Coach": "flame.fill",
                        "Scout": "binoculars.fill", "Verein": "trophy.fill"][r] ?? "soccerball"
            let name = ["Spieler": "Leon Bäcker", "Coach": "Mehmet Demir",
                        "Scout": "Lena Groß", "Verein": "TSV Eller 04"][r] ?? "Leon Bäcker"
            NavigationStack {
                UserProfileView(person: PersonRef(name: name, role: r, icon: icon, sub: ""))
            }
            .preferredColorScheme(Theme.scheme)
        }
    }
}

#Preview { RootView() }
