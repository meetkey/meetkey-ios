//
//  RecommendationService.swift
//  MeetKey
//
//  Created by 전효빈 on 2/10/26.
//

class RecommendationService {
    static let shared = RecommendationService()
    
    private let networkProvider = NetworkProvider.shared
    
    private init() {}
    
    
    func getRecommendation(filter: RecommendationRequest) async throws -> RecommendationResponse {
        let response = try await withCheckedThrowingContinuation { continuation in
            networkProvider.requestRecommendation(
                .getRecommendations(filter: filter),
                type: RecommendationResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        return response
    }
    
    func sendUserAction(targetId: Int, action: ActionType) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            networkProvider.requestRecommendation(
                .sendAction(targetId: targetId, action: action),
                type: ActionResponse.self // code랑 message만 있는 공통 모델 사용
            ) { result in
                switch result {
                case .success(_):
                    continuation.resume()

                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


//MARK: - 액션 응답에 대한 에러 방지용
struct ActionResponse: Codable {
    let code : String
    let message: String

}


