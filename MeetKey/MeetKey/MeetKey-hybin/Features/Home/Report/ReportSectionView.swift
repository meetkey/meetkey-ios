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
                BlockConfirmView(reportVM: reportVM, targetUser: targetUser)
            case .blockComplete:
                BlockCompleteView(reportVM: reportVM, targetUser: targetUser)
            case .report:
                ReportConfirmView(reportVM: reportVM, targetUser: targetUser)
            case .reportCase:
                ReportCaseView(reportVM: reportVM, targetUser: targetUser)
            case .reportReason:
                ReportReasonView(reportVM: reportVM, targetUser: targetUser)
            case .reportComplete:
                ReportCompleteView(reportVM: reportVM, targetUser: targetUser)
            default:
                EmptyView()
            }
        }
        .padding()
        .transition(
            .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        )
        .animation(.easeInOut, value: reportVM.currentReportStep)
    }
}
