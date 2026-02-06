import SwiftUI

struct InterestSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // 1. 페이지네이션 (4단계)
                OnboardingPagination(currentStep: 4)
                
                // 2. 타이틀
                OnboardingTitleView(
                    title: "관심사를 입력해주세요.",
                    subTitle: "각 카테고리 별로\n최소 3개 이상 선택해주세요."
                )
                
                // 3. 관심사 목록 (스크롤 가능)
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        ForEach(viewModel.orderedInterests, id: \.category) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                // 카테고리 제목
                                Text(group.category)
                                    .font(.custom("Pretendard-Medium", size: 14))
                                    .foregroundColor(.meetKeyBlack03) // #6B7280
                                
                                // 태그 구름 (FlowLayout)
                                FlowLayout(items: group.items) { item in
                                    InterestTagButton(
                                        text: item,
                                        isSelected: viewModel.data.interests.contains(item)
                                    ) {
                                        viewModel.toggleInterest(item)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40) // 하단 여백
                }
                
                Spacer()
                
                // 4. 다음 버튼
                NavigationLink(destination: PersonalitySelectionView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(.meetKeyWhite01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isInterestSelectionCompleted ? Color.meetKeyOrange04 : Color.meetKeyBlack04)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.isInterestSelectionCompleted) // 3개 이상 선택 안 하면 클릭 불가
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}

// [컴포넌트] 관심사 태그 버튼
struct InterestTagButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.meetKey(.body2))
                .foregroundColor(isSelected ? .main : .text4)
                .padding(.horizontal, 14)
                .frame(height: 38)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.sub1 : Color.background4)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.main : Color.clear, lineWidth: isSelected ? 2 : 0)
                )
        }
    }
}

// [레이아웃] FlowLayout
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable {
    let items: Data
    let spacing: CGFloat = 6
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
                    .padding([.horizontal, .vertical], 5) // 태그 사이 간격 (세로 + 보정)
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
