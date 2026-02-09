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
    static let value = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI2Iiwicm9sZSI6IlJPTEVfQURNSU4iLCJ0eXBlIjoiYWNjZXNzIiwiaWF0IjoxNzcwMjg1OTQwLCJleHAiOjE4MDE4MjE5NDB9.yWoGhcB-vPHz5504eeAAhg8i1Lb9GxH1dO8kc6NiJjc"
}

enum MyAPI {
    case myInfo
}

extension MyAPI: TargetType {
    var headers: [String : String]? {
        var headers: [String: String] = ["Content-Type": "application/json"]
        let token = TokenStorage.accessToken
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .myInfo:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .myInfo:
            return .requestPlain
        }
    }
}
