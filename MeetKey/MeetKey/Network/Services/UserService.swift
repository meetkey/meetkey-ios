import Foundation
import Moya

final class UserService {
    static let shared = UserService()

    private let provider = MoyaProvider<UserAPI>()

    private init() {}

    func fetchPersonalityOptions() async throws -> PersonalityOptionsResponse {
        try await performRequest(.getPersonality, type: PersonalityOptionsResponse.self)
    }

    func updatePersonality(_ request: PersonalityUpdateRequest) async throws -> PersonalityUpdateResponse {
        try await performRequest(.putPersonality(request: request), type: PersonalityUpdateResponse.self)
    }

    func fetchInterestOptions() async throws -> InterestOptionsResponse {
        try await performRequest(.getInterest, type: InterestOptionsResponse.self)
    }

    func updateInterests(_ request: InterestsUpdateRequest) async throws -> InterestsUpdateResponse {
        try await performRequest(.putInterest(request: request), type: InterestsUpdateResponse.self)
    }

    func requestPhotoUpload(_ items: [PhotoUploadRequestItem]) async throws -> [PhotoUploadResponseItem] {
        try await performRequest(.requestPhotoUpload(items: items), type: [PhotoUploadResponseItem].self)
    }

    func registerPhotos(keys: [String]) async throws {
        _ = try await performRequest(.registerPhotos(keys: keys), type: EmptyResponse.self)
    }

    private func performRequest<T: Codable>(_ target: UserAPI, type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        if (200...299).contains(response.statusCode) {
                            let decoder = JSONDecoder()
                            if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: response.data),
                               let data = apiResponse.data {
                                continuation.resume(returning: data)
                                return
                            }
                            let data = try decoder.decode(T.self, from: response.data)
                            continuation.resume(returning: data)
                        } else {
                            let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: response.data)
                            let message = errorResponse?.message ?? "Server error"
                            continuation.resume(throwing: NetworkError.serverError(code: "\(response.statusCode)", message: message))
                        }
                    } catch {
                        continuation.resume(throwing: NetworkError.decodingError(error))
                    }
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.networkError(error))
                }
            }
        }
    }
}

struct EmptyResponse: Codable {}
