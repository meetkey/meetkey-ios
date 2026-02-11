import Foundation

struct PersonalityOptionsResponse: Codable {
    let categories: [PersonalityCategory]
}

struct PersonalityCategory: Codable, Hashable {
    let title: String
    let options: [String]
}

struct InterestOptionsResponse: Codable {
    let categories: [InterestCategory]
}

struct InterestCategory: Codable, Hashable {
    let category: String
    let items: [InterestItem]
}

struct InterestItem: Codable, Hashable {
    let code: String
    let name: String
}

struct PersonalityUpdateResponse: Codable {
    let socialType: String
    let meetingType: String
    let chatType: String
    let friendType: String
    let relationType: String
}

struct InterestsUpdateResponse: Codable {
    let interests: [String]
}

struct PhotoUploadResponseItem: Codable {
    let url: String
    let key: String
}
