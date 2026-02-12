import SwiftUI

struct ReportConfirmView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Capsule()
                    .fill(.background4)
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.vertical, 12)
            
            HStack {
                Text("신고하기")
                    .font(.meetKey(.title4))
                    .foregroundStyle(.text1)
                    .frame(height: 31)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            HStack(alignment: .top, spacing: 10) {
                Image(.dangerCircle)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("상대방의 부적절한 행동을 신고해 주세요.")
                        .font(.meetKey(.body3))
                        .foregroundStyle(.text2)
                    
                    Text("신고 내용은 비공개로 처리되며,\n밋키 운영팀이 검토 후 결과를 안내합니다.")
                        .font(.meetKey(.body3))
                        .foregroundStyle(.text3)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 34)
            .padding(.bottom, 33)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 5) {
                    Image(.dangerTriangle)
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text("허위 신고 금지")
                        .font(.meetKey(.body3))
                        .foregroundStyle(.text2)
                }
                .padding(.top, 14)
                .padding(.leading, 12)
                
                VStack(alignment: .leading, spacing: 2) {
                    bulletPoint(text: "허위 신고 시 서비스 이용 제한이 발생할 수 있습니다.")
                    bulletPoint(text: "신고 내용은 밋키 운영팀이 검토합니다.")
                    bulletPoint(text: "검토 결과는 회원님께 안내됩니다.")
                }
                .padding(.leading, 12)
                .padding(.bottom, 14)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.background4, lineWidth: 1)
            )
            .padding(.horizontal, 24)
            
            Spacer()
            
            HStack(spacing: 6) {
                BlockBtn(title: "취소") {
                    reportVM.closeReportMenu()
                }
                .frame(width: 106)
                
                BlockApplyBtn(title: "신고하기") {
                    reportVM.changeReportStep(to: .reportCase)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .background(.background1)
    }
    
    private func bulletPoint(text: String) -> some View {
        Text(text)
            .font(.meetKey(.caption3))
            .foregroundStyle(.text3)
            .frame(height: 17)
    }
}
