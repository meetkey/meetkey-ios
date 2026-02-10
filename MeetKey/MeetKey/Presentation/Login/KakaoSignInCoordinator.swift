import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

final class KakaoSignInCoordinator: NSObject, ObservableObject {
    // UI 에러 매핑
    enum SignInError: LocalizedError {
        case missingIdToken

        var errorDescription: String? {
            switch self {
            case .missingIdToken:
                return "Kakao idToken is missing."
            }
        }
    }

    private var completion: ((Result<String, Error>) -> Void)?

    // Kakao 로그인 시작
    func startSignIn(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion

        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] token, error in
                self?.handleResult(token: token, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { [weak self] token, error in
                self?.handleResult(token: token, error: error)
            }
        }
    }

    private func handleResult(token: OAuthToken?, error: Error?) {
        if let error = error {
            completion?(.failure(error))
            return
        }

        guard let idToken = token?.idToken, !idToken.isEmpty else {
            completion?(.failure(SignInError.missingIdToken))
            return
        }

        completion?(.success(idToken))
    }
}
