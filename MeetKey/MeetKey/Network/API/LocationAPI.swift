//
//  LocationAPI.swift
//  MeetKey
//
//  Created by 전효빈 on 2/11/26.
//

import Alamofire
import Foundation
import Moya

enum LocationAPI {
    case updateLocation(latitude: Double, longitude: Double)
}

extension LocationAPI: TargetType {
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL + "/users") else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }

    var path: String {
        switch self {
        case .updateLocation:
            return "/me/location"
        }
    }

    var method: Moya.Method {
        switch self {
        case .updateLocation:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .updateLocation(let latitude, let longitude):
            return .requestParameters(
                parameters: [
                    "latitude": latitude,
                    "longitude": longitude,
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

        return headers
    }
}
