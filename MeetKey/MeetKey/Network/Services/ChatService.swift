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
}
