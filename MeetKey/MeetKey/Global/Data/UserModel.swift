//
//  HybinUserModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Foundation

enum SafeBadge : String, CaseIterable{
    case none  = "none"
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
}

//struct User: Identifiable, Equatable {
//    let id: UUID
//    let name : String
//    let age: Int
//    let bio : String
//    let profileImageURL: String
//    let safeBadge: SafeBadge
//}

//struct User {
//    var name: String
//    var birthDate: Date
//    var location: String
//    var usingLanguage: String
//    var interestingLanguage: String
//    var oneLiner: String
//}

//MARK: - UserModel (hybin)
/*
 struct User: Identifiable, Equatable {
 let id: UUID
 let name : String
 let age: Int (== birthDate)
 let bio : String  (== oneLiner)
 let profileImageURL: String -> 필요하고
 let safeBadge: SafeBadge -> 필요하고 nil?
 }
 */

// MARK: - 서버 응답 전체 구조
struct UserResponse: Codable {
    var code: String
    var message: String
    var data: User
}

// MARK: - 표준 유저 모델
struct User: Identifiable, Codable, Equatable {
    // 1. 서버 명세서 기준 필수 데이터
    var id: Int
    let name: String
    var profileImage: String

    // 2. 상세 정보 (명세서 기준 + 옵셔널 처리)
    let age: Int?  // 서버에서 주는 나이
    let gender: String?  // "MALE", "FEMALE"
    let homeTown: String?
    var location: String // 팀원 모델 대응용
    var distance: String?
    var bio: String?  // bio == oneLiner 통합

    // 3. 언어 및 활동 데이터
    var first: String  // 모국어 (usingLanguage)
    var target: String  // 목표 언어 (interestingLanguage)
    var level: String
    var recommendCount: Int = 0
    var notRecommendCount: Int = 0

    // 4. 성향 및 관심사
    var interests: [String]?
    var personalities: Personalities?

    // 5. 뱃지 데이터 (UI 컴포넌트 'Badge'와 충돌 방지를 위해 BadgeInfo로 명명)
    var badge: BadgeInfo?

    // 6. 프로필 수정 시 사용하는 데이터
    var birthDate: Date?

    // MARK: - 매너 브릿지 & 계산 프로퍼티

    // 기존에 쓰던 이름을 그대로 유지할 수 있게 연결
    var oneLiner: String { bio ?? "" }
    var usingLanguage: String { first ?? "" }
    var interestingLanguage: String { target ?? "" }

    // 로직용으로 쓸 순수 숫자 나이 (Int)
    var ageInt: Int {
        if let age = age { return age }
        guard let birth = birthDate else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.year], from: birth, to: Date()).year
        ?? 0
    }

    // Equatable 준수
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 하위 데이터 구조들

// MARK: - 뱃지
// 1. 기존 Badge.swift에 있는 열거형 이사 (View 의존성 제거)
enum BadgeType1: String, CaseIterable, Codable {
    case normal, bronze, silver, gold

    //재사용을 위한 수정
    var assetName: String {
        switch self {
        case .normal: return ""
        case .bronze: return "bronzeBadge"
        case .silver: return "silverBadge"
        case .gold:   return "goldBadge"
        }
    }

    // 팀원의 로직을 그대로 static 함수로 유지
    static func from(score: Int) -> BadgeType1 {
        let safeScore = min(max(score, 0), 100)
        switch safeScore {
        case 0..<70:  return .normal
        case 70..<80: return .bronze
        case 80..<90: return .silver
        default:      return .gold
        }
    }
}

// 기존의 'Badge'와 겹치지 않게 'Info'를 붙였습니다.
struct BadgeInfo: Codable, Equatable {
    let badgeName: String
    var totalScore: Int
    var histories: [BadgeHistory]?

    var type : BadgeType1 {
        BadgeType1.from(score: totalScore)
    }
}

struct BadgeHistory: Codable, Equatable {
    var reason: String
    var amount: Int
    var date: String
}

struct Personalities: Codable, Equatable {
    var socialType: String
    var meetingType: String
    var chatType: String
    var friendType: String
    var relationType: String

}

extension User {

    var tags: [String] {
        var result: [String] = []

        let age = ageInt
        if age > 0 {
            result.append("\(age)살")
        }

        if let personalities = personalities {
            result.append(personalities.socialType)
        }

        if let interests = interests {
            result.append(contentsOf: interests.prefix(2))
        }

        return result
    }
}
