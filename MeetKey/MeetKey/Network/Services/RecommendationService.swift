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
    
    
    func getRecommendation(filter: RecommendationRequest) async throws -> [User] {
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
        return response.data.recommendations.map { User(from: $0) }
    }
}


