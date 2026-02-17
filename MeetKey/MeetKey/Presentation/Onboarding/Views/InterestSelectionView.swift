import SwiftUI

struct InterestSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // Step 1 페이지네이션 4단계
                OnboardingPagination(currentStep: 4)
                
                // Step 2 타이틀
                OnboardingTitleView(
                    title: "관심사를 입력해주세요.",
            subTitle: "전체 키워드에서\n최소 3개 이상 선택해주세요."
                )
                
                // Step 3 관심사 목록 스크롤
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(viewModel.interestGroups, id: \.category) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                // Category 제목
                                Text(group.category)
                                    .font(.custom("Pretendard-Medium", size: 14))
                                    .foregroundColor(Color.meetKey.text2)
                                
                                // Tag 구름 FlowLayout
                                FlowLayout(items: group.items) { item in
                                    InterestTagButton(
                                        text: item.name,
                                        isSelected: viewModel.data.interests.contains(item.code)
                                    ) {
                                        viewModel.toggleInterest(item.code)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40) // Bottom 여백
                }
                
                Spacer()
                
                // Step 4 다음 버튼
                NavigationLink(destination: PersonalitySelectionView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color.meetKey.white01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isInterestSelectionCompleted ? Color.meetKey.main : Color.meetKey.black04)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.isInterestSelectionCompleted) // Min 3개 선택
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}

// Component 관심사 태그 버튼
struct InterestTagButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom(isSelected ? "Pretendard-SemiBold" : "Pretendard-Medium", size: 16))
                .foregroundColor(isSelected ? Color.meetKey.main : Color.meetKey.text4)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.meetKey.sub1 : Color.meetKey.black07)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.meetKey.main : Color.clear, lineWidth: isSelected ? 2 : 0)
                )
        }
    }
}

// Layout FlowLayout
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat = 8 // Tag 간격 가로
    let content: (Data.Element) -> Content
    
    @State private var totalHeight: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                self.content(item)
                    .padding([.horizontal, .vertical], 5) // Tag 간격 세로 보정
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == self.items.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == self.items.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

#Preview {
    InterestSelectionView(viewModel: OnboardingViewModel())
}
