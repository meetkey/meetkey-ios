import SwiftUI

struct PersonalitySelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // Step 1 페이지네이션
                OnboardingPagination(currentStep: 5)
                
                // Step 2 타이틀
                OnboardingTitleView(
                    title: "나는 어떤 성향인가요?",
                    subTitle: "각 카테고리 별로 한 개씩 선택해주세요."
                )
                
                // Step 3 성향 설문 리스트
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // View 분리로 컴포넌트화
                        ForEach(viewModel.personalityQuestions, id: \.question) { item in
                            PersonalityQuestionSection(
                                question: item.question,
                                options: item.options,
                                viewModel: viewModel
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                
                Spacer()
                
                // Step 4 다음 버튼
                NavigationLink(destination: OnboardingCompletedView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color.meetKey.white01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isPersonalitySelectionCompleted ? Color.meetKey.main : Color.meetKey.black04)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.isPersonalitySelectionCompleted)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}

// Question 그리드 컴포넌트 분리
struct PersonalityQuestionSection: View {
    let question: String
    let options: [String]
    @ObservedObject var viewModel: OnboardingViewModel
    
    // Grid 설정
    let columns = [
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question 제목
            Text(question)
                .font(.custom("Pretendard-Medium", size: 14))
                .foregroundColor(Color.meetKey.text2)
            
            // Option 그리드
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(options, id: \.self) { option in
                    PersonalityOptionButton(
                        text: option,
                        isSelected: viewModel.isPersonalitySelected(question: question, optionLabel: option)
                    ) {
                        viewModel.selectPersonality(question: question, option: option)
                    }
                }
            }
        }
    }
}

// Component 성향 선택 버튼
struct PersonalityOptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Icon 아이콘
                Image(isSelected ? "icon_button_y" : "icon_button_n")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.top, 28)
                
                Spacer()
                
                // Text 줄바꿈 처리
                Text(text)
                    .font(.custom("Pretendard-SemiBold", size: 18))
                    .foregroundColor(isSelected ? Color.meetKey.main : Color.meetKey.text4)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Max 2줄 허용
                    .fixedSize(horizontal: false, vertical: true) // Height 늘어남 허용
                    .padding(.horizontal, 4) // 좌우 여백
                    .padding(.bottom, 24)    // Bottom 여백 조정
            }
            .frame(width: 112, height: 121)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.meetKey.sub1 : Color(hex: "C2C2C2").opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.meetKey.main : Color.clear, lineWidth: isSelected ? 2 : 0)
            )
        }
    }
}

#Preview {
    PersonalitySelectionView(viewModel: OnboardingViewModel())
}
