import Foundation

struct LoginRequest: Codable {
    let idToken: String
}

struct SignupRequest: Codable {
    let idToken: String
    let name: String
    let birthday: String // "YYYY-MM-DD"
    let gender: Gender
    let homeTown: String
    let firstLanguage: AppLanguage
    let targetLanguage: AppLanguage
    let targetLanguageLevel: LanguageLevel
    let phoneNumber: String // 국제번호 형식
}

struct WithdrawRequest: Codable {
    let kakaoAccessToken: String?
    let appleAuthorizationCode: String?
}

enum Gender: String, Codable {
    case male = "MALE"
    case female = "FEMALE"
}

enum AppLanguage: String, Codable {
    case english = "ENGLISH"
    case korean = "KOREAN"
    case japanese = "JAPANESE"
    case chinese = "CHINESE"
    case spanish = "SPANISH"
    case french = "FRENCH"
    case german = "GERMAN"
    case italian = "ITALIAN"
    case russian = "RUSSIAN"
}

enum LanguageLevel: String, Codable {
    case novice = "NOVICE"
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case fluent = "FLUENT"
}
