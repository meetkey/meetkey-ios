//
//  StompFrame.swift
//  MeetKey
//
//  Created by 은재 on 2/19/26.
//

import Foundation

struct StompFrame {
    let command: String
    var headers: [String: String] = [:]
    var body: String? = nil

    func serialize() -> String {
        var lines: [String] = [command]
        for (k, v) in headers { lines.append("\(k):\(v)") }
        lines.append("") // header/body separator
        if let body { lines.append(body) }
        return lines.joined(separator: "\n") + "\u{00}" // NULL terminator
    }

    static func parse(_ raw: String) -> StompFrame? {
        // heartbeat("\n") 같은 건 무시
        let trimmed = raw.trimmingCharacters(in: .newlines)
        if trimmed.isEmpty { return nil }

        // NULL 제거
        let noNull = raw.replacingOccurrences(of: "\u{00}", with: "")
        let parts = noNull.components(separatedBy: "\n\n")
        guard let head = parts.first else { return nil }

        let headLines = head.components(separatedBy: "\n")
        guard let command = headLines.first, !command.isEmpty else { return nil }

        var headers: [String: String] = [:]
        for line in headLines.dropFirst() {
            guard let idx = line.firstIndex(of: ":") else { continue }
            let k = String(line[..<idx])
            let v = String(line[line.index(after: idx)...])
            headers[k] = v
        }

        let body = parts.count > 1 ? parts[1] : nil
        return StompFrame(command: command, headers: headers, body: body)
    }
}
