import SwiftUI

struct MenuButtonLabel: View {
    let title: String
    let selectedText: String? // Selected 값 있으면 선택 상태
    
    var body: some View {
        ZStack {
            // Layer 1 텍스트 중앙 정렬
            Text(title)
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundColor(selectedText != nil ? Color.meetKey.main : Color.meetKey.text1)
            
            // Layer 2 아이콘 오른쪽 정렬
            HStack {
                Spacer()
                
                if selectedText != nil {
                    // Done 선택 완료 체크박스 아이콘
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color.meetKey.main)
                } else {
                    // Default 미선택 화살표 아이콘
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.meetKey.text1)
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 54)
        // Background 선택됨 Orange05 미선택 Black02 20
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(selectedText != nil ? Color.meetKey.sub1 : Color.meetKey.black02.opacity(0.2))
        )
        // Border 그라데이션 Orange06 to Orange07 두께 1.5px
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    LinearGradient.meetKeyStateActive,
                    lineWidth: selectedText != nil ? 1.5 : 0
                )
        )
        .cornerRadius(30)
    }
}
