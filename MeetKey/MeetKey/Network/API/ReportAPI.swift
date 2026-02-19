import Alamofire
//
//  ReportAPI.swift
//  MeetKey
//
//  Created by 전효빈 on 2/12/26.
//
import Foundation
import Moya

enum ReportAPI {
    case sendReport(
        targetId: Int,
        type: ReportType,
        reason: String,
        images: [String]
    )
}

extension ReportAPI: TargetType {
    var baseURL: URL { URL(string: APIConfig.baseURL)! }
    var path: String {
        switch self {
        case .sendReport(let targetId, _, _, _):
            return "/report/\(targetId)"  // 명세서 경로 확인!
        }
    }
    var method: Moya.Method { .post }
    var task: Task {
        switch self {
        case .sendReport(_, let type, let reason, let images):
            let params: [String: Any] = [
                "reportType": type.rawValue,
                "body": reason,
                "imageUrls": images,
            ]
            return .requestParameters(
                parameters: params,
                encoding: JSONEncoding.default
            )
        }
    }

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
    
}
