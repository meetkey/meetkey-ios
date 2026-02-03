//
//  User.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI
import Foundation

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
    let code: String
    let message: String
    let data: User
}

// MARK: - 표준 유저 모델
struct User: Identifiable, Codable, Equatable {
    // 1. 서버 명세서 기준 필수 데이터
    let memberId: Int
    var id: Int { memberId } // SwiftUI Identifiable 대응 (Int 사용)
    let name: String
    let profileImage: String
    
    // 2. 상세 정보 (명세서 기준 + 옵셔널 처리)
    let age: Int?           // 서버에서 주는 나이
    let gender: String?      // "MALE", "FEMALE"
    let homeTown: String?
    let location: String?    // 팀원 모델 대응용
    let distance: String?
    let bio: String?         // bio == oneLiner 통합
    
    // 3. 언어 및 활동 데이터
    let first: String?       // 모국어 (usingLanguage)
    let target: String?      // 목표 언어 (interestingLanguage)
    let level: String?
    var recommendCount: Int? = nil
    var notRecommendCount: Int? = nil
    
    // 4. 성향 및 관심사
    let interests: [String]?
    let personalities: Personalities?
    
    // 5. 뱃지 데이터 (UI 컴포넌트 'Badge'와 충돌 방지를 위해 BadgeInfo로 명명)
    let badge: BadgeInfo?

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
        return calendar.dateComponents([.year], from: birth, to: Date()).year ?? 0
    }
    
    // 로직을 이식한 표시용 문자열 (String)
    var birthInfoString: String {
        guard let birth = birthDate else { return "정보 없음" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        let dateString = formatter.string(from: birth)
        return "만 \(ageInt)세 \(dateString)"
    }
    
    // Equatable 준수
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.memberId == rhs.memberId
    }
}

// MARK: - 하위 데이터 구조들

// 기존의 'Badge'와 겹치지 않게 'Info'를 붙였습니다.
struct BadgeInfo: Codable, Equatable {
    let badgeName: String
    let totalScore: Int
    let histories: [BadgeHistory]?
}

struct BadgeHistory: Codable, Equatable {
    let reason: String
    let amount: Int
    let date: String
}

struct Personalities: Codable, Equatable {
    let socialType: String
    let meetingType: String
    let chatType: String
    let friendType: String
    let relationType: String
}
