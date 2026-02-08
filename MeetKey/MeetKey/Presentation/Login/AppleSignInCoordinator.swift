import AuthenticationServices
import UIKit
import Combine

final class AppleSignInCoordinator: NSObject, ObservableObject {
    enum SignInError: LocalizedError {
        case bundleIdMismatch(expected: String, actual: String?)
        case missingIdentityToken

        var errorDescription: String? {
            switch self {
            case .bundleIdMismatch(let expected, let actual):
                return "Bundle ID mismatch. expected=\(expected), actual=\(actual ?? "nil")"
            case .missingIdentityToken:
                return "Apple identity token is missing."
            }
        }
    }

    private var completion: ((Result<String, Error>) -> Void)?

    func startSignIn(completion: @escaping (Result<String, Error>) -> Void) {
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

        DispatchQueue.main.async {
            self.completion?(.success(token))
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
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            return window
        }
        return UIWindow()
    }
}

