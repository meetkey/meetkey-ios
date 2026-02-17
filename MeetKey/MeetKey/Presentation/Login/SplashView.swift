import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            LinearGradient.meetKeySplash
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                
                // Key 아이콘
                Image("img_key")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                // Logo 로고
                Image("logo_01")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                
                // Description 텍스트
                Text("""
                     언어와 문화를 넘어
                     사람과 사람을 잇는 커뮤니케이션 앱
                    """)
                    .font(.meetKey(.body5))
                    .foregroundColor(Color.meetKey.text2)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.bottom, 50) // Bottom 여백
        }
    }
}

#Preview {
    SplashView()
}
