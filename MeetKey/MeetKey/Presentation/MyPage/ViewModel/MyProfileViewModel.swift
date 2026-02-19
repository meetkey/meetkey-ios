//
//  MyProfileViewModel.swift
//  MeetKey
//
//  Created by sumin Kong on 2/9/26.
//
import SwiftUI
import Combine
import Moya

final class MyProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoggingOut = false
    @Published var logoutErrorMessage: String?
    @Published var isWithdrawing = false
    @Published var withdrawErrorMessage: String?
    
    private let provider = MoyaProvider<MyAPI>()
    private let authService = AuthService.shared
    private let authProviderKey = "authProvider"
    private let appleAuthorizationCodeKey = "lastAuthorizationCode"
    
    func fetchMyProfile() {
        provider.request(.myInfo) { result in
            switch result {
            case .success(let response):
                print("📦 Profile statusCode:", response.statusCode)
                
                if let body = String(data: response.data, encoding: .utf8),
                   !body.isEmpty {
                } else {
                    print("📦 response body: (empty)")
                }
                switch response.statusCode {
                    
                case 200:
                    do {
                        let decoded = try JSONDecoder().decode(
                            MyInfoResponseDTO.self,
                            from: response.data
                        )
                        
                        let user = User(dto: decoded.data)
                        
                        DispatchQueue.main.async {
                            self.user = user
                        }
                    } catch {
                        print("❌ 디코딩 실패:", error)
                    }
                    
                case 401:
                    print("🚫 401 Unauthorized - 토큰 없음 / 만료")
                    
                case 403:
                    print("🚫 403 Forbidden - 토큰은 있으나 권한 없음")
                    
                default:
                    print("🚨 알 수 없는 상태 코드:", response.statusCode)
                }
                
            case .failure(let error):
                print("❌ 네트워크 실패:", error)
                if let moyaError = error as? MoyaError {
                    switch moyaError {
                    case .statusCode(let response):
                        print("📦 statusCode:", response.statusCode)
                        print("📦 data:", String(data: response.data, encoding: .utf8) ?? "nil")
                        
                    case .underlying(let nsError, _):
                        print("📦 underlying error:", nsError)
                        
                    default:
                        print("📦 moya error:", moyaError)
                    }
                }
            }
        }
    }
    
    func getMyProfileForEdit(completion: @escaping () -> Void) {
        provider.request(.getMyProfileForEdit) { result in
            switch result {
            case .success(let response):
                print("📦 statusCode:", response.statusCode)
                print("📦 data:", String(data: response.data, encoding: .utf8) ?? "nil")
                
                do {
                    let decoded = try JSONDecoder().decode(EditProfileResponseDTO.self, from: response.data)
                    let user = User(dto: decoded.data)
                    
                    DispatchQueue.main.async {
                        self.user = user
                        completion()
                    }
                } catch {
                    print("❌ 디코딩 실패", error)
                }
                
            case .failure(let error):
                print("❌ 조회 실패", error)
            }
        }
    }
    
    @MainActor
    func logout() async {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        logoutErrorMessage = nil
        defer { isLoggingOut = false }
        
        do {
            guard let refreshToken = try KeychainManager.read(account: "refreshToken"),
                  !refreshToken.isEmpty else {
                logoutErrorMessage = "리프레시 토큰이 없습니다"
                return
            }
            
            try await authService.logout(
                refreshToken: refreshToken
            )
            
            KeychainManager.delete(account: "accessToken")
            KeychainManager.delete(account: "refreshToken")
            UserDefaults.standard.removeObject(forKey: authProviderKey)
            UserDefaults.standard.removeObject(forKey: appleAuthorizationCodeKey)
            NotificationCenter.default.post(name: .authDidLogout, object: nil)
        } catch {
            print("❌ 로그아웃 실패: \(error)")
            logoutErrorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func withdraw() async {
        guard !isWithdrawing else { return }
        isWithdrawing = true
        withdrawErrorMessage = nil
        defer { isWithdrawing = false }
        
        do {
            guard let refreshToken = try KeychainManager.read(account: "refreshToken"),
                  !refreshToken.isEmpty else {
                withdrawErrorMessage = "리프레시 토큰이 없습니다"
                return
            }
            
            try await authService.withdraw(
                refreshToken: refreshToken
            )
            
            KeychainManager.delete(account: "accessToken")
            KeychainManager.delete(account: "refreshToken")
            UserDefaults.standard.removeObject(forKey: authProviderKey)
            UserDefaults.standard.removeObject(forKey: appleAuthorizationCodeKey)
            NotificationCenter.default.post(name: .authDidWithdraw, object: nil)
            print("🚀 회원탈퇴 완료")
        } catch {
            print("❌ 회원탈퇴 실패: \(error)")
            withdrawErrorMessage = error.localizedDescription
        }
    }
    
    var socialTypeText: String {
        guard let type = user?.personalities?.socialType else { return "" }
        return PersonalityOptionMapper.socialType[type] ?? ""
    }

    var meetingTypeText: String {
        guard let type = user?.personalities?.meetingType else { return "" }
        return PersonalityOptionMapper.meetingType[type] ?? ""
    }

    var chatTypeText: String {
        guard let type = user?.personalities?.chatType else { return "" }
        return PersonalityOptionMapper.chatType[type] ?? ""
    }

    var friendTypeText: String {
        guard let type = user?.personalities?.friendType else { return "" }
        return PersonalityOptionMapper.friendType[type] ?? ""
    }

    var relationTypeText: String {
        guard let type = user?.personalities?.relationType else { return "" }
        return PersonalityOptionMapper.relationType[type] ?? ""
    }

}
