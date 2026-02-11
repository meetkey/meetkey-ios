import SwiftUI

struct BlockConfirmView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("차단하기")
                    .font(.meetKey(.title4))
                    .foregroundStyle(.text1)
                    .frame(height: 31)
                Spacer()
            }
            .padding(.leading, 1)

            HStack(spacing: 10) {
                Image(.hide)
                    .frame(width: 24, height: 24)
                Text("이 설정을 적용하면 서로의 프로필을 확인할 수  없습니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 34)

            Divider()
                .background(.disabled)
                .padding(.top, 8)

            HStack(spacing: 10) {
                Image(.paperFail)
                    .frame(width: 24, height: 24)
                Text("상대방은 회원님에게 메시지를 보낼 수 없게 됩니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.text3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 12)
            Divider()
                .background(.disabled)
                .padding(.top, 8)

            Button(action: {
                reportVM.changeReportStep(to: .report)
            }) {
                VStack(spacing: 2) {
                    HStack(spacing: 5) {
                        Image(.dangerTriangle)
                            .frame(width: 20, height: 20)
                        Text("상대방이 커뮤니티 가이드라인을 위반했나요?")
                            .font(.meetKey(.body3))
                            .foregroundStyle(.text2)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 14)
                    .padding(.leading, 12)
                    .padding(.trailing, 12)

                    HStack(spacing: 4) {
                        Text("신고하러 바로가기")
                            .font(.meetKey(.caption3))
                            .foregroundStyle(.text3)
                            .frame(height: 17)
                        Image(.arrowRight)
                            .frame(height: 16)
                        Spacer()
                    }
                    .padding(.leading, 37)
                    .padding(.bottom, 14)
                }
                .frame(height: 67)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.background1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.background4, lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())  // 버튼 클릭 시 글자색 변함 방지
            .padding(.top, 43)
            //            .padding(.horizontal, 24)

            HStack(spacing: 6) {
                BlockBtn(title: "취소") {
                    reportVM.closeReportMenu()
                }
                .frame(width: 106)
                BlockApplyBtn(title: "차단하기") {
                    reportVM.confirmBlock(
                        targetId: targetUser.id,
                        userName: targetUser.name
                    )
                }
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white01)
    }

}
