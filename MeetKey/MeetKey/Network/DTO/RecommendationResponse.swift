//
//  RecommendationResponse.swift
//  MeetKey
//
//  Created by 전효빈 on 2/10/26.
//

//매칭 API

import Foundation

struct RecommendationResponse: Codable {
    let code: String
    let message: String
    let data: RecommendationDataDTO
}



struct RecommendationDataDTO: Codable {
    let recommendations: [RecommendationDTO]
    let swipeInfo: SwipeInfoDTO
    let matchType: String
}

struct RecommendationDTO: Codable {
    let targetMemberId: Int
    let nickname: String
    let age: Int
    let hometown: String?
    let distance: Double?
    let gender: String
    let nativeLanguage: LanguageDTO
    let targetLanguage: LanguageDTO
    let interests: [String]?
    let personality: PersonalityDTO?
    let photoUrls: [String]
    let introduction: String?
    let badge: BadgeDTO?
    let location: String?
}

struct LanguageDTO: Codable {
    let language: String
    let level: String?
}

struct PersonalityDTO: Codable {
    let socialType: String
    let meetingType: String
    let chatType: String
    let friendType: String
    let relationType: String
}

struct BadgeDTO: Codable {
    let level : String?
    let score: Int?
}

struct SwipeInfoDTO: Codable {
    let remainingCount: Int
    let totalCount: Int
}

