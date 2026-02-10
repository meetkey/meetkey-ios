//
//  MyAPI.swift
//  MeetKey
//
//  Created by sumin Kong on 2/9/26.
//

import Foundation
import Moya
import Alamofire

enum TokenStorage {
    static var accessToken: String {
        // TODO: 로그인 후 교체 TokenStorage.accessToken = response.accessToken
        return MasterToken.value
    }
}

enum MasterToken {
    static let value = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwicm9sZSI6IlJPTEVfQURNSU4iLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzcwNjkyODc1LCJleHAiOjE4MDIyMjg4NzV9.l6I1k82Oc9RMuA37w_X1-xp2xrbXP8CCY87MhbmBmMs"
}

enum MyAPI {
    case myInfo
    case getInterest
    case getMyProfileImages
}

extension MyAPI: TargetType {
    var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json"
        ]

        let token = TokenStorage.accessToken
        print("🔑 accessToken:", token)

        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        print("🔑 headers:", headers)
        return headers
    }
    
    var baseURL: URL {
        guard let url = URL(string: APIConfig.baseURL + "/users") else {
            fatalError("Invalid base URL: \(APIConfig.baseURL)")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .myInfo:
            return "/me"
        case .getInterest:
            return "/interest"
        case .getMyProfileImages:
            return "/photos"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .myInfo, .getInterest, .getMyProfileImages:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .myInfo, .getInterest, .getMyProfileImages:
            return .requestPlain
        }
    }
}
