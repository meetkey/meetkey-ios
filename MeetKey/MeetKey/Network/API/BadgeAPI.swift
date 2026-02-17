//
//  BadgeAPI.swift
//  MeetKey
//
//  Created by sumin Kong on 2/17/26.
//

import Foundation
import Moya
import Alamofire


enum BadgeAPI {
    case getMyBadgeRecord
}

extension BadgeAPI: TargetType {
    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]
        
        let token = TokenStorage.accessToken
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        return headers
    }
    
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL) else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getMyBadgeRecord:
            return "/badges/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMyBadgeRecord:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getMyBadgeRecord:
            return .requestPlain
        }
    }
}
