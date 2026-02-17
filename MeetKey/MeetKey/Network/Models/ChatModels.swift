//
//  ChatModels.swift
//  MeetKey
//
//  Created by 은재 on 2/11/26.
//

import Foundation

// 채팅방 목록 조회 (GET /chat-room)
struct ChatRoomSummaryDTO: Codable {
    let roomId: Int
    let chatOpponent: ChatOpponentDTO
    let lastChatMessages: String?
    let unReadMessageCnt: Int?
    let unreadCount: Int
    let updatedAt: String
}

struct ChatOpponentDTO: Codable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
}

// 채팅방 메시지 조회 (GET /chat-room/{roomId}/messages)
struct ChatRoomMessagesDTO: Codable {
    let roomId: Int
    let chatOpponent: ChatOpponentDTO
    let chatMessages: [ChatMessageDTO]
    let nextCursor: Int?
    let hasNext: Bool
}

enum ChatMessageType: String, Codable {
    case text = "TEXT"
    case image = "IMAGE"
    case audio = "AUDIO" // 혹시 서버 확장 대비
}

struct ChatMessageDTO: Codable {
    let messageId: Int
    let chatRoomId: Int
    let senderId: Int
    let messageType: ChatMessageType
    let content: String?
    let duration: Int?
    let createdAt: String
    let mine: Bool
}

// 채팅방 생성 (POST /chat-room)
struct CreateChatRoomDTO: Codable {
    let createdChatRoomId: Int
    let createdAt: String
}

// data 없는 응답용 (PATCH /chat-room/{roomId}/read 등)
struct EmptyDTO: Codable {
    init() {}
}

// (옵션) 서버 content가 "\"안녕하세요\""처럼 따옴표가 한번 더 들어오는 경우 UI 출력용
extension String {
    var unquoted: String {
        trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }
}
