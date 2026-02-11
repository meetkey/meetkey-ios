//
//  ReportViewModel.swift
//  MeetKey
//
//  Created by 전효빈 on 2/2/26.
//

import Combine
import Foundation
import SwiftUI

class ReportViewModel: ObservableObject {

    @Published var isReportMenuPresented: Bool = false
    @Published var currentReportStep: ReportStep = .none
    
    @Published var selectedType: ReportType = .other
    @Published var reportReason: String = ""
    @Published var selectedImageUrls: [String] = []

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
    func confirmBlock(targetId: Int, userName: String) {
        print("📍 \(userName) 차단 시도 중 (ID: \(targetId))")

        Task {
            do {
                try await BlockService.shared.blockUser(targetId: targetId)

                await MainActor.run {
                    withAnimation {
                        self.currentReportStep = .blockComplete
                    }
                    print("✅ \(userName) 차단 성공")
                }
            } catch {
                print("❌ \(userName) 차단 실패: \(error.localizedDescription)")
            }
        }
    }

    func confirmReport(targetId: Int, userName: String) {
            print("📍 \(userName) 신고 시도 중")
            
            Task {
                do {
                    try await ReportService.shared.submitReport(
                        targetId: targetId,
                        type: self.selectedType,
                        reason: self.reportReason,
                        images: self.selectedImageUrls
                    )
                    
                    await MainActor.run {
                        withAnimation(.spring()) {
                            self.currentReportStep = .reportComplete
                        }
                    }
                } catch {
                    print("❌ 신고 실패: \(error)")
                }
            }
        }

    func finalizeReportProcess() {
        onFinalize?()
    }
}
