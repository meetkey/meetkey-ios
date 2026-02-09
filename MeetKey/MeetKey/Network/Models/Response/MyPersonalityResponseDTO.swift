//
//  MyPersonalityResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/10/26.
//

struct MyPersonalityResponseDTO: Decodable {
    let categories: MyPersonalityDTO
}

struct MyPersonalityDTO: Decodable {
    let title: String
    let options: [String]
}
