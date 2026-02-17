import SwiftUI

struct BlockCompleteView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User

    var body: some View {
        ZStack {
            // 배경 이미지 배치
            Image(.meetkeyLock)
                .padding(.leading, 89)

            VStack(alignment: .leading, spacing: 0) {
                // 1. 타이틀 (22 SemiBold)
                HStack(spacing: 4) {
                    Image(.tickSquare)
                    
                    Text("차단 완료")
                        .font(.meetKey(.title4))
                        .foregroundStyle(.text1)
                        .frame(height: 31)
                    
                    Spacer()
                }
                .padding(.leading, 2)

                // 2. 안내 본문 (16 Regular)
                Text("상대방을 차단했습니다.\n서로의 프로필을 확인할 수 없으며,\n추천친구 목록에도 표시되지 않습니다.\n\n또한 상대방은 회원님에게\n메시지를 보낼 수 없습니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                    .padding(.top, 34)

                Spacer()

                // 3. 확인 버튼 (하단 고정)
                BlockApplyBtn(title: "확인") {
                    reportVM.finalizeReportProcess()
                }
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 23)
            .padding(.top, 28) // 상단 여백 추가
        }
        .background(.background1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
