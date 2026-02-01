import SwiftUI

struct LanguageButton: View {
    let title: String
    let isSelected: Bool
    let isOtherSelected: Bool
    var cornerRadius: CGFloat = 30 // ✨ 기본값 30, 필요하면 12로 변경 가능
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Pretendard-Medium", size: 16))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                // [배경]
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius) // ✨ 변수 사용
                        .fill(isSelected ? Color.meetKeyOrange05 : Color.meetKeyBlack02.opacity(0.2))
                )
                // [테두리]
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius) // ✨ 변수 사용
                        .strokeBorder(Color.meetKeyOrange04, lineWidth: isSelected ? 1.5 : 0)
                )
                // [글자색]
                .foregroundColor(
                    isSelected ? .meetKeyOrange04 : (isOtherSelected ? .meetKeyBlack05 : .meetKeyBlack01)
                )
        }
    }
}
