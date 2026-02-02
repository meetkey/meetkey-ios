//
//  ReportViewModel.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import SwiftUI
import Foundation
import Combine


class ReportViewModel: ObservableObject {

    @Published var isReportMenuPresented: Bool = false
    @Published var currentReportStep: ReportStep = .none
    
    // 작업 완료 후 부모(Home)에게 알려줄 신호 (클로저)
    var onFinalize: (() -> Void)?


    func handleReportMenuTap() {
        withAnimation(.spring()) {
            if isReportMenuPresented {
                closeReportMenu()
            } else {
                isReportMenuPresented = true
                currentReportStep = .main
            }
        }
    }

    func changeReportStep(to step: ReportStep) {
        withAnimation(.easeInOut) {
            isReportMenuPresented = false
            currentReportStep = step
        }
    }

    func closeReportMenu() {
        withAnimation {
            isReportMenuPresented = false
            currentReportStep = .none
        }
    }
    
    // MARK: API 연결될 비즈니스 로직들
    func confirmBlock(userName: String) {
        print("\(userName) 차단 완료")
        withAnimation { self.currentReportStep = .blockComplete }
    }
    
    func confirmReport(userName: String) {
        print("\(userName) 신고 완료")
        withAnimation { self.currentReportStep = .reportComplete }
    }

    // 최종 종료
    func finalizeReportProcess() {
        onFinalize?() // 홈뷰한테 끝났다고 말해주기
    }
}
