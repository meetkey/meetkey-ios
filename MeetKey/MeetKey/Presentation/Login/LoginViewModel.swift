import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    private let isNewMemberKey = "isNewMember"
    private let authProviderKey = "authProvider"
    private let lastIdTokenKey = "lastIdToken"
    @Published var phoneNumber: String = ""
    @Published var verifyCode: String = ""
    
    // UI 화면 상태
    @Published var isCodeSent: Bool = false
    @Published var isVerified: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Login 결과
    @Published var loginResponse: LoginResponse?
    @Published var isLoginSuccess: Bool = false
    @Published var shouldNavigateToSignup: Bool = false
    @Published var shouldNavigateToHome: Bool = false
    
    private let authService = AuthService.shared
    
    // Social 로그인 공통 진입점
    func login(provider: SocialProvider, idToken: String) {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let response = try await authService.login(provider: provider, idToken: idToken)
                self.loginResponse = response
                self.isLoginSuccess = true

                UserDefaults.standard.set(response.isNewMember, forKey: isNewMemberKey)
                UserDefaults.standard.set(provider.rawValue, forKey: authProviderKey)
                UserDefaults.standard.set(idToken, forKey: lastIdTokenKey)
                if response.isNewMember {
                    self.shouldNavigateToSignup = true
                } else {
                    guard let accessToken = response.accessToken,
                          let refreshToken = response.refreshToken else {
                        self.errorMessage = "로그인 토큰이 없습니다."
                        self.isLoginSuccess = false
                        return
                    }

                    do {
                        try KeychainManager.save(
                            value: accessToken,
                            account: "accessToken"
                        )
                        try KeychainManager.save(
                            value: refreshToken,
                            account: "refreshToken"
                        )
                    } catch {
                        self.errorMessage = "토큰 저장에 실패했습니다."
                        self.isLoginSuccess = false
                        return
                    }

                    self.shouldNavigateToHome = true
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoginSuccess = false
                print("로그인 실패: \(error.localizedDescription)")
            }
            
            self.isLoading = false
        }
    }
    
    // Kakao 로그인 래퍼
    func loginWithKakao(idToken: String) {
        login(provider: .kakao, idToken: idToken)
    }
    
    // Apple 로그인 래퍼
    func loginWithApple(idToken: String) {
        login(provider: .apple, idToken: idToken)
    }
    
    // SMS 인증번호 발송 요청
    func sendCode() {
        guard !phoneNumber.isEmpty else {
            errorMessage = "전화번호를 입력해주세요"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let cleanPhone = phoneNumber.replacingOccurrences(of: "-", with: "")
                let success = try await authService.sendSMS(phone: cleanPhone)
                
                if success {
                    withAnimation {
                        isCodeSent = true
                    }
                    print("인증번호 발송 성공!")
                }
            } catch {
                self.errorMessage = error.localizedDescription
                print("인증번호 발송 실패: \(error.localizedDescription)")
            }
            
            self.isLoading = false
        }
    }
    
    // SMS 인증번호 검증
    func checkCode() {
        guard !phoneNumber.isEmpty, !verifyCode.isEmpty else {
            errorMessage = "전화번호와 인증번호를 입력해주세요"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let cleanPhone = phoneNumber.replacingOccurrences(of: "-", with: "")
                let success = try await authService.verifySMS(phone: cleanPhone, code: verifyCode)
                
                if success {
                    withAnimation {
                        isVerified = true
                    }
                    print("인증 성공")
                }
            } catch {
                self.errorMessage = error.localizedDescription
                print("인증 실패: \(error.localizedDescription)")
            }
            
            self.isLoading = false
        }
    }
}
