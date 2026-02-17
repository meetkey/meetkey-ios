//
//  ImageUploadRequestDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/12/26.
//

struct ImageUploadRequestDTO: Encodable {
    let fileName: String
    let contentType: String
}

struct ImageUploadResponseDTO: Decodable {
    let code: String
    let message: String
    let data: [PresignedURLData]
}

struct PresignedURLData: Decodable {
    let url: String
    let key: String
}
