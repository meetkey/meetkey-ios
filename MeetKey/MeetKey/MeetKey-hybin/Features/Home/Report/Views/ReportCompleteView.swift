import SwiftUI

struct ReportCompleteView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Image("meetkey_Key")
                .resizable()
                .scaledToFit()
                .frame(width: 240)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(.tickSquare)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("신고 완료")
                        .font(.meetKey(.title4))
                        .foregroundStyle(.text1)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("신고가 정상적으로 접수되었습니다.\n회원님의 신고는 안전한 이용 환경 조성에\n반영됩니다.")
                        .font(.meetKey(.body3))
                        .foregroundStyle(.text2)
                        .lineSpacing(6)
                    
                    Text("밋키 운영팀이 내용을 확인한 후\n처리 결과를 안내해드리겠습니다.\n감사합니다.")
                        .font(.meetKey(.body3))
                        .foregroundStyle(.text2)
                        .lineSpacing(6)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                Spacer()
                
                BlockApplyBtn(title: "확인") {
                    reportVM.finalizeReportProcess()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .background(.background1)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
