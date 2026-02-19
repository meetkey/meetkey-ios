import SwiftUI

struct AppRootView: View {
    @State private var showSplash = true
    @State private var destination: Destination = .login
    private let firstLaunchKey = "hasLaunchedBefore"

    private enum Destination {
        case login
        case main
    }

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                switch destination {
                case .login:
                    LoginView()
                case .main:
                    HybinMainTabView()
                }
            }
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: firstLaunchKey) {
                UserDefaults.standard.set(true, forKey: firstLaunchKey)
                KeychainManager.delete(account: "accessToken")
                KeychainManager.delete(account: "refreshToken")
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                destination = resolveDestination()
                showSplash = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidWithdraw)) { _ in
            destination = .login
            showSplash = false
        }
    }

    private func resolveDestination() -> Destination {
        if let token = KeychainManager.load(account: "accessToken"),
           !token.isEmpty {
            return .main
        }
        return .login
    }
}

extension Notification.Name {
    static let authDidWithdraw = Notification.Name("authDidWithdraw")
}

#Preview {
    AppRootView()
}
