//
//  RecommendationAPI.swift
//  MeetKey
//
//  Created by 전효빈 on 2/10/26.
//

import Alamofire
import Foundation
import Moya

enum RecommendationAPI {
    case getRecommendations(filter: RecommendationRequest)
    case sendAction(targetId: Int, action: ActionType)
}

enum ActionType: String {
    case like = "LIKE"
    case skip = "DISLIKE"
}

extension RecommendationAPI: TargetType {
    var method: Moya.Method {
        switch self {
        case .getRecommendations: return .get
        case .sendAction: return .post
        }
    }

    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getRecommendations: return "/matches/recommendations"
        case .sendAction: return "/matches/swipe"
        }
    }

    var task: Task {
        switch self {
        case .getRecommendations(let filter):
            let params = filter.toDictionary()
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        case .sendAction(let targetId, let action):
            return .requestParameters(
                parameters: [
                    "targetMemberId": targetId, "action": action.rawValue,
                ],
                encoding: JSONEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        let token = KeychainManager.load(account: "accessToken") ?? ""

        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        // 토큰 있을 때만 Authorization 붙이기
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        

        switch self {
        case .getRecommendations:
            break
        case .sendAction:
            break
        }
        return headers
    }

}
