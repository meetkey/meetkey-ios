import Foundation
import Moya

class NetworkProvider {
    static let shared = NetworkProvider()

    private let provider: MoyaProvider<AuthAPI>

    private init() {
        // Debug 로깅 플러그인 추가
        #if DEBUG
            let plugins: [PluginType] = [
                NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
            ]
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
                    // Success 200-299 범위 응답 처리
                    if (200...299).contains(response.statusCode) {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        
                        // Bool 타입 special 처리 sendSMS verifySMS
                        if type is Bool.Type {
                            // Bool 응답은 true 처리
                            completion(.success(true as! T))
                            return
                        }
                        
                        // APIResponse 래핑 여부 확인
                        if let apiResponse = try? decoder.decode(APIResponse<T>.self, from: response.data),
                           let data = apiResponse.data {
                            completion(.success(data))
                            return
                        }
                        
                        // Direct 데이터인 경우
                        let data = try decoder.decode(T.self, from: response.data)
                        completion(.success(data))
                    } else {
                        // Error 응답 처리 400 401 500
                        let decoder = JSONDecoder()
                        if let errorResponse = try? decoder.decode(
                            ErrorResponse.self,
                            from: response.data
                        ) {
                            let errorMessage = errorResponse.message
                            let errorCode = errorResponse.code
                            completion(.failure(NetworkError.serverError(code: errorCode, message: errorMessage)))
                        } else if let apiResponse = try? decoder.decode(APIResponse<Bool>.self, from: response.data) {
                            // APIResponse 래핑된 에러 응답
                            let errorMessage = apiResponse.message ?? "Unknown error"
                            let errorCode = apiResponse.code ?? "UNKNOWN"
                            completion(
                                .failure(
                                    NetworkError.serverError(
                                        code: errorCode,
                                        message: errorMessage
                                    )
                                )
                            )
                        } else {
                            completion(
                                .failure(
                                    NetworkError.serverError(
                                        code: "\(response.statusCode)",
                                        message: "Server error"
                                    )
                                )
                            )
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

    // MARK: - 추천 전용 API 요청 함수
    private let recommendationProvider = MoyaProvider<RecommendationAPI>(
        plugins: [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
    )

    func requestRecommendation<T: Codable>(
        _ target: RecommendationAPI,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        print("서버로 요청")

        recommendationProvider.request(target) { result in
            print("서버 대답 도착")

            switch result {
            case .success(let response):
                print("성공 (상태코드: \(response.statusCode))")
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601

                    if (200...299).contains(response.statusCode) {
                        let decodedData = try decoder.decode(
                            T.self,
                            from: response.data
                        )
                        completion(.success(decodedData))
                    } else {
                        // 에러 응답 처리 (서버에서 준 에러 메시지 파싱)
                        if let errorBody = try? decoder.decode(
                            ErrorResponse.self,
                            from: response.data
                        ) {
                            completion(
                                .failure(
                                    NetworkError.serverError(
                                        code: errorBody.code,
                                        message: errorBody.message
                                    )
                                )
                            )
                        } else {
                            completion(
                                .failure(
                                    NetworkError.serverError(
                                        code: "\(response.statusCode)",
                                        message: "Unknown Error"
                                    )
                                )
                            )
                        }
                    }
                } catch {
                    print(" 디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                print(" 네트워크 에러: \(error.localizedDescription)")
                completion(.failure(NetworkError.networkError(error)))
            }
        }
    }

    //MARK: - LocationProvider
    private let locationProvider = MoyaProvider<LocationAPI>(
        plugins: [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
        ]
    )
    func requestLocation<T: Codable>(
        _ target: LocationAPI,
        type: T.Type,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        print("📍 위치 API 요청 시작")

        locationProvider.request(target) { result in
            switch result {
            case .success(let response):
                print("📍 위치 API 응답 도착 (상태코드: \(response.statusCode))")

                do {
                    if (200...299).contains(response.statusCode) {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601

                        // Bool 타입 처리
                        if type is Bool.Type {
                            completion(.success(true as! T))
                            return
                        }

                        // APIResponse로 감싸져 있는지 확인
                        if let apiResponse = try? decoder.decode(
                            APIResponse<T>.self,
                            from: response.data
                        ),
                            let data = apiResponse.data
                        {
                            completion(.success(data))
                            return
                        }

                        // 직접 데이터
                        let data = try decoder.decode(
                            T.self,
                            from: response.data
                        )
                        completion(.success(data))
                    } else {
                        // 에러 처리
                        let decoder = JSONDecoder()
                        if let errorResponse = try? decoder.decode(
                            ErrorResponse.self,
                            from: response.data
                        ) {
                            completion(
                                .failure(
                                    NetworkError.serverError(
                                        code: errorResponse.code,
                                        message: errorResponse.message
                                    )
                                )
                            )
                        } else {
                            completion(
                                .failure(
                                    NetworkError.serverError(
                                        code: "\(response.statusCode)",
                                        message: "Server error"
                                    )
                                )
                            )
                        }
                    }
                } catch {
                    print("📍 디코딩 실패: \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }

            case .failure(let error):
                print("📍 네트워크 에러: \(error.localizedDescription)")
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
