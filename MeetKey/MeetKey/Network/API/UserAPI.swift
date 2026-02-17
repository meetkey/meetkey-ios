import Foundation
import Moya
import Alamofire

enum UserAPI {
    case getPersonality
    case putPersonality(request: PersonalityUpdateRequest)
    case getInterest
    case putInterest(request: InterestsUpdateRequest)
    case requestPhotoUpload(items: [PhotoUploadRequestItem])
    case registerPhotos(keys: [String])
}

extension UserAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getPersonality, .putPersonality:
            return "/users/me/personality"
        case .getInterest, .putInterest:
            return "/users/me/interest"
        case .requestPhotoUpload:
            return "/users/photos"
        case .registerPhotos:
            return "/users/photos/register"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getPersonality, .getInterest:
            return .get
        case .putPersonality, .putInterest:
            return .put
        case .requestPhotoUpload, .registerPhotos:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .getPersonality, .getInterest:
            return .requestPlain
        case .putPersonality(let request):
            return .requestJSONEncodable(request)
        case .putInterest(let request):
            return .requestJSONEncodable(request)
        case .requestPhotoUpload(let items):
            return .requestJSONEncodable(items)
        case .registerPhotos(let keys):
            return .requestJSONEncodable(keys)
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        if let token = KeychainManager.load(account: "accessToken") {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
