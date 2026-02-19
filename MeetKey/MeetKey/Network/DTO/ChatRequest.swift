//
//  ChatSendRequestDTO.swift
//  MeetKey
//
//  Created by 은재 on 2/19/26.
//

import Foundation

struct StompSendChatPayload: Codable {
    let chatRoomId: Int
    let messageType: ChatMessageType
    let content: String
    let duration: Int?
}
