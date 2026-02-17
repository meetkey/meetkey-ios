//
//  MyProfileImagesResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/10/26.
//

struct MyProfileImagesResponseDTO: Decodable {
    let code: String
    let message: String
    let data: [String]
}
