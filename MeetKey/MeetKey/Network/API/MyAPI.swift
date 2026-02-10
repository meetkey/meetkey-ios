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
    case updateInterest(dto: MyInterestEditRequestDTO)
    case getPersonality
    case updatePersonality(dto: MyPersonalityEditRequestDTO)
    case getMyProfileImages
}

extension MyAPI: TargetType {
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
            return "/me/interest"
        case .updateInterest:
            return "/me/interest"
        case .getPersonality:
            return "/me/personality"
        case .updatePersonality:
            return "/me/personality"
        case .getMyProfileImages:
            return "/photos"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .myInfo, .getInterest, .getPersonality, .getMyProfileImages:
            return .get
        case .updateInterest, .updatePersonality:
            return .put
        }
    }
    
    var task: Task {
    switch self {
    case .myInfo, .getInterest, .getPersonality, .getMyProfileImages:
            return .requestPlain
        case .updateInterest(let dto):
            return .requestJSONEncodable(dto)
    case .updatePersonality(dto: let dto):
        return .requestJSONEncodable(dto)
    }
    }
}
