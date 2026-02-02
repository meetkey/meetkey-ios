//
//  ReportSectionView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ReportSelectionView: View {
    @ObservedObject var reportVM: ReportViewModel
    
    let targetUser: User
    var body: some View {
        VStack {
            switch reportVM.currentReportStep {

            case .block:
                BlockConfirmView(reportVM: reportVM, targetUser: targetUser)   // 아까 만든 차단 확인 뷰
            case .blockComplete:
                BlockCompleteView(reportVM: reportVM, targetUser: targetUser)
            case .report:
                ReportConfirmView(reportVM: reportVM, targetUser: targetUser)   // 신고 사유 선택 뷰
            case .reportCase:
                ReportCaseView(reportVM: reportVM, targetUser: targetUser)
            case .reportReason:
                ReportReasonView(reportVM: reportVM, targetUser: targetUser)
            case .reportComplete:
                ReportCompleteView(reportVM: reportVM, targetUser: targetUser) // 완료 화면
            default:
                EmptyView()
            }
        }
        .padding()
        // 단계가 바뀔 때 옆으로 슥 밀리는 애니메이션 추가
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.easeInOut, value: reportVM.currentReportStep)
    }
}
