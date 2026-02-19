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
                    self.saveTokens(response: response)
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("❌ [DEBUG] 로그인 API 자체 실패: \(error)")
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
                    self.saveTokens(response: response)
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("❌ [DEBUG] 회원가입 API 자체 실패: \(error)")
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
                    self.saveTokens(response: response)
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                    print("❌ [DEBUG] 리이슈 토큰 API 자체 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - Withdraw
    func withdraw(refreshToken: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            networkProvider.request(
                .withdraw(refreshToken: refreshToken),
                type: EmptyResponse.self
            ) { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
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
    
    
    private func saveTokens(response: LoginResponse) {
        guard let access = response.accessToken,
              let refresh = response.refreshToken else {
            print("⚠️ [AuthService] 저장할 토큰이 응답에 포함되어 있지 않습니다.")
            return
        }

        do {
            try KeychainManager.save(value: access, account: "accessToken")
            try KeychainManager.save(value: refresh, account: "refreshToken")
            
            print("✅ [AuthService] 토큰 저장 성공")
            print("   - AT: \(access.prefix(15))...")
            print("   - RT: \(refresh.prefix(15))...")
            
        } catch {
            print("❌ [AuthService] Keychain 저장 중 에러 발생: \(error.localizedDescription)")
            
            // 필요하다면 여기서 사용자에게 '로그인 세션 저장 실패' 알림을 띄우는 로직을 추가할 수 있습니다.
        }
    }
}

