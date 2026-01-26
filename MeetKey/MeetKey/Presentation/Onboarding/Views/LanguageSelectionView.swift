import SwiftUI

struct LanguageSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // 공통 컴포넌트 (페이지 1)
                OnboardingPagination(currentStep: 1)
                
                // 공통 컴포넌트 (타이틀)
                OnboardingTitleView(
                    title: "사용 언어를 알려주세요.",
                    subTitle: "사용 언어는 나중에 변경할 수 없으니,\n꼼꼼하게 확인해 주세요."
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(viewModel.languages, id: \.self) { language in
                            LanguageButton(
                                title: language,
                                isSelected: viewModel.data.nativeLanguage == language,
                                isOtherSelected: viewModel.data.nativeLanguage != nil && viewModel.data.nativeLanguage != language,
                                action: {
                                    if viewModel.data.nativeLanguage == language {
                                        viewModel.data.nativeLanguage = nil
                                    } else {
                                        viewModel.data.nativeLanguage = language
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                
                Spacer()
                
                // 공통 컴포넌트 (하단 버튼)
                BottomActionButton(
                    title: "다음",
                    isEnabled: viewModel.data.nativeLanguage != nil
                ) {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}
