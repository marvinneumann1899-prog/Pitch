import SwiftUI

@main
struct PitchApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

enum Phase { case auth, onboarding, main }

struct RootView: View {
    @State private var phase: Phase = .auth

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            switch phase {
            case .auth:
                AuthView(
                    onLogin: { phase = .main },       // Login → direkt zur App
                    onSignUp: { phase = .onboarding } // Registrierung → Onboarding
                )
            case .onboarding:
                OnboardingView { phase = .main }
            case .main:
                MainTabView()
            }
        }
        .preferredColorScheme(Theme.scheme)
    }
}

struct MainTabView: View {
    @State private var tab = 0

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch tab {
                case 0: FeedView()
                case 1: NotificationsView()
                case 2: CreatePostView { tab = 0 }
                case 3: MessagesView()
                default: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            PitchTabBar(tab: $tab)
        }
        .background(Theme.bg)
    }
}

struct PitchTabBar: View {
    @Binding var tab: Int

    var body: some View {
        ZStack {
            // Feed links · (Chats, Profil) rechts
            HStack(spacing: 0) {
                tabItem(icon: "house.fill", label: "Feed", index: 0)
                tabItem(icon: "bell.fill", label: "Mitteilungen", index: 1)
                Spacer()
                tabItem(icon: "bubble.left.and.bubble.right.fill", label: "Chats", index: 3)
                tabItem(icon: "person.fill", label: "Profil", index: 4)
            }
            .padding(.horizontal, 12)

            // ＋ mittig (per ZStack zentriert)
            createItem()
        }
        .padding(.top, 10)
        .padding(.bottom, 24)
        .background(Theme.surface)
        .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .top)
    }

    private func tabItem(icon: String, label: String, index: Int) -> some View {
        let active = tab == index
        return Image(systemName: icon)
            .font(.system(size: 23))
            .foregroundStyle(active ? Theme.text : Theme.textFaint)
            .frame(width: 64, height: 44)
            .contentShape(Rectangle())
            .onTapGesture { tab = index }
    }

    private func createItem() -> some View {
        let active = tab == 2
        return Image(systemName: "plus")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Theme.accentText)
            .frame(width: 52, height: 52)
            .background(active ? Theme.text : Theme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(Rectangle())
            .onTapGesture { tab = 2 }
    }
}

#Preview { RootView() }
