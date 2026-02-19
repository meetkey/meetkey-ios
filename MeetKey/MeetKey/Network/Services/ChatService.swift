//
//  ChatService.swift
//  MeetKey
//
//  Created by 은재 on 2/11/26.
//

import Foundation

final class ChatService {
    static let shared = ChatService()
    private init() {}

    // 채팅방 목록 조회
    func fetchChatRooms() async throws -> [ChatRoomSummaryDTO] {
        try await withCheckedThrowingContinuation { continuation in
            NetworkProvider.shared.requestChat(.fetchChatRooms, type: [ChatRoomSummaryDTO].self) { result in
                switch result {
                case .success(let rooms):
                    continuation.resume(returning: rooms)
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }

    // 채팅 메시지 조회 (cursor optional)
    func fetchMessages(roomId: Int, cursorId: Int? = nil) async throws -> ChatRoomMessagesDTO {
        try await withCheckedThrowingContinuation { continuation in
            NetworkProvider.shared.requestChat(.fetchMessages(roomId: roomId, cursorId: cursorId),
                                               type: ChatRoomMessagesDTO.self) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }

    // 채팅방 생성
    func createChatRoom(targetUserId: Int) async throws -> CreateChatRoomDTO {
        try await withCheckedThrowingContinuation { continuation in
            NetworkProvider.shared.requestChat(.createChatRoom(targetUserId: targetUserId),
                                               type: CreateChatRoomDTO.self) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }

    // 읽음 처리 (data 없음)
    func markAsRead(roomId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NetworkProvider.shared.requestChat(.markAsRead(roomId: roomId),
                                               type: EmptyDTO.self) { result in
                switch result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }
    
    func updateAlarm(chatRoomId: Int, isAlarm: Bool) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            NetworkProvider.shared.requestChat(
                .updateAlarm(chatRoomId: chatRoomId, isAlarm: isAlarm),
                type: String.self
            ) { result in
                switch result {
                case .success(let msg):
                    continuation.resume(returning: msg)
                case .failure(let err):
                    continuation.resume(throwing: err)
                }
            }
        }
    }
}



//매칭 뷰에서 메시지 전송하기 위한 로직
extension ChatService {
    /// - Parameters:
    ///   - roomId: 채팅방 ID
    ///   - content: 메시지 내용
    ///   - type: 메시지 타입 (기본 "TEXT")
    func sendMatchMessage(roomId: Int, content: String, type: String = "TEXT") {
        // 1. 서버 명세서에 따른 페이로드 구성 (Encodable DTO가 있다고 가정)
        // let payload = ["chatRoomId": roomId, "messageType": type, "content": content]
        
        // 2. 실제 STOMP 전송 로직이 들어갈 자리
        print("🚀 [STOMP SEND MOCK] destination: /pub/chat/send")
        print("📦 [Payload]: \(content) (RoomID: \(roomId))")
        
        // TODO: 전송 로직 구현 후 말씀주세요,,,
        // stompClient.send(destination: "/pub/chat/send", body: payload)
    }
}
