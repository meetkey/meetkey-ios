import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        // 비율 설정을 위해 GeometryReader 사용
        GeometryReader { geometry in
            ZStack {
                // 1. 배경 이미지
                Image("bg_onboarding")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack(spacing: 0) {
                    
                    // 로고 영역
                    Image("logo_02")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 10 : 30)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // 텍스트 영역
                    VStack(alignment: .leading, spacing: 18) {
                        Text("대화를 여는 가장 쉬운 방법")
                            .font(.meetKey(.title2))
                            .foregroundColor(.meetKeyBlack01)
                        
                        Text("언어가 달라도, 관심사가 같다면 친구가 될 수 있어요.\n밋키에서 자연스러운 만남을 시작해보세요.")
                            .font(.meetKey(.body5))
                            .foregroundColor(.meetKeyBlack03)
                            .lineSpacing(4)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // 텍스트와 이미지 사이 간격
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // 중앙 캐릭터 이미지
                    Image("img_char_meetkey_twin")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.9)
                        .frame(maxHeight: .infinity)
                    
                    // 이미지와 버튼 사이 간격
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)
                    
                    // 시작하기 버튼
                    NavigationLink(destination: BasicInfoMenuView()) {
                        Text("시작하기")
                            .font(.custom("Pretendard-SemiBold", size: 18))
                            .foregroundColor(.meetKeyWhite01)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.meetKeyOrange04)
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
