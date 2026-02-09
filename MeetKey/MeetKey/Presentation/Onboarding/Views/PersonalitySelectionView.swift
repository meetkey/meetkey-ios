import SwiftUI

struct PersonalitySelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // 1. 페이지네이션
                OnboardingPagination(currentStep: 5)
                
                // 2. 타이틀
                OnboardingTitleView(
                    title: "나는 어떤 성향인가요?",
                    subTitle: "각 카테고리 별로 한 개씩 선택해주세요."
                )
                
                // 3. 성향 설문 리스트
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // 뷰를 가볍게 만들기 위해 별도 컴포넌트로 분리함
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
                
                // 4. 다음 버튼
                NavigationLink(destination: OnboardingCompletedView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(.meetKeyWhite01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isPersonalitySelectionCompleted ? Color.meetKeyOrange04 : Color.meetKeyBlack04)
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

// 질문 하나와 그리드를 그리는 부분 (컴파일러 과부하 방지용 분리)
struct PersonalityQuestionSection: View {
    let question: String
    let options: [String]
    @ObservedObject var viewModel: OnboardingViewModel
    
    // 그리드 설정
    let columns = [
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12),
        GridItem(.fixed(112), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 질문 제목
            Text(question)
                .font(.custom("Pretendard-Medium", size: 14))
                .foregroundColor(.meetKeyBlack03)
            
            // 선택지 그리드
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(options, id: \.self) { option in
                    PersonalityOptionButton(
                        text: option,
                        isSelected: viewModel.data.personality[question] == option
                    ) {
                        viewModel.selectPersonality(question: question, option: option)
                    }
                }
            }
        }
    }
}

// [컴포넌트] 성향 선택 버튼
struct PersonalityOptionButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // 아이콘
                Image(isSelected ? "icon_button_y" : "icon_button_n")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.top, 28)
                
                Spacer()
                
                // 텍스트 줄바꿈 처리
                Text(text)
                    .font(.meetKey(.title5))
                    .foregroundColor(isSelected ? .main : .text4)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // 최대 2줄 허용
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4) // 좌우 여백
                    .padding(.bottom, 24)    // 하단 여백 조정
            }
            .frame(width: 112, height: 121)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.sub1 : Color.background4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.main : Color.clear, lineWidth: isSelected ? 2 : 0)
            )
        }
    }
}

#Preview {
    PersonalitySelectionView(viewModel: OnboardingViewModel())
}
