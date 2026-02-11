
import SwiftUI

struct BlockCompleteView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User

    var body: some View {

        ZStack {
            Image(.meetkeyLock)
                .padding(.leading, 89)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Image(.tickSquare)
                    Text("차단 완료")
                        .font(.meetKey(.title4))
                        .foregroundStyle(.text1)
                        .frame(height: 31)
                    Spacer()
                }
                .padding(.leading, 2)

                Text(
                    "상대방을 차단했습니다.\n서로의 프로필을 확인할 수 없으며,\n추천치구 목록에도 표시되지 않습니다.\n\n또한 상대방은 회원님에게\n메시지를 보낼 수 없습니다."
                )
                .font(.meetKey(.body3))
                .foregroundStyle(.text3)
                .padding(.top, 34)
                Text("상대방을 차단했습니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)

                // 확인 버튼
                BlockApplyBtn(title: "확인") {
                    reportVM.finalizeReportProcess()  // 다음상대로 넘기기
                }
                .padding(.top, 103)
            }
            .padding(.horizontal, 23)
        }
    }
}
