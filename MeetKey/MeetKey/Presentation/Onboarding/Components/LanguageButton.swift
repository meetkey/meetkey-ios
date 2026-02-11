import SwiftUI

struct LanguageButton: View {
    let title: String
    let isSelected: Bool
    let isOtherSelected: Bool
    var cornerRadius: CGFloat = 30 // 기본값 30 필요시 12 변경
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Pretendard-Medium", size: 16))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                // Background 배경
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius) // 변수 사용
                        .fill(isSelected ? Color.meetKey.sub1 : Color.meetKey.black02.opacity(0.2))
                )
                // Border 테두리
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius) // 변수 사용
                        .strokeBorder(Color.meetKey.main, lineWidth: isSelected ? 1.5 : 0)
                )
                // Text 글자색
                .foregroundColor(
                    isSelected ? Color.meetKey.main : (isOtherSelected ? Color.meetKey.text4 : Color.meetKey.text1)
                )
        }
    }
}
