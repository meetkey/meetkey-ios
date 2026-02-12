//
//  OtherInfoResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/12/26.
//

struct  OtherInfoResponseDTO: Decodable {
    let code: String
    let message: String
    let data: OtherInfoDTO
}

struct OtherInfoDTO: Decodable {
    let memberId: Int
    let name: String
    let age: Int
    let gender: String
    let homeTown: String
    let profileImage: String
    let location: String
    let distance: String
    let recommendCount: Int
    let notRecommendCount: Int
    let badge: BadgeDTO?
    let first: String
    let target: String
    let level: String
    let interests: [String]
    let personalities: PersonalityDTO
    let bio: String
}

struct PersonalityDTO: Decodable {
    let socialType: String
    let meetingType: String
    let chatType: String
    let friendType: String
    let relationType: String
}

struct BadgeDTO: Decodable {
    let badgeName: String
    let totalScore: Int
    let histories: [BadgeHistoryDTO]
}

struct BadgeHistoryDTO: Decodable {
    let reason: String
    let amount: Int
    let date: String
}

