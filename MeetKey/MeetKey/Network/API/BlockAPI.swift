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
        // 토큰 처리를 위한 헤더 설정
        return ["Content-Type": "application/json"]
    }
}
