import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        // Layout 비율 설정 GeometryReader 사용
        GeometryReader { geometry in
            ZStack {
                // Step 1 배경 이미지
                Image("bg_onboarding")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack(spacing: 0) {
                    
                    // Logo 로고 영역
                    Image("logo_02")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 10 : 30)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // Text 텍스트 영역
                    VStack(alignment: .leading, spacing: 18) {
                        Text("대화를 여는 가장 쉬운 방법")
                            .font(.meetKey(.title2))
                            .foregroundColor(Color.meetKey.text1)
                        
                        Text("언어가 달라도, 관심사가 같다면 친구가 될 수 있어요.\n밋키에서 자연스러운 만남을 시작해보세요.")
                            .font(.meetKey(.body5))
                            .foregroundColor(Color.meetKey.text2)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Text 이미지 사이 간격
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // Center 캐릭터 이미지
                    Image("img_char_meetkey_twin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.9)
                        .frame(maxHeight: .infinity)
                    
                    // Image 버튼 사이 간격
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // Start 시작하기 버튼
                    NavigationLink(destination: BasicInfoMenuView()) {
                        Text("시작하기")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundColor(Color.meetKey.white01)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.meetKey.main)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 10 : 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnboardingIntroView()
}
