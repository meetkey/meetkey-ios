//
//  EditProfileResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/11/26.
//

struct EditProfileResponseDTO: Decodable {
    let code: String
    let message: String
    let data: EditProfileDTO
}

struct EditProfileDTO: Decodable {
    let memberId: Int
    let name: String
    let age: Int
    let location: String
    let bio: String?
    let first: String
    let target: String
    let level: String
}
