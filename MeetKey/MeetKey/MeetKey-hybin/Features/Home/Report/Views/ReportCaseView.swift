import SwiftUI

struct ReportCaseView: View {
    @ObservedObject var reportVM: ReportViewModel
    let targetUser: User

    @State private var tempSelectedType: ReportType? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("어떤 사유로 신고하나요?")
                    .font(.meetKey(.title3))
                    .foregroundStyle(.text1)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                VStack(spacing: 0) {
                    ForEach(ReportType.allCases, id: \.self) { type in
                        Button(action: {
                            tempSelectedType = type
                        }) {
                            HStack {
                                Text(type.displayName)
                                    .font(.meetKey(.body2))
                                    .foregroundStyle(.text2)
                                    // 선택된 항목은 선명하게, 나머지는 살짝 흐리게
                                    .opacity(tempSelectedType == type ? 1 : 0.6)
                                
                                Spacer()
                                
                                Image(.arrowRight)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                        }

                        if type != ReportType.allCases.last {
                            Divider()
                                .background(.disabled)
                                .padding(.horizontal, 24)
                        }
                    }
                }

                Spacer()

                HStack(spacing: 6) {
                    BlockBtn(title: "취소") {
                        reportVM.closeReportMenu()
                    }
                    .frame(width: 106)

                    BlockApplyBtn(title: "신고하기") {
                        if let selected = tempSelectedType {
                            reportVM.selectedType = selected
                            reportVM.changeReportStep(to: .reportReason)
                        }
                    }
                    .disabled(tempSelectedType == nil)
                    .opacity(tempSelectedType == nil ? 0.4 : 1.0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
        .background(.background1)
    }
}
