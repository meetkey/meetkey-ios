//
//  MyPersonalityEditRequestDTO.swift
//  MeetKey
//
//  Created by sumin Kong on 2/11/26.
//

struct MyPersonalityEditRequestDTO: Encodable {
    let socialType: String
    let meetingType: String
    let chatType: String
    let friendType: String
    let relationType: String

    init(from selections: [String: String]) {
        self.socialType = selections["socialType"] ?? ""
        self.meetingType = selections["meetingType"] ?? ""
        self.chatType = selections["chatType"] ?? ""
        self.friendType = selections["friendType"] ?? ""
        self.relationType = selections["relationType"] ?? ""
    }
}
