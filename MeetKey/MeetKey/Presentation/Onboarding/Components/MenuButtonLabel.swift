import SwiftUI

struct MenuButtonLabel: View {
    let title: String
    let selectedText: String? // 값이 있으면 선택된 상태
    
    var body: some View {
        ZStack {
            // 1. 텍스트 레이어 (중앙 정렬)
            Text(title)
                .font(.custom("Pretendard-SemiBold", size: 18))
                .foregroundColor(selectedText != nil ? .meetKeyOrange04 : .meetKeyBlack01)
            
            // 2. 아이콘 레이어 (오른쪽 정렬)
            HStack {
                Spacer()
                
                if selectedText != nil {
                    // ✅ 선택 완료 시: 체크박스 아이콘
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.meetKeyOrange04)
                } else {
                    // ⬜️ 미선택 시: 화살표 아이콘
                    Image(systemName: "chevron.right")
                        .foregroundColor(.meetKeyBlack01)
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 54)
        // [배경] 선택됨: Orange05, 미선택: Black02(20%)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(selectedText != nil ? Color.meetKeyOrange05 : Color.meetKeyBlack02.opacity(0.2))
        )
        // [테두리] ✨ 수정됨: 그라데이션 (Orange06 -> Orange07), 두께 1.5px
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(
                    LinearGradient(
                        colors: [.meetKeyOrange06, .meetKeyOrange07],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: selectedText != nil ? 1.5 : 0 // 선택 안 되면 두께 0 (안 보임)
                )
        )
        .cornerRadius(30)
    }
}
