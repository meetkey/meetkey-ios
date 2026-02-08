import Foundation
import Combine

class AuthService {
    static let shared = AuthService()
    
    private let networkProvider = NetworkProvider.shared
    
    private init() {}
    
    // MARK: - Login
    func login(provider: SocialProvider, idToken: String) async throws -> LoginResponse {
        return try await withCheckedThrowingContinuation { continuation in
            networkProvider.request(
                .login(provider: provider, idToken: idToken),
                type: LoginResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Signup
    func signup(provider: SocialProvider, request: SignupRequest) async throws -> LoginResponse {
        return try await withCheckedThrowingContinuation { continuation in
            networkProvider.request(
                .signup(provider: provider, request: request),
                type: LoginResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Token Reissue
    func reissue(refreshToken: String) async throws -> LoginResponse {
        return try await withCheckedThrowingContinuation { continuation in
            networkProvider.request(
                .reissue(refreshToken: refreshToken),
                type: LoginResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - SMS Send
    func sendSMS(phone: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            networkProvider.request(
                .sendSMS(phone: phone),
                type: Bool.self
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - SMS Verify
    func verifySMS(phone: String, code: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            networkProvider.request(
                .verifySMS(phone: phone, code: code),
                type: Bool.self
            ) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

