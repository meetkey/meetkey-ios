import SwiftUI

struct AppRootView: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSplash = false
            }
        }
    }
}

#Preview {
    AppRootView()
}
