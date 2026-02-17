//
//  HybinUserModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Foundation
import SwiftUI

enum SafeBadge: String, CaseIterable {
    case none = "none"
    case bronze = "bronze"
    case silver = "silver"
    case gold = "gold"
}

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
    var location: String  // 팀원 모델 대응용
    var distance: String?
    var bio: String?  // bio == oneLiner 통합

    // 3. 언어 및 활동 데이터
    var first: String
    var target: String
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
    //유저모델 바뀐거에 따른 옵셔널 제거
    var usingLanguage: String { first }
    var interestingLanguage: String { target }

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
        case .gold: return "goldBadge"
        }
    }

    // 팀원의 로직을 그대로 static 함수로 유지
    static func from(score: Int) -> BadgeType1 {
        let safeScore = min(max(score, 0), 100)
        switch safeScore {
        case 0..<70: return .normal
        case 70..<80: return .bronze
        case 80..<90: return .silver
        default: return .gold
        }
    }
}

struct BadgeInfo: Codable, Equatable {
    let badgeName: String
    var totalScore: Int
    var histories: [BadgeHistory]?

    var type: BadgeType1 {
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
        if let age = age, age > 0 {
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

    // User모델의 first와 target을 국기 이미지로 바꿔주는 프로퍼티
    var nativeNation: Nation? {
        Nation.from(serverValue: first)
    }

    var targetNation: Nation? {
        Nation.from(serverValue: target)
    }
}

//MARK: - 홈화면 유저 매칭을 위한 Response
extension User {
    init(from dto: RecommendationDTO) {
        self.id = dto.targetMemberId
        self.name = dto.nickname
        self.age = dto.age
        self.homeTown = dto.hometown
        if let distanceValue = dto.distance {
                self.distance = String(format: "%.1fkm", distanceValue)
            } else {
                self.distance = "거리를 확인할 수 없습니다"
            }
        self.gender = dto.gender
        self.first = dto.nativeLanguage.language
        self.target = dto.targetLanguage.language
        self.level = dto.targetLanguage.level ?? "초보"
        self.interests = dto.interests
        if let p = dto.personality {
            self.personalities = Personalities(
                socialType: p.socialType,
                meetingType: p.meetingType,
                chatType: p.chatType,
                friendType: p.friendType,
                relationType: p.relationType
            )
        } else {
            self.personalities = nil
        }
        self.profileImage = dto.photoUrls.first ?? "profileImageSample1"
        self.bio = dto.introduction

        self.location = dto.location ?? "위치를 찾을 수 없습니다"
        
        if let badgeData = dto.badge {
            self.badge = BadgeInfo(
                badgeName: badgeData.level ?? "일반",
                totalScore: badgeData.score ?? 0,
                histories: nil
            )
        } else { self.badge = nil }
        
        self.birthDate = nil
    }
}

extension User {
    // MyInfo API 응답용 init
    init(dto: MyInfoDTO) {
        self.id = dto.memberId
        self.name = dto.name
        self.profileImage = dto.profileImage
        self.first = dto.first
        self.target = dto.target
        self.recommendCount = dto.recommendCount
        self.notRecommendCount = dto.notRecommendCount
        self.badge = dto.badge
        self.interests = dto.interests
        self.personalities = dto.personalities
        self.bio = dto.bio
        self.age = dto.age
        
        // MyInfo API에서는 location과 level을 주지 않으므로 기본값 사용
        self.location = "현재 위치"
        self.level = "BEGINNER"
        self.gender = nil
        self.homeTown = nil
        
        // UserDefaults에서 birthDate 불러오기
        if let birthDateString = UserDefaults.standard.string(forKey: "userBirthDate") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            self.birthDate = formatter.date(from: birthDateString)
        } else {
            self.birthDate = nil
        }
    }
    
    // EditProfile API 응답용 init
    init(dto: EditProfileDTO) {
        self.id = dto.memberId
        self.name = dto.name
        self.profileImage = ""
        self.first = dto.first
        self.target = dto.target
        self.bio = dto.bio
        self.age = dto.age
        self.location = dto.location
        self.level = dto.level
        
        // 기본값 설정
        self.recommendCount = 0
        self.notRecommendCount = 0
        self.badge = nil
        self.interests = nil
        self.personalities = nil
        self.gender = nil
        self.homeTown = nil
        
        // UserDefaults에서 birthDate 불러오기
        if let birthDateString = UserDefaults.standard.string(forKey: "userBirthDate") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            self.birthDate = formatter.date(from: birthDateString)
        } else {
            self.birthDate = nil
        }
    }
    
    // birthDate를 UserDefaults에 저장하는 헬퍼 메서드
    static func saveBirthDate(_ birthDateString: String) {
        UserDefaults.standard.set(birthDateString, forKey: "userBirthDate")
    }
}
