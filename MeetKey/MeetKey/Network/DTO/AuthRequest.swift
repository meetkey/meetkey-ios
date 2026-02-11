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
}

enum LanguageLevel: String, Codable {
    case novice = "NOVICE"
    case beginner = "BEGINNER"
    case intermediate = "INTERMEDIATE"
    case advanced = "ADVANCED"
    case fluent = "FLUENT"
}
