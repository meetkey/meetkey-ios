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
        var headers = ["Content-Type": "application/json"]
            
        let accessToken = APIConfig.testToken
            
        headers["Authorization"] = "Bearer \(accessToken)"
        return headers
    }
}
