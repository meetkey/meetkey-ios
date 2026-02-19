//
//  StompClient.swift
//  MeetKey
//
//  Created by 은재 on 2/19/26.
//

import Foundation

final class StompClient {
    enum State { case idle, connecting, connected, error(String) }

    private let url: URL
    private var task: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)

    var stateChanged: ((State) -> Void)?
    var onFrame: ((StompFrame) -> Void)?
    var onError: ((String) -> Void)?

    init(url: URL) { self.url = url }

    func connect(accessToken: String) {
        stateChanged?(.connecting)

        var request = URLRequest(url: url)
        // ⚠️ 어떤 서버는 WebSocket 핸드셰이크 header로 Authorization 받음
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.webSocketTask(with: request)
        self.task = task
        task.resume()

        // STOMP CONNECT 프레임 전송
        let frame = StompFrame(
            command: "CONNECT",
            headers: [
                "Authorization": "Bearer \(accessToken)",
                "accept-version": "1.2",
                "heart-beat": "10000,10000"
            ],
            body: nil
        )
        sendRaw(frame.serialize())

        listen()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        stateChanged?(.idle)
    }

    func subscribe(id: String, destination: String) {
        let frame = StompFrame(
            command: "SUBSCRIBE",
            headers: ["id": id, "destination": destination],
            body: nil
        )
        sendRaw(frame.serialize())
    }

    func send(destination: String, jsonBody: String) {
        let frame = StompFrame(
            command: "SEND",
            headers: [
                "destination": destination,
                "content-type": "application/json"
            ],
            body: jsonBody
        )
        sendRaw(frame.serialize())
    }

    private func sendRaw(_ text: String) {
        task?.send(.string(text)) { [weak self] err in
            if let err {
                self?.onError?("WebSocket send error: \(err.localizedDescription)")
            }
        }
    }

    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let err):
                self.stateChanged?(.error(err.localizedDescription))
                self.onError?(err.localizedDescription)

            case .success(let message):
                let raw: String?
                switch message {
                case .string(let s): raw = s
                case .data(let d): raw = String(data: d, encoding: .utf8)
                @unknown default: raw = nil
                }

                if let raw, let frame = StompFrame.parse(raw) {
                    // CONNECTED / ERROR 처리
                    if frame.command == "CONNECTED" {
                        self.stateChanged?(.connected)
                    } else if frame.command == "ERROR" {
                        let msg = frame.headers["message"] ?? (frame.body ?? "STOMP ERROR")
                        self.stateChanged?(.error(msg))
                        self.onError?(msg)
                    }

                    self.onFrame?(frame)
                }
                // 계속 listening
                self.listen()
            }
        }
    }
}
