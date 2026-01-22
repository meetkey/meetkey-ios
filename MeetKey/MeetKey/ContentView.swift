import SwiftUI

struct ContentView: View {
    // 앱이 처음 켜졌을 때 스플래시 화면이 활성화된 상태로 시작
    @State private var isSplashActive: Bool = true
    
    var body: some View {
        ZStack {
            if isSplashActive {
                // 1. 처음엔 스플래시 뷰를 보여줌
                SplashView()
            } else {
                // 3. 1초 뒤에 로그인 뷰로 교체됨
                LoginView()
            }
        }
        .onAppear {
            // 2. 1초(1.0) 뒤에 isSplashActive를 false로 바꿔서 화면 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    isSplashActive = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
