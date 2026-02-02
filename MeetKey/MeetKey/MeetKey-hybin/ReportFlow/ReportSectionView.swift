//
//  ReportSectionView.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI

struct ReportSelectionView: View {
    @ObservedObject var homeVM: HomeViewModel
    
    var body: some View {
        VStack {
            switch homeVM.currentReportStep {

            case .block:
                BlockConfirmView(homeVM: homeVM)   // 아까 만든 차단 확인 뷰
            case .blockComplete:
                BlockCompleteView(homeVM: homeVM)
            case .report:
                ReportConfirmView(homeVM: homeVM)  // 신고 사유 선택 뷰
            case .reportCase:
                ReportCaseView(homeVM: homeVM)
            case .reportReason:
                ReportReasonView(homeVM: homeVM)
            case .reportComplete:
                ReportCompleteView(homeVM: homeVM) // 완료 화면
            default:
                EmptyView()
            }
        }
        .padding()
        // ✅ 단계가 바뀔 때 옆으로 슥 밀리는 애니메이션 추가
        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        .animation(.easeInOut, value: homeVM.currentReportStep)
    }
}
