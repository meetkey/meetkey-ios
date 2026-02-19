import SwiftUI

struct OnboardingCompletedView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var navigateToHome = false
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Step 1 배경 이미지
                Image("bg_onboarding_final")
                    .resizable()
                    .ignoresSafeArea(.all)
                
                // Step 2 컨텐츠 레이어
                VStack(spacing: 0) {
                    
                    // A 상단 텍스트 영역
                    VStack(alignment: .leading, spacing: 12) {
                        Text("밋키에 오신 걸\n환영합니다!")
                            .font(.custom("Pretendard-Bold", size: 24))
                            .foregroundColor(Color.meetKey.text1)
                            .lineSpacing(4)
                        
                        Text("\(viewModel.data.name)님, 우리 같이 커뮤니케이션 해보아요!")
                            .font(.custom("Pretendard-Regular", size: 16))
                            .foregroundColor(Color.meetKey.text2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, geometry.safeAreaInsets.top - 10)
                    
                    Spacer()
                    
                    // B 중앙 캐릭터 영역
                    ZStack {
                        // 1 가랜드
                        Image("img_congratulation")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.85)
                            .offset(x: width * 0.05)
                        // 2 자물쇠
                        Image("img_char_meetkey_smile_02")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.52)
                            .offset(x: -width * 0.23, y: -width * 0.35)
                        
                        // 3 열쇠
                        Image("img_char_meetkey_smile_01")
                            .resizable()
                            .scaledToFit()
                            .frame(width: width * 0.64)
                            .offset(x: width * 0.18, y: width * 0.24)
                    }
                    .frame(maxHeight: height * 0.57)
                    
                    Spacer()
                    
                    // C 시작하기 버튼
                Button(action: {
                    // birthDate를 UserDefaults에 저장
                    User.saveBirthDate(viewModel.data.birthDateString)
                    
                    if viewModel.isOnboardingCompleted {
                        navigateToHome = true
                    } else {
                        viewModel.saveOnboardingData()
                    }
                }) {
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
            .onChange(of: viewModel.isOnboardingCompleted) { _, completed in
                if completed {
                    navigateToHome = true
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                ChatListView()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    let vm = OnboardingViewModel()
    vm.data.name = "주영"
    return OnboardingCompletedView(viewModel: vm)
}
