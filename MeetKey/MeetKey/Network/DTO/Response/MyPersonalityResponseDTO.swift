//
//  MyPersonalityResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/10/26.
//

struct MyPersonalityResponseDTOWrapper: Decodable {
    let code: String
    let message: String
    let data: MyPersonalityResponseDTO
}


struct MyPersonalityResponseDTO: Decodable {
    let categories: [PersonalitiesDTO]
}

struct PersonalitiesDTO: Decodable {
    let title: String
    let options: [String]
}
