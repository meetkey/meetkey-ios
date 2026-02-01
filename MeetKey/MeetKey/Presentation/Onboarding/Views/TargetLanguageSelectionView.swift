import SwiftUI

struct TargetLanguageSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // 공통 컴포넌트 (페이지네이션)
                OnboardingPagination(currentStep: 1)
                
                // 공통 컴포넌트 (타이틀)
                OnboardingTitleView(
                    title: "어떤 언어를 배우고 싶나요?",
                    subTitle: "현재 가장 관심있는\n언어 하나를 선택해주세요."
                )
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        
                        // [A] 선택된 언어 (맨 위)
                        if let selected = viewModel.data.targetLanguage {
                            VStack(spacing: 0) {
                                LanguageButton(
                                    title: selected,
                                    isSelected: true,
                                    isOtherSelected: false,
                                    action: {
                                        withAnimation(.spring()) {
                                            viewModel.data.targetLanguage = nil
                                            viewModel.targetLanguageLevel = 1.0
                                        }
                                    }
                                )
                                
                                CustomLevelSlider(value: $viewModel.targetLanguageLevel)
                                    .padding(.top, 1)
                                    .padding(.horizontal, 4)
                                    .padding(.bottom, 1)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // [B] 나머지 언어들
                        ForEach(viewModel.languages.filter { $0 != viewModel.data.targetLanguage }, id: \.self) { language in
                            LanguageButton(
                                title: language,
                                isSelected: false,
                                isOtherSelected: viewModel.data.targetLanguage != nil,
                                action: {
                                    withAnimation(.spring()) {
                                        viewModel.data.targetLanguage = language
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
                    isEnabled: viewModel.data.targetLanguage != nil
                ) {
                    dismiss()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}

#Preview {
    TargetLanguageSelectionView(viewModel: OnboardingViewModel())
}
