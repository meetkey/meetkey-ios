//
//  ChatRoomViewModel.swift
//  MeetKey
//
//  Created by 은재 on 2/19/26.
//

import Foundation
import Combine

@MainActor
final class ChatRoomViewModel: ObservableObject {

    let roomId: Int
    
    @Published var messages: [ChatMessage] = []
    @Published var loadError: String? = nil

    private var cancellables = Set<AnyCancellable>()
    @Published var lastSentText: String? = nil
    @Published var lastSentAt: Date? = nil

    init(roomId: Int) {
        self.roomId = roomId
    }

    func bindStomp(token: String) {
        ChatStompService.shared.onMessage = { [weak self] dto in
            guard let self else { return }
            guard dto.chatRoomId == self.roomId else { return }

            // 중복 방지
            if dto.mine,
               let last = self.lastSentText,
               let sentAt = self.lastSentAt,
               dto.messageType == .text,
               (dto.content ?? "") == last,
               Date().timeIntervalSince(sentAt) < 3.0 {
                self.lastSentText = nil
                self.lastSentAt = nil
                return
            }

            self.appendIncoming(dto)
        }

        ChatStompService.shared.onError = { [weak self] err in
            print("STOMP ERROR:", err)
            // self?.loadError = "실시간 연결 실패: \(err)"
        }

        ChatStompService.shared.connectIfNeeded(accessToken: token)
    }

    func sendText(_ text: String) {
        lastSentText = text
        lastSentAt = Date()

        let payload = StompSendChatPayload(
            chatRoomId: roomId,
            messageType: .text,
            content: text,
            duration: nil
        )
        ChatStompService.shared.sendMessage(payload)
    }

    private func appendIncoming(_ dto: ChatMessageDTO) {
        let time = dto.createdAt.replacingOccurrences(of: "T", with: " ").prefix(16)
        let timeStr = String(time)

        let newMsg: ChatMessage
        switch dto.messageType {
        case .text:
            newMsg = ChatMessage(kind: .text(dto.content ?? ""), isMe: dto.mine, time: timeStr)
        case .image:
            newMsg = ChatMessage(kind: .text("[IMAGE]"), isMe: dto.mine, time: timeStr)
        case .voice:
            newMsg = ChatMessage(kind: .text("[VOICE]"), isMe: dto.mine, time: timeStr)
        }

        messages.append(newMsg)
    }
}
