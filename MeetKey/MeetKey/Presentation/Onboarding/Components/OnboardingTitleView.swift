import SwiftUI

struct OnboardingTitleView: View {
    let title: String
    let subTitle: String
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.meetKey(.title2))
                .foregroundColor(.meetKeyBlack01)
                .padding(.bottom, 10)
            
            Text(subTitle)
                .font(.meetKey(.body5))
                .foregroundColor(.meetKeyBlack03)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 40)
        }
    }
}
