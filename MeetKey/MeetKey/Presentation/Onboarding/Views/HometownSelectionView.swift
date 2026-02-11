import SwiftUI

struct HometownSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    // Grid 2열 설정
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // Common 컴포넌트
                OnboardingPagination(currentStep: 1)
                OnboardingTitleView(
                    title: "출신 국가를 알려주세요.",
                    subTitle: "지역은 나중에 변경할 수 없으니,\n꼼꼼하게 확인해 주세요."
                )
                
                // Country 그리드 2열
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.countries, id: \.self) { country in
                        LanguageButton(
                            title: country,
                            isSelected: viewModel.data.hometown == country,
                            isOtherSelected: viewModel.data.hometown != nil && viewModel.data.hometown != country,
                            cornerRadius: 12,
                            action: {
                                if viewModel.data.hometown == country {
                                    viewModel.data.hometown = nil
                                } else {
                                    viewModel.data.hometown = country
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Common 하단 버튼
                BottomActionButton(
                    title: "다음",
                    isEnabled: viewModel.data.hometown != nil
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
    HometownSelectionView(viewModel: OnboardingViewModel())
}
