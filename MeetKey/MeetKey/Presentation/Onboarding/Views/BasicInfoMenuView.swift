import SwiftUI

struct BasicInfoMenuView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    // 남은 질문 개수 계산
    var remainingCount: Int {
        var count = 3
        if viewModel.data.hometown != nil { count -= 1 }
        if viewModel.data.nativeLanguage != nil { count -= 1 }
        if viewModel.data.targetLanguage != nil { count -= 1 }
        return count
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 6) {
                HStack { Spacer() }.frame(height: 44)
                
                // 공통 컴포넌트: 페이지네이션 (1단계)
                OnboardingPagination(currentStep: 1)
                
                // 공통 컴포넌트: 타이틀
                OnboardingTitleView(
                    title: "관심 언어를 입력해주세요.",
                    subTitle: "정확한 정보를 입력하면 나에게 꼭 맞는\n콘텐츠와 서비스를 추천 받을 수 있어요."
                )
                
                // 메뉴 버튼들
                VStack(spacing: 15) {
                    // [1] 출신 국가
                    NavigationLink(destination: HometownSelectionView(viewModel: viewModel)) {
                        MenuButtonLabel(title: "출신 국가", selectedText: viewModel.data.hometown)
                    }
                    
                    // [2] 사용 언어
                    NavigationLink(destination: LanguageSelectionView(viewModel: viewModel)) {
                        MenuButtonLabel(title: "사용 언어", selectedText: viewModel.data.nativeLanguage)
                    }
                    
                    // [3] 배우고 싶은 언어
                    NavigationLink(destination: TargetLanguageSelectionView(viewModel: viewModel)) {
                        MenuButtonLabel(title: "배우고 싶은 언어", selectedText: viewModel.data.targetLanguage)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 하단 안내 텍스트
                if remainingCount > 0 {
                    Text(remainingCount == 3 ? "세 가지를 반드시 입력해주세요." : (remainingCount == 2 ? "질문 두 개 남았어요!" : "질문 하나 남았어요!"))
                        .font(.custom("Pretendard-Regular", size: 14))
                        .foregroundColor(.meetKeyBlack05)
                        .underline()
                        .padding(.bottom, 10)
                }
                
                // NavigationLink로 다음으로 이동
                NavigationLink(destination: ProfileInfoInputView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(.meetKeyWhite01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isBasicInfoCompleted ? Color.meetKeyOrange04 : Color.meetKeyBlack04)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.isBasicInfoCompleted)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}

#Preview {
    NavigationStack {
        BasicInfoMenuView()
    }
}
