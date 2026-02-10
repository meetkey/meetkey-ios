import Foundation
import Moya

class NetworkProvider {
    static let shared = NetworkProvider()
    
    private let provider: MoyaProvider<AuthAPI>
    
    private init() {
        // 로깅 플러그인 추가 (디버그 모드에서만)
        #if DEBUG
        let plugins: [PluginType] = [NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))]
        #else
        let plugins: [PluginType] = []
        #endif
        
        provider = MoyaProvider<AuthAPI>(
            plugins: plugins
        )
    }
    
    func request<T: Codable>(
        _ target: AuthAPI,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    // 200-299 범위의 성공 응답 처리
                    if (200...299).contains(response.statusCode) {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        // Bool 타입인 경우 특별 처리 (sendSMS, verifySMS)
                        if type is Bool.Type {
                            // Bool 응답은 true로 간주
                            completion(.success(true as! T))
                            return
                        }
                        
                        // 응답이 APIResponse로 감싸져 있는지 확인
                        if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: response.data),
                           let data = apiResponse.data {
                            completion(.success(data))
                            return
                        }
                        
                        // 직접 데이터인 경우
                        let data = try decoder.decode(T.self, from: response.data)
                        completion(.success(data))
                    } else {
                        // 에러 응답 처리 (400, 401, 500 등)
                        let decoder = JSONDecoder()
                        if let errorResponse = try? decoder.decode(ErrorResponse.self, from: response.data) {
                            let errorMessage = errorResponse.message
                            let errorCode = errorResponse.code
                            completion(.failure(NetworkError.serverError(code: errorCode, message: errorMessage)))
                        } else if let apiResponse = try? decoder.decode(APIResponse<Bool>.self, from: response.data) {
                            // APIResponse로 감싸진 에러 응답
                            let errorMessage = apiResponse.message ?? "Unknown error"
                            let errorCode = apiResponse.code ?? "UNKNOWN"
                            completion(.failure(NetworkError.serverError(code: errorCode, message: errorMessage)))
                        } else {
                            completion(.failure(NetworkError.serverError(code: "\(response.statusCode)", message: "Server error")))
                        }
                    }
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(NetworkError.networkError(error)))
            }
        }
    }
    //MARK: - 추천 전용 API 요청 함수
    func requestRecommendation<T:Codable> (
        _ target: RecommendationAPI,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let recommendationProvider = MoyaProvider<RecommendationAPI>(
            
        )
        
        recommendationProvider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    // 200-299 범위의 성공 응답 처리
                    if (200...299).contains(response.statusCode) {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        // Bool 타입인 경우 특별 처리 (sendSMS, verifySMS)
                        if type is Bool.Type {
                            // Bool 응답은 true로 간주
                            completion(.success(true as! T))
                            return
                        }
                        
                        // 응답이 APIResponse로 감싸져 있는지 확인
                        if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: response.data),
                           let data = apiResponse.data {
                            completion(.success(data))
                            return
                        }
                        
                        // 직접 데이터인 경우
                        let data = try decoder.decode(T.self, from: response.data)
                        completion(.success(data))
                    } else {
                        // 에러 응답 처리 (400, 401, 500 등)
                        let decoder = JSONDecoder()
                        if let errorResponse = try? decoder.decode(ErrorResponse.self, from: response.data) {
                            let errorMessage = errorResponse.message
                            let errorCode = errorResponse.code
                            completion(.failure(NetworkError.serverError(code: errorCode, message: errorMessage)))
                        } else if let apiResponse = try? decoder.decode(APIResponse<Bool>.self, from: response.data) {
                            // APIResponse로 감싸진 에러 응답
                            let errorMessage = apiResponse.message ?? "Unknown error"
                            let errorCode = apiResponse.code ?? "UNKNOWN"
                            completion(.failure(NetworkError.serverError(code: errorCode, message: errorMessage)))
                        } else {
                            completion(.failure(NetworkError.serverError(code: "\(response.statusCode)", message: "Server error")))
                        }
                    }
                } catch {
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(NetworkError.networkError(error)))
            }
        }
    }
}

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case serverError(code: String, message: String)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .serverError(_, let message):
            return message
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

