import Foundation

// MARK: - Login Response
struct LoginResponse: Codable {
    let accessToken: String?
    let refreshToken: String?
    let memberId: Int64?
    let isNewMember: Bool
}

// MARK: - API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let code: String?
    let message: String?
    let data: T?
}

// MARK: - Error Response
struct ErrorResponse: Codable {
    let code: String
    let message: String
    let data: Bool?
}

// MARK: - Social Provider
enum SocialProvider: String, Codable {
    case kakao = "KAKAO"
    case apple = "APPLE"
}

