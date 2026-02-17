//
//  MyProfileSettingsRequestDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/11/26.
//

struct MyProfileSettingsRequestDTO: Encodable {
    let location : String
    let latitude: Double
    let longitude: Double
    let bio: String
    let first: String
    let target: String
    let level: String
}
