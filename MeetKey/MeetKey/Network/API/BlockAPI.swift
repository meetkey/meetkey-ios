//
//  BlockAPI.swift
//  MeetKey
//
//  Created by 전효빈 on 2/12/26.
//

import Foundation
import Moya
import Alamofire

enum BlockAPI {
    case blockUser(targetId: Int)
}

extension BlockAPI: TargetType {
    var baseURL: URL { URL(string: APIConfig.baseURL)! }
    var path: String {
        switch self {
        case .blockUser(let memberId):
            return "/users/block/\(memberId)"
        }
    }
    var method: Moya.Method { .post }
    var task: Task { .requestPlain }
    var headers: [String: String]? {
        let token = KeychainManager.load(account: "accessToken") ?? ""

        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        // 토큰 있을 때만 Authorization 붙이기
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }

        return headers
    }
}
