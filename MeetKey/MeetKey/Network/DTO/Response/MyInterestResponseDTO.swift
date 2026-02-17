//
//  MyInterestResponseDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/10/26.
//

struct MyInterestResponseDTOWrapper: Decodable {
    let code: String
    let message: String
    let data: MyInterestResponseDTO
}

struct MyInterestResponseDTO: Decodable {
    let categories: [InterestCategoryDTO]
}

struct InterestCategoryDTO: Decodable {
    let category: String
    let items: [InterestItemDTO]
}

struct InterestItemDTO: Decodable, Hashable {
    let code: String
    let name: String
}
