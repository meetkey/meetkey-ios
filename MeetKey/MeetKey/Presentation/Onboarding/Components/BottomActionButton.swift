import SwiftUI

struct BottomActionButton: View {
    let title: String
    let isEnabled: Bool // 활성화 여부 (색상 변경용)
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundColor(.meetKeyWhite01)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(isEnabled ? Color.meetKeyOrange04 : Color.meetKeyBlack04)
                .cornerRadius(15)
        }
        .disabled(!isEnabled)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
