//
//  ChatStompService.swift
//  MeetKey
//
//  Created by 은재 on 2/19/26.
//

import Foundation

final class ChatStompService {
    static let shared = ChatStompService()
    private init() {}

    private var client: StompClient?
    private let decoder = JSONDecoder()

    var onMessage: ((ChatMessageDTO) -> Void)?
    var onError: ((String) -> Void)?

    func connectIfNeeded(accessToken: String) {
        guard client == nil else { return }
        decoder.dateDecodingStrategy = .iso8601

        // ✅ 명세의 WS 엔드포인트로 변경
        let url = URL(string: "wss://api.meetkey.com/ws-chat")!

        let stomp = StompClient(url: url)
        self.client = stomp

        stomp.onError = { [weak self] msg in
            print("STOMP ERROR:",msg)
            self?.onError?(msg) }

        stomp.onFrame = { [weak self] frame in
            
            print("STOMP:", frame.command, frame.headers)
            guard let self else { return }

            if frame.command == "CONNECTED" {
                // ✅ 개인 큐 구독
                stomp.subscribe(id: "sub-0", destination: "/user/queue/chat")
                return
            }

            if frame.command == "MESSAGE" {
                guard let body = frame.body,
                      let data = body.data(using: .utf8) else { return }
                if let dto = try? self.decoder.decode(ChatMessageDTO.self, from: data) {
                    self.onMessage?(dto)
                }
            }
        }

        stomp.connect(accessToken: accessToken)
    }

    func sendMessage(_ payload: StompSendChatPayload) {
        guard let client else { return }
        guard let data = try? JSONEncoder().encode(payload),
              let json = String(data: data, encoding: .utf8) else { return }
        client.send(destination: "/pub/chat/send", jsonBody: json)
    }
}

