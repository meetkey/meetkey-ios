//
//  ReportAPI.swift
//  MeetKey
//
//  Created by 전효빈 on 2/12/26.
//

import Foundation

class ReportService {
    static let shared = ReportService()
    private let networkProvider = NetworkProvider.shared
    
    private init() {}
    
    /// 사용자 신고 제출
    /// - Parameters:
    ///   - targetId: 신고 대상 유저의 ID
    ///   - type: 신고 유형 (ReportType Enum)
    ///   - reason: 신고 상세 사유 (최대 1000자)
    ///   - images: S3 업로드된 이미지 URL 리스트 ************* TODO 일단 빈배열
    func submitReport(targetId: Int, type: ReportType, reason: String, images: [String]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            networkProvider.requestReport(
                .sendReport(targetId: targetId, type: type, reason: reason, images: images),
                type: ActionResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    if response.code == "COMMON200" {
                        print("✅ 신고 접수 성공 (대상: \(targetId))")
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: NetworkError.serverError(code: response.code, message: response.message))
                    }
                case .failure(let error):
                    print("❌ 신고 접수 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
