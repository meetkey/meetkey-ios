import SwiftUI

struct OnboardingPagination: View {
    var totalStep: Int = 5
    var currentStep: Int // 1부터 시작 (예: 1이면 첫번째 점 활성화)
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalStep, id: \.self) { step in
                Circle()
                    .fill(step == currentStep ? Color.meetKeyOrange04 : Color.meetKeyBlack02)
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}
