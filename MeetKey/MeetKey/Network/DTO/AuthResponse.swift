import Foundation

// 서버 공통 응답 포맷 (code, message, data)
struct BaseResponse<T: Codable>: Codable {
    let code: String
    let message: String
    let data: T?
}

// 로그인/회원가입 성공 시 받는 알맹이 데이터
struct LoginData: Codable {
    let accessToken: String
    let refreshToken: String
    let memberId: Int64
    let isNewMember: Bool
}
