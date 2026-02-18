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
        let token = KeychainManager.load(account: "accessToken") ?? ""
        
        // 🔍 디버깅 로그 추가
            print("------------------------------------------")
            print("🚀 [NETWORK DEBUG] API 요청 발생")
            print("📍 경로(Path): \(path)")
            print("🔑 토큰 존재 여부: \(token.isEmpty ? "❌ 없음" : "✅ 있음")")
            if !token.isEmpty {
                print("🎫 토큰 앞부분: \(token.prefix(15))...") // 토큰 유효성 대조용
            }
            print("------------------------------------------")

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
