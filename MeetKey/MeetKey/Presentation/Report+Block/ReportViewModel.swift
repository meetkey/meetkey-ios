import Combine
import Foundation
import SwiftUI

class ReportViewModel: ObservableObject {
    @Published var isReportMenuPresented: Bool = false
    @Published var currentReportStep: ReportStep = .none
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var selectedType: ReportType = .other
    @Published var reportReason: String = ""
    @Published var selectedImageUrls: [String] = []

    var onFinalize: (() -> Void)?

    // MARK: - Menu Actions
    func handleReportMenuTap() {
        withAnimation(.spring()) {
            if isReportMenuPresented {
                print("📍 [ReportVM] 메뉴 닫기")
                closeReportMenu()
            } else {
                print("📍 [ReportVM] 메뉴 열기 (Step: .main)")
                isReportMenuPresented = true
                currentReportStep = .main
            }
        }
    }

    func changeReportStep(to step: ReportStep) {
        withAnimation(.easeInOut) {
            print("📍 [ReportVM] 단계 변경: \(currentReportStep) -> \(step)")
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

    // MARK: - API Business Logic
    func confirmBlock(targetId: Int, userName: String) {
        print("📍 [Block] \(userName) 차단 시도 중 (ID: \(targetId))")
        isLoading = true
        
        Task {
            do {
                try await BlockService.shared.blockUser(targetId: targetId)

                await MainActor.run {
                    withAnimation {
                        self.currentReportStep = .blockComplete
                    }
                    self.isLoading = false
                    print("✅ [Block] \(userName) 차단 성공!")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ [Block] 차단 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func confirmReport(targetId: Int, userName: String) {
        print("📍 [Report] \(userName) 신고 시도 중 (사유: \(selectedType.rawValue))")
        isLoading = true
        
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
                    self.isLoading = false
                    print("✅ [Report] 신고 제출 성공!")
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("❌ [Report] 신고 실패: \(error.localizedDescription)")
                }
            }
        }
    }

    func finalizeReportProcess() {
        onFinalize?()
    }
}
