import AuthenticationServices
import UIKit
import Combine

// Apple 로그인 Token
struct AppleSignInTokens {
    let identityToken: String
    let authorizationCode: String
}

final class AppleSignInCoordinator: NSObject, ObservableObject {
    // UI 에러 매핑
    enum SignInError: LocalizedError {
        case bundleIdMismatch(expected: String, actual: String?)
        case missingIdentityToken
        case missingAuthorizationCode

        var errorDescription: String? {
            switch self {
            case .bundleIdMismatch(let expected, let actual):
                return "Bundle ID mismatch. expected=\(expected), actual=\(actual ?? "nil")"
            case .missingIdentityToken:
                return "Apple identity token is missing."
            case .missingAuthorizationCode:
                return "Apple authorization code is missing."
            }
        }
    }

    private var completion: ((Result<AppleSignInTokens, Error>) -> Void)?

    // Apple 로그인 flow 시작
    func startSignIn(completion: @escaping (Result<AppleSignInTokens, Error>) -> Void) {
        guard Bundle.main.bundleIdentifier == AppleAuthConfig.bundleId else {
            completion(.failure(SignInError.bundleIdMismatch(
                expected: AppleAuthConfig.bundleId,
                actual: Bundle.main.bundleIdentifier
            )))
            return
        }

        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let token = String(data: tokenData, encoding: .utf8) else {
            DispatchQueue.main.async {
                self.completion?(.failure(SignInError.missingIdentityToken))
            }
            return
        }

        guard let codeData = credential.authorizationCode,
              let code = String(data: codeData, encoding: .utf8) else {
            DispatchQueue.main.async {
                self.completion?(.failure(SignInError.missingAuthorizationCode))
            }
            return
        }

        DispatchQueue.main.async {
            self.completion?(.success(AppleSignInTokens(identityToken: token, authorizationCode: code)))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.completion?(.failure(error))
        }
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!
        if let window = scene.windows.first {
            return window
        }
        return UIWindow(windowScene: scene)
    }
}

