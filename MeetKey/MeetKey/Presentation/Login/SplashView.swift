import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // 배경 그라데이션
            LinearGradient(
                gradient: Gradient(colors: [.bgTop, .bgBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // 열쇠 아이콘
                Image("img_key")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                
                // 로고
                Image("logo_01")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
                
                // 설명 텍스트
                Text("""
                     언어와 문화를 넘어
                     사람과 사람을 잇는 커뮤니케이션 앱
                    """)
                    .font(.meetKey(.body5))
                    .foregroundColor(.meetKeyBlack03)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.bottom, 50) // 하단 여백
        }
    }
}

#Preview {
    SplashView()
}
