import Foundation
import Moya
import Alamofire

enum AuthAPI {
    case login(provider: SocialProvider, idToken: String)
    case signup(provider: SocialProvider, request: SignupRequest)
    case reissue(refreshToken: String)
    case logout(refreshToken: String)
    case withdraw(refreshToken: String)
    case sendSMS(phone: String)
    case verifySMS(phone: String, code: String)
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signup:
            return "/auth/signup"
        case .reissue:
            return "/auth/reissue"
        case .logout:
            return "/auth/logout"
        case .withdraw:
            return "/auth/withdraw"
        case .sendSMS:
            return "/auth/sms/send"
        case .verifySMS:
            return "/auth/sms/verify"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .signup, .reissue, .logout, .withdraw, .sendSMS, .verifySMS:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .login(let provider, let idToken):
            var parameters: [String: Any] = [:]
            parameters["provider"] = provider.rawValue
            return .requestCompositeParameters(
                bodyParameters: ["idToken": idToken],
                bodyEncoding: JSONEncoding.default,
                urlParameters: parameters
            )
            
        case .signup(let provider, let request):
            var parameters: [String: Any] = [:]
            parameters["provider"] = provider.rawValue
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            guard let bodyData = try? encoder.encode(request),
                  let bodyDict = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any] else {
                return .requestPlain
            }
            return .requestCompositeParameters(
                bodyParameters: bodyDict,
                bodyEncoding: JSONEncoding.default,
                urlParameters: parameters
            )
            
        case .reissue:
            return .requestPlain
            
        case .logout:
            return .requestPlain
            
        case .withdraw:
            return .requestPlain
            
        case .sendSMS(let phone):
            return .requestParameters(
                parameters: ["phone": phone],
                encoding: URLEncoding.queryString
            )
            
        case .verifySMS(let phone, let code):
            return .requestParameters(
                parameters: [
                    "phone": phone,
                    "code": code
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        switch self {
        case .reissue(let refreshToken):
            headers["refresh"] = refreshToken
        case .logout(let refreshToken):
            headers["refresh"] = refreshToken
            if let accessToken = KeychainManager.load(account: "accessToken"),
               !accessToken.isEmpty {
                headers["Authorization"] = "Bearer \(accessToken)"
            }
        case .withdraw(let refreshToken):
            headers["refresh"] = refreshToken
            if let accessToken = KeychainManager.load(account: "accessToken"),
               !accessToken.isEmpty {
                headers["Authorization"] = "Bearer \(accessToken)"
            }
        default:
            break
        }
        
        return headers
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
