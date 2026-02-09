//
//  MyInfoResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/9/26.
//

struct MyInfoResponseDTO: Decodable {
    let code: String
    let message: String
    let data: MyInfoDTO
}

struct MyInfoDTO: Decodable {
    let memberId: Int
    let name: String
    let first: String
    let target: String
    let age: Int
    let profileImage: String
    let recommendCount: Int
    let notRecommendCount: Int
    let badge: BadgeInfo
    let interests: [String]
    let personalities: Personalities?
    let bio: String?
}
