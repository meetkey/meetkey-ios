import Foundation

struct PersonalityUpdateRequest: Codable {
    let socialType: String
    let meetingType: String
    let chatType: String
    let friendType: String
    let relationType: String
}

struct InterestsUpdateRequest: Codable {
    let interests: [String]
}

struct PhotoUploadRequestItem: Codable {
    let fileName: String
    let contentType: String
}
