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
}

extension RecommendationAPI: TargetType {
    var method: Moya.Method { .get }

    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .getRecommendations: return "/matches/recommendations"
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
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        // Authorizaiton 넣어야함

        switch self {
        case .getRecommendations:
            break
        }
        return headers
    }

}
